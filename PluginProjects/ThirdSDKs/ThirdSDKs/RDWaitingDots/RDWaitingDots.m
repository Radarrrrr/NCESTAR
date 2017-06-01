//
//  RDWaitingDots.m
//  TestSth
//
//  Created by Radar on 2017/5/31.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import "RDWaitingDots.h"


#define dot_width   8  //圆点直径
#define dots_offset 4  //圆点间隔

#define dots_color_hide    [UIColor clearColor]
#define dots_color_waiting [UIColor colorWithRed:255.0f/255.0f green:150.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
#define dots_color_success [UIColor colorWithRed:50.0f/255.0f green:220.0f/255.0f blue:210.0f/255.0f alpha:1.0f]
#define dots_color_failure [UIColor colorWithRed:255.0f/255.0f green:30.0f/255.0f blue:0.0f/255.0f alpha:1.0f]


@interface RDWaitingDots ()

@property (nonatomic, strong) UIView *dot1;
@property (nonatomic, strong) UIView *dot2;
@property (nonatomic, strong) UIView *dot3;

@end


static BOOL dotsFlashing = NO;  //是否正在闪烁


@implementation RDWaitingDots

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        self.backgroundColor = [UIColor clearColor];
        self.flashStyle = RDWaitingDotsFlashStyleFulling;
        
        //添加点击事件
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tapGesture];
        
        //添加圆点
        self.dot2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dot_width, dot_width)];
        _dot2.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
        _dot2.userInteractionEnabled = NO;
        _dot2.backgroundColor = dots_color_waiting;
        _dot2.alpha = 0.0;
        [self addRadiusToView:_dot2 radius:dot_width/2];
        [self addSubview:_dot2];
        
        self.dot1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dot_width, dot_width)];
        _dot1.center = CGPointMake(CGRectGetMidX(_dot2.frame)-dots_offset-dot_width, CGRectGetMidY(_dot2.frame));
        _dot1.userInteractionEnabled = NO;
        _dot1.backgroundColor = dots_color_waiting;
        _dot1.alpha = 0.0;
        [self addRadiusToView:_dot1 radius:dot_width/2];
        [self addSubview:_dot1];
        
        self.dot3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dot_width, dot_width)];
        _dot3.center = CGPointMake(CGRectGetMidX(_dot2.frame)+dots_offset+dot_width, CGRectGetMidY(_dot2.frame));
        _dot3.userInteractionEnabled = NO;
        _dot3.backgroundColor = dots_color_waiting;
        _dot3.alpha = 0.0;
        [self addRadiusToView:_dot3 radius:dot_width/2];
        [self addSubview:_dot3];
        
    }
    return self;
}

- (void)addRadiusToView:(UIView*)view radius:(float)radius
{
    if(!view) return;
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}


- (void)tapAction:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapActionFromWaitingDots:)])
    {
        [_delegate didTapActionFromWaitingDots:self];
    }
}




//触发等待和结束
- (void)startWaiting
{
    if(dotsFlashing) return;
    dotsFlashing = YES;
    
    //先全部还原
    _dot1.alpha = 0.0;
    _dot2.alpha = 0.0;
    _dot3.alpha = 0.0;
    
    //开始闪烁
    if(_flashStyle == RDWaitingDotsFlashStyleFulling)
    {
        [self runFulling];
    }
    else if(_flashStyle == RDWaitingDotsFlashStyleRolling)
    {
        isForwarding = YES;
        [self runRolling];
    }
    
}
- (void)stopWaitingForState:(RDWaitingDotsFinishState)state
{
    dotsFlashing = NO;
    
    if(_flashStyle == RDWaitingDotsFlashStyleRolling)
    {
        isForwarding = YES;
    }
    
    //更改状态
    switch (state) {
        case RDWaitingDotsFinishStateHide:
        {
            _dot1.backgroundColor = dots_color_hide;
            _dot2.backgroundColor = dots_color_hide;
            _dot3.backgroundColor = dots_color_hide;
        }
            break;
        case RDWaitingDotsFinishStateSuccess:
        {
            _dot1.backgroundColor = dots_color_success;
            _dot2.backgroundColor = dots_color_success;
            _dot3.backgroundColor = dots_color_success;
        }
            break;
        case RDWaitingDotsFinishStateFailure:
        {
            _dot1.backgroundColor = dots_color_failure;
            _dot2.backgroundColor = dots_color_failure;
            _dot3.backgroundColor = dots_color_failure;
        }
            break;
        default:
            break;
    }
}


//填满滚动方式RDWaitingDotsFlashStyleFulling
- (void)runFulling
{
    [UIView animateWithDuration:0.5 animations:^{
        
        _dot1.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            _dot2.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                _dot3.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5 animations:^{
                    
                    _dot1.alpha = 0.0;
                    _dot2.alpha = 0.0;
                    _dot3.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    if(dotsFlashing)
                    {
                        [self runFulling];
                    }
                    else
                    {
                        [UIView animateWithDuration:0.5 animations:^{
                            _dot1.alpha = 1.0;
                            _dot2.alpha = 1.0;
                            _dot3.alpha = 1.0;
                        }];
                    }
                    
                }];
  
            }];
        }];
    }];
}


//前后滚动方式RDWaitingDotsFlashStyleRolling
static BOOL isForwarding = YES; //是否正向显示
- (void)runRolling 
{  
    if(isForwarding) //正向前进
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            _dot1.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                _dot1.alpha = 0.0;
                _dot2.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5 animations:^{
                    
                    _dot2.alpha = 0.0;
                    _dot3.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                    
                    if(dotsFlashing)
                    {
                        isForwarding = NO;
                        [self runRolling];
                    }
                    
                }];
            }];
        }];
    }
    else    //反向倒退
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            _dot3.alpha = 0.0;
            _dot2.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                _dot2.alpha = 0.0;
                _dot1.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                if(dotsFlashing)
                {
                    isForwarding = YES;
                    [self runRolling];
                }
                else
                {
                    [UIView animateWithDuration:0.5 animations:^{
                        _dot1.alpha = 1.0;
                        _dot2.alpha = 1.0;
                        _dot3.alpha = 1.0;
                    }];
                }
                
            }];
        }];
    }
} 








@end
