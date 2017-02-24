//
//  DDScrollButton.m
//  DDDevLib
//
//  Created by Radar on 12-10-15.
//  Copyright (c) 2012年 www.dangdang.com. All rights reserved.
//

#import "DDScrollButton.h"



#pragma mark -
#pragma mark in use functions & params
@interface DDScrollButton () 

- (void)itemAction:(id)sender;
- (void)checkContentPositionState;
- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size; //创建纯色背景

@end




@implementation DDScrollButton
@synthesize delegate=_delegate;
@synthesize scrollView = _scrollView;
@synthesize selectedIndex= _selectedIndex;
@synthesize selectionSyle = _selectionSyle;


#pragma mark -
#pragma mark overwrite system function 
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
        _selectionSyle = styleNone;
        _selectedIndex = -1;
		
		//background
		self.backgroundColor = [UIColor clearColor];
		
		//scrollview
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		_scrollView.backgroundColor = [UIColor clearColor];
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		[_scrollView setDelegate:self];
		[self addSubview:_scrollView];
        
    }
    return self;
}


- (void)dealloc {
    [_btnParams release];
	[_buttons release];
	[_scrollView release];
    
    [super dealloc];
}




#pragma mark -
#pragma mark in use functions
-(void)itemAction:(id)sender
{
	UIButton *itemBtn = (UIButton*)sender;
	[self chooseButtonForIndex:itemBtn.tag bReturnToDelegate:YES];
}
-(void)checkContentPositionState
{
	//check if content size overload
	BOOL bOverload = NO;
	ScrollButtonsPositon contentPosition;
	
	if(_scrollView.contentSize.width > self.frame.size.width)
	{
		bOverload = YES;
		
		//check content position
		float contentWidth = _scrollView.contentSize.width;
		float visibleWidth = _scrollView.frame.size.width;
		CGPoint contentOffset = _scrollView.contentOffset;
		
		if(contentOffset.x <= 0)
		{
			//max right
			contentPosition = posMaxRight;
		}
		else if(contentOffset.x + visibleWidth >= contentWidth)
		{
			//max left
			contentPosition = posMaxLeft;
		}
		else
		{
			//middle&nomal
			contentPosition = posNomal;
		}
	}
	else
	{
		bOverload = NO;
		contentPosition = posNomal;
	}
	
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(scrollButtonsContentViewOverLoad:contentPositon:)])
	{
		[self.delegate scrollButtonsContentViewOverLoad:bOverload contentPositon:contentPosition];
	}
}

- (UIImage*)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}



