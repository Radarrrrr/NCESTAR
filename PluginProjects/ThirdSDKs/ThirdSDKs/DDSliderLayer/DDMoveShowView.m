//
//  DDMoveShowView.m
//  DDDevLib
//
//  Created by Radar on 12-11-14.
//  Copyright (c) 2012年 www.dangdang.com. All rights reserved.
//

#import "DDMoveShowView.h"



#pragma mark -
#pragma mark in use properties and functions
@interface DDMoveShowView ()

@property (nonatomic, retain) UIView *backView;
@property (nonatomic, retain) UIView *canvasView;

//根据content的位置和大小，确认content在view上的显示位置frame和隐藏位置的frame
- (void)confirmContentRectsForPosition:(ContentPosition)position contentSize:(CGSize)size; 

- (void)showCanvasView;   //显示和关闭容器
- (void)closeCanvasView;

//根据抬手时候手势加速度判断当前容器应该移动向哪个方向
- (void)fixUrlsTablePosition:(CGPoint)velocity;

@end




@implementation DDMoveShowView
@synthesize delegate = _delegate;
@synthesize backView = _backView;
@synthesize canvasView = _canvasView;
@synthesize sizeLocked = _sizeLocked;
@synthesize lockBlank = _lockBlank;
@dynamic panEnabled;
@dynamic contentView;
@dynamic useBackGround;

#pragma mark -
#pragma mark system functions
- (id)initWithFrame:(CGRect)frame contentPosition:(ContentPosition)position contentSize:(CGSize)contentSize
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        _contentPosition = position;
        _sizeLocked = YES;
        _showing = NO;
        _lockBlank = NO;
        _useBackGround = YES;
        _panEnabled = YES;
        
        //添加黑色半透明背景
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0.0;
        [self addSubview:_backView];
        
        //确认contentview的frame
        [self confirmContentRectsForPosition:position contentSize:contentSize];
        
        //添加_canvasView
        _canvasView = [[UIView alloc] initWithFrame:_canvasHideRect];
        _canvasView.backgroundColor = [UIColor clearColor];
        [self addSubview:_canvasView];

    }
    return self;
}

- (void)dealloc
{
    [_backView release];  
    [_canvasView release];
    [_contentView release];
    
    [super dealloc];
}

- (void)setPanEnabled:(BOOL)panEnabled
{
    _panEnabled = panEnabled;
    
    //添加手势 只有右滑有手势
    //if(_panEnabled && _contentPosition == positionRight)
    if(_panEnabled)
    {
        //先暂时只处理左右方向的
        if(_contentPosition == positionRight || _contentPosition == positionLeft)
        {
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
            [self addGestureRecognizer:panGesture];
            [panGesture release];
        }
    }
}
- (BOOL)panEnabled
{
    return _panEnabled;
}

- (void)setContentView:(UIView *)theView
{
    if(_contentView && _contentView == theView) return;
    if(_contentView)
    {
        if([_contentView superview])
        {
            [_contentView removeFromSuperview];
        }
        [_contentView release];
    }
    
    _contentView = [theView retain];
    
    
    //判断谁根据谁的大小而改变
    if(_sizeLocked)
    {
        _contentView.frame = CGRectMake(0, 0, _canvasShowRect.size.width, _canvasShowRect.size.height);
    }
    else
    {
        [self confirmContentRectsForPosition:_contentPosition contentSize:theView.frame.size];
        
        if(_showing)
        {
            _canvasView.frame = _canvasShowRect;
        }
        else
        {
            _canvasView.frame = _canvasHideRect;
        }
    }
    
    
    //把_contentView加到canvas上
    [_canvasView addSubview:_contentView];
    
}

- (void)setUseBackGround:(BOOL)useBackGround
{
    _useBackGround = useBackGround;
    
    if(_useBackGround)
    {
        _backView.hidden = NO;
    }
    else
    {
        _backView.hidden = YES;
    }
}




#pragma mark -
#pragma mark in use functions
- (void)confirmContentRectsForPosition:(ContentPosition)position contentSize:(CGSize)size
{
    switch (position) 
    {
        case positionUP:
        {
            _canvasShowRect = CGRectMake(0, 0, self.frame.size.width, size.height);
            _canvasHideRect = CGRectMake(0, -size.height, self.frame.size.width, size.height);
        }
            break;
        case positionDown:
        {
            _canvasShowRect = CGRectMake(0, self.frame.size.height-size.height, self.frame.size.width, size.height);
            _canvasHideRect = CGRectMake(0, self.frame.size.height, self.frame.size.width, size.height);
        }
            break;
        case positionLeft:
        {
            _canvasShowRect = CGRectMake(0, 0, size.width, self.frame.size.height);
            _canvasHideRect = CGRectMake(-size.width, 0, size.width, self.frame.size.height);
        }
            break;
        case positionRight:
        {
            _canvasShowRect = CGRectMake(self.frame.size.width-size.width, 0, size.width, self.frame.size.height);
            _canvasHideRect = CGRectMake(self.frame.size.width, 0, size.width, self.frame.size.height);
        }
            break;
        default:
            break;
    }
}

