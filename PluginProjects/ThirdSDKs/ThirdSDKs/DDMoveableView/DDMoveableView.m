//
//  DDMoveableView.m
//  CMSMaker
//
//  Created by Radar on 14-1-15.
//  Copyright (c) 2014年 Radar. All rights reserved.
//

#import "DDMoveableView.h"

@implementation DDMoveableView

@synthesize delegate = _delegate;
@synthesize dragEnable;
@dynamic image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.dragEnable = YES;
        self.horizontalOnly = NO;
        self.verticalOnly = NO;
    }
    return self;
}

- (void)dealloc
{
    [_image release];
    [_imageView release];
    [super dealloc];
}





#pragma mark -
#pragma mark 参数设定相关
- (void)setImage:(UIImage *)image
{
    if(_image)
    {
        [_image release];
        _image = nil;
    }
    
    if(image)
    {
        _image = [image retain];
    }
    
    if(!_imageView)
    {
        //add _imageView
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _imageView.userInteractionEnabled = NO;
        [self addSubview:_imageView];   
    }
    _imageView.image = _image;
    
}

- (UIImage*)image
{
    return _image;
}





#pragma mark -
#pragma mark touch 操作相关
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!dragEnable) {
        return;
    }
    UITouch *touch = [touches anyObject];
    
    beginPoint = [touch locationInView:self];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!dragEnable) {
        return;
    }
    UITouch *touch = [touches anyObject];
    
    CGPoint nowPoint = [touch locationInView:self];
    
    float offsetX = nowPoint.x - beginPoint.x;
    float offsetY = nowPoint.y - beginPoint.y;
    
    float toX = self.center.x + offsetX;
    float toY = self.center.y + offsetY;
    
    //判断是否越界了
    if(toX < self.frame.size.width/2) 
    {
        toX = self.frame.size.width/2;
    }
    else if(toX > self.superview.frame.size.width-self.frame.size.width/2)
    {
        toX = self.superview.frame.size.width-self.frame.size.width/2;
    }
    
    if(toY < self.frame.size.height/2) 
    {
        toY = self.frame.size.height/2;
    }
    else if(toY > self.superview.frame.size.height-self.frame.size.height/2)
    {
        toY = self.superview.frame.size.height-self.frame.size.height/2;
    }

    
    if(_horizontalOnly)
    {
        toY = self.center.y;
    }
    if(_verticalOnly)
    {
        toX = self.center.x;
    }
    
    self.center = CGPointMake(toX, toY);
    
    //self.center = CGPointMake(self.center.x + offsetX, self.center.y + offsetY);
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event 
{
    if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(DDMoveableViewTouchUp:)])
	{
		[self.delegate DDMoveableViewTouchUp:self];
	}
}




@end