#pragma mark -
#pragma mark out use functions && can also be use in class
-(void)addButtonsForItems:(NSArray*)items withParams:(NSDictionary*)params
{
    if(!items || [items count] == 0) return;
    if(!params) return;
    
    _btnParams = [params retain];
    
    
    //解析设定的按钮配置串
    NSInteger btn_width        = [(NSNumber*)[_btnParams objectForKey:@"btn_width"] integerValue];
    NSInteger btn_height       = [(NSNumber*)[_btnParams objectForKey:@"btn_height"] integerValue];
    NSInteger btn_blank_offset = [(NSNumber*)[_btnParams objectForKey:@"btn_blank_offset"] integerValue];
    NSInteger btn_pos_offset_x = [(NSNumber*)[_btnParams objectForKey:@"btn_pos_offset_x"] integerValue];
    //NSInteger btn_move_offset  = [(NSNumber*)[_btnParams objectForKey:@"btn_move_offset"] integerValue];
    
    
	//add buttons
	NSMutableArray *buttons = [[[NSMutableArray alloc] init] autorelease];
	
	float posX = 0.0 + btn_pos_offset_x;
	float posY = (self.frame.size.height-btn_height)/2;
    if(posY<0.0) posY = 0.0;
    
	float contentWidth = 0.0 + btn_pos_offset_x;
	
	for(int i=0; i<[items count]; i++)
	{		
		UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		itemBtn.frame = CGRectMake(posX, posY, btn_width, btn_height);
		itemBtn.tag = i;
		[itemBtn addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        NSDictionary *dic = (NSDictionary*)[items objectAtIndex:i];
        
        //先判断是否有图片，如果有图片，那么就不管文字的事了
        NSString *imageName = (NSString*)[dic objectForKey:@"image_name"];
        if(imageName && [imageName compare:@""] != NSOrderedSame)
        {
            UIImage *image = [UIImage imageNamed:imageName];
            [itemBtn setBackgroundImage:image forState:UIControlStateNormal];
            
            //add btn image sel
            NSString *imageName_sel = (NSString*)[dic objectForKey:@"image_name_sel"];
            if(imageName_sel && [imageName_sel compare:@""] != NSOrderedSame)
            {
                UIImage *image_sel = [UIImage imageNamed:imageName_sel];
                [itemBtn setBackgroundImage:image_sel forState:UIControlStateHighlighted];
                [itemBtn setBackgroundImage:image_sel forState:UIControlStateSelected];
                [itemBtn setBackgroundImage:image_sel forState:UIControlStateDisabled];
            }
        }
        else
        {
            //如果没有图片，再看是否有文字
            NSString *title = (NSString*)[dic objectForKey:@"title"];
            if(title && [title compare:@""] != NSOrderedSame)
            {
                [itemBtn setTitle:title forState:UIControlStateNormal];
                
                //add btn title sel
                NSString *title_sel = (NSString*)[dic objectForKey:@"title_sel"];
                if(title_sel && [title_sel compare:@""] != NSOrderedSame)
                {
                    [itemBtn setTitle:title_sel forState:UIControlStateHighlighted];
                    [itemBtn setTitle:title_sel forState:UIControlStateSelected];
                    [itemBtn setTitle:title_sel forState:UIControlStateDisabled];
                }
                
                UIColor *tcolor      = [dic objectForKey:@"title_color"];
                UIColor *tcolor_sel  = [dic objectForKey:@"title_color_sel"];
                UIFont  *tfont       = [dic objectForKey:@"title_font"];
                UIColor *bgcolor     = [dic objectForKey:@"bg_color"];
                UIColor *bgcolor_sel = [dic objectForKey:@"bg_color_sel"];
                
                if(bgcolor)
                {
                    UIImage *bgimg = [self imageWithColor:bgcolor andSize:CGSizeMake(btn_width, btn_height)];
                    [itemBtn setBackgroundImage:bgimg forState:UIControlStateNormal];
                }
                if(bgcolor_sel)
                {
                    UIImage *bgimg_sel = [self imageWithColor:bgcolor_sel andSize:CGSizeMake(btn_width, btn_height)];
                    [itemBtn setBackgroundImage:bgimg_sel forState:UIControlStateHighlighted];
                    [itemBtn setBackgroundImage:bgimg_sel forState:UIControlStateSelected];
                    [itemBtn setBackgroundImage:bgimg_sel forState:UIControlStateDisabled];
                }
                
                if(tcolor)
                {
                    [itemBtn setTitleColor:tcolor forState:UIControlStateNormal];
                }
                if(tcolor_sel)
                {
                    [itemBtn setTitleColor:tcolor_sel forState:UIControlStateHighlighted];
                    [itemBtn setTitleColor:tcolor_sel forState:UIControlStateSelected];
                    [itemBtn setTitleColor:tcolor_sel forState:UIControlStateDisabled];
                }
                
                if(tfont)
                {
                    itemBtn.titleLabel.font = tfont;
                }
                
            }
        }
        
        
		[_scrollView addSubview:itemBtn];
		
		posX += btn_width;
        posX += btn_blank_offset;
        
		contentWidth +=btn_width;
        if(i<[items count]-1)
        {
            contentWidth += btn_blank_offset;
        }
        
		
		//add btns into array
		[buttons addObject:itemBtn];
	}
	
	contentWidth += btn_pos_offset_x;
	
	
	_buttons = [buttons retain];
	_scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
	
	
	
	//check contnet view position state
	[self checkContentPositionState];
	
}
-(void)chooseButtonForIndex:(NSInteger)index bReturnToDelegate:(BOOL)bReturnTodele
{
	if(_buttons == nil || [_buttons count] ==0) return;

	//暂时注释掉，如果选择以后，需要有选中状态的改变，就改写这个地方
    _selectedIndex = index;
    
    if(_selectionSyle == styleSelected)
    {
        for(UIButton *btn in _buttons)
        {                
            if(btn.tag == index)
            {
                btn.selected = YES;
            }
            else
            {
                btn.selected = NO;
            }
        }
    }
    else if(_selectionSyle == styleDisabled)
    {
        for(UIButton *btn in _buttons)
        {                
            if(btn.tag == index)
            {
                btn.enabled = NO;
            }
            else
            {
                btn.enabled = YES;
            }
        }
    }
    
	
	if(bReturnTodele)
	{
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(scrollButtonChooseIndex:)])
		{
			[self.delegate scrollButtonChooseIndex:index];
		}
	}
}