- (void)showCanvasView
{
    //动画显示
    [UIView beginAnimations:@"show_moveshow" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	_backView.alpha = 0.5;
    _canvasView.frame = _canvasShowRect;
	
	[UIView commitAnimations];
}
- (void)closeCanvasView
{
    //动画显示
    [UIView beginAnimations:@"close_moveshow" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	_backView.alpha = 0.0;
    _canvasView.frame = _canvasHideRect;
	
	[UIView commitAnimations];
}
- (void)fixUrlsTablePosition:(CGPoint)velocity
{
    //判断是否越过中线, 修正接口列表位置
    float off = 50;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        off = 100;
    }
    
    if(_contentPosition == positionRight)
    {
        float cx = _canvasView.frame.origin.x;  
        float limx = self.frame.size.width-_canvasView.frame.size.width+off;
        
        //判断是否显示和隐藏
        if(velocity.x >= 0)  //向右滑动
        {
            //过线就关闭
            if(cx <= limx)
            {
                //移动到展开位置
                [self showCanvasView];
            }
            else
            {
                //移动到收起来的位置
                [self closeCanvasView];
            }
        }
        else                //向左滑动
        {
            if(velocity.x < -100)
            {
                //移动到展开位置
                [self showCanvasView];
            }
            else
            {
                //过线就关闭
                if(cx <= limx)
                {
                    //移动到展开位置
                    [self showCanvasView];
                }
                else
                {
                    //移动到收起来的位置
                    [self closeCanvasView];
                }
            }
        }
    }
    else if(_contentPosition == positionLeft)
    {
        off = 100;
        float cx = _canvasView.frame.origin.x+_canvasView.frame.size.width;  
        float limx = _canvasView.frame.size.width-off;
        
        //判断是否显示和隐藏
        if(velocity.x >= 0)  //向右滑动
        {
            if(velocity.x > 100)
            {
                //移动到展开位置
                [self showCanvasView];
            }
            else
            {
                //过线就开启
                if(cx >= limx)
                {
                    //移动到展开位置
                    [self showCanvasView];
                }
                else
                {
                    //移动到收起来的位置
                    [self closeCanvasView];
                }
            }
        }
        else                //向左滑动
        {
            //过线就关闭
            if(cx >= limx)
            {
                //移动到展开位置
                [self showCanvasView];
            }
            else
            {
                //移动到收起来的位置
                [self closeCanvasView];
            }
            
        }
    }

}

- (void)handleShowPercent:(float)percent
{
    //处理当前获取到的显示百分比
    if(_useBackGround)
    {
        //如果使用黑色背景，那么把黑色背景的alpha和百分比挂钩
        _backView.alpha = 0.5*percent;
    }
    
    //通过代理返回给上层
    if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(ddMoveShowViewChangeShowPercent:percent:)])
	{
		[self.delegate ddMoveShowViewChangeShowPercent:self percent:percent];
	}
    
}




#pragma mark -
#pragma mark out use functions
- (void)callInView:(UIView*)theView
{
    if(!theView) return;
    
    //把自己添加到theView上
    [theView addSubview:self];
    
    //返回代理
    if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(ddMoveShowViewWillShow:)])
	{
		[self.delegate ddMoveShowViewWillShow:self];
	}
    
    //显示contentview
    [self showCanvasView];
}

- (void)close
{
    if(![self superview]) return;
    
    //返回代理
    if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(ddMoveShowViewWillClose:)])
    {
        [self.delegate ddMoveShowViewWillClose:self];
    }
    
    //关闭contentview
    [self closeCanvasView];
}




#pragma mark -
#pragma mark delegate functions
//animation delegate
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if([animationID compare:@"show_moveshow"] == NSOrderedSame)
    {
        _showing = YES;
        
        //显示状态设定为1.0
        [self handleShowPercent:1.0];
        
        //返回代理
        if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(ddMoveShowViewDidShow:)])
        {
            [self.delegate ddMoveShowViewDidShow:self];
        }
    }
    else if([animationID compare:@"close_moveshow"] == NSOrderedSame)
    {
        _showing = NO;
        
        //显示状态设定为0.0
        [self handleShowPercent:0.0];
        
        //返回代理
        if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(ddMoveShowViewDidClose:)])
        {
            [self.delegate ddMoveShowViewDidClose:self];
        }
        
        if(_contentView && [_contentView superview])
        {
            [_contentView removeFromSuperview];
        }
        
        [self removeFromSuperview];
    }
}





#pragma mark -
#pragma mark - Gesture handling
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]])
    {
        if(!_panEnabled) return;
        if(_lockBlank) return;
        

        UIGestureRecognizerState state = gestureRecognizer.state;
        if(state == UIGestureRecognizerStateBegan)
        {
            _currentX = _canvasView.frame.origin.x;
        }
        else if(state == UIGestureRecognizerStateChanged)
        {
            //处理平移位移
            CGPoint tr = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
            //NSLog(@"tr:(%f, %f)", tr.x, tr.y); 
         
            if(_contentPosition == positionRight)
            {
                //tr.x < 0 向左滑动, tr.x > 0向右滑动
                float tox = _currentX+tr.x;
                if(tox <= _canvasShowRect.origin.x)
                {
                    tox = _canvasShowRect.origin.x;
                }
                
                CGRect uframe = _canvasView.frame;
                uframe.origin.x = tox;
                _canvasView.frame = uframe;
                
                
                //监听容器的位置并处理显示百分比
                //计算当前已经显示出来的部分占总共需要显示的部分的百分比
                float tw = uframe.size.width;              //总宽度
                float cw = self.frame.size.width-tox;      //已经显示的宽度
                
                float percent = cw/tw; //已经显示的百分比
                [self handleShowPercent:percent];
                
            }
            else if(_contentPosition == positionLeft)
            {
                //tr.x < 0 向左滑动, tr.x > 0向右滑动
                float tox = _currentX+tr.x;             //tox < 0
                if(tox >= _canvasShowRect.origin.x)     
                {
                    tox = _canvasShowRect.origin.x;
                }
                
                CGRect uframe = _canvasView.frame;
                uframe.origin.x = tox;
                _canvasView.frame = uframe;
                
                
                //监听容器的位置并处理显示百分比
                //计算当前已经显示出来的部分占总共需要显示的部分的百分比
                float tw = uframe.size.width;              //总宽度
                float cw = uframe.size.width+tox;      //已经显示的宽度   //self.frame.size.width+tox;
                
                float percent = cw/tw; //已经显示的百分比
                [self handleShowPercent:percent];
                
            }
        }
        else if(state == UIGestureRecognizerStateEnded)
        {
            //处理加速度
            CGPoint vr = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self];
            //NSLog(@"vr:(%f, %f)", vr.x, vr.y); 
            
            if(_contentPosition == positionRight)
            {
                if(vr.x > 1000)         //vr.x > 0向右滑动
                {
                    [self closeCanvasView];
                }
                else if(vr.x < -1000)   //vr.x < 0 向左滑动
                {
                    [self showCanvasView];
                }
                else
                {
                    //检测是否越过limitline，自动移动到最左或者最右的位置
                    [self fixUrlsTablePosition:vr];
                }
            }
            else if(_contentPosition == positionLeft)
            {
                if(vr.x > 1000)         //vr.x > 0向右滑动
                {
                    [self showCanvasView];
                }
                else if(vr.x < -1000)   //vr.x < 0 向左滑动
                {
                    [self closeCanvasView];
                }
                else
                {
                    //检测是否越过limitline，自动移动到最左或者最右的位置
                    [self fixUrlsTablePosition:vr];
                }
            }
            
        }
            
    }
}





#pragma mark -
#pragma mark touches functions
- (void) touchesCanceled 
{
}
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event 
{
}
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event 
{
}
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event 
{
	NSSet *allTouches = [event allTouches];
	
    switch ([allTouches count]) {
        case 1: 
		{
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			CGPoint tapPoint = [touch locationInView:self];
			
            switch (touch.tapCount) 
			{
                case 1: 
				{		
                    if(!_lockBlank)
                    {
                        BOOL bIn = CGRectContainsPoint(_canvasShowRect, tapPoint);
                        if(!bIn)
                        {
                            //发送消息通知，本类关闭
                            [[NSNotificationCenter defaultCenter] postNotificationName:lib_notification_DDMoveShowView_need_close object:nil userInfo:nil];
                            
                            //关闭本类
                            [self close];
                        }
                    }
				}
					break;
				default:
					break;
            }
        }
			break;
		default:
			break;
	}
}









@end