-(void)clearChoose
{
    //清空选择状态
    _selectedIndex = -1;
    
    //把当前选中的按钮变为未选中
    if(_selectionSyle == styleSelected)
    {
        for(UIButton *btn in _buttons)
        {                
            btn.selected = NO;
        }
    }
    else if(_selectionSyle == styleDisabled)
    {
        for(UIButton *btn in _buttons)
        {                
             btn.enabled = YES;
        }
    }
}

-(void)moveButtonsToLeft
{
	//check
	CGPoint contentOffset = _scrollView.contentOffset;
	
	float canMoveOffset = contentOffset.x;
	if(canMoveOffset <= 0) return;
    if(!_btnParams) return;
    
	//解析设定的按钮配置串
    NSInteger btn_move_offset  = [(NSNumber*)[_btnParams objectForKey:@"btn_move_offset"] integerValue];
    
	float moveOffset = btn_move_offset;
	if(canMoveOffset < btn_move_offset)
	{
		moveOffset = canMoveOffset;
	}
	
	//move
	CGPoint offset = _scrollView.contentOffset;
	offset.x = offset.x - moveOffset;
	_scrollView.contentOffset = offset;

}
-(void)moveButtonsToRight
{
	//check
	float contentWidth = _scrollView.contentSize.width;
	float visibleWidth = _scrollView.frame.size.width;
	CGPoint contentOffset = _scrollView.contentOffset;
	
	float canMoveOffset = contentWidth - contentOffset.x - visibleWidth;
	if(canMoveOffset <= 0) return;
    if(!_btnParams) return;
    
	//解析设定的按钮配置串
    NSInteger btn_move_offset  = [(NSNumber*)[_btnParams objectForKey:@"btn_move_offset"] integerValue];
	
	float moveOffset = btn_move_offset;
	if(canMoveOffset < btn_move_offset)
	{
		moveOffset = canMoveOffset;
	}

	//move
	CGPoint offset = _scrollView.contentOffset;
	offset.x = offset.x + moveOffset;
	_scrollView.contentOffset = offset;
	
}
-(void)setScrollButtonFrame:(CGRect)frame
{
	self.frame = frame;
	_scrollView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
	
	//check contnet view position state
	[self checkContentPositionState];
}





#pragma mark -
#pragma mark delegate functions
//UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	float contentWidth = _scrollView.contentSize.width;
	float visibleWidth = _scrollView.frame.size.width;
	CGPoint contentOffset = _scrollView.contentOffset;
	
	if(contentOffset.x <= 0)
	{
		//scroll to max right
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(scrollButtonsScrollToPosition:)])
		{
			[self.delegate scrollButtonsScrollToPosition:posMaxRight];
		}
	}
	else if(contentOffset.x + visibleWidth >= contentWidth)
	{
		//scroll to max left
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(scrollButtonsScrollToPosition:)])
		{
			[self.delegate scrollButtonsScrollToPosition:posMaxLeft];
		}
	}
	else
	{
		//at middle state
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(scrollButtonsScrollToPosition:)])
		{
			[self.delegate scrollButtonsScrollToPosition:posNomal];
		}
	}

}




@end
