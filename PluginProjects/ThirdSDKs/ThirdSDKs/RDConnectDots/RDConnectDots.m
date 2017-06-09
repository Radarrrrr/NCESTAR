//
//  RDConnectDots.m
//  TestSth
//
//  Created by Radar on 2017/5/31.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import "RDConnectDots.h"


#define default_dot_width   8  //默认圆点直径
#define default_dots_offset 8  //默认圆点间隔
#define default_dots_amount 3  //默认圆点数量

//#define 


#define dots_color_hide    [UIColor clearColor]
#define dots_color_waiting [UIColor colorWithRed:255.0f/255.0f green:150.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
#define dots_color_success [UIColor colorWithRed:50.0f/255.0f green:220.0f/255.0f blue:210.0f/255.0f alpha:1.0f]
#define dots_color_failure [UIColor colorWithRed:255.0f/255.0f green:30.0f/255.0f blue:0.0f/255.0f alpha:1.0f]


@interface RDConnectDots ()

@property (nonatomic, strong) UIView *dot1;
@property (nonatomic, strong) UIView *dot2;
@property (nonatomic, strong) UIView *dot3;
//@property (nonatomic, strong) UIView *dot4;

@property (nonatomic) BOOL dotsFlashing;  //是否正在闪烁

@end


@implementation RDConnectDots

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        self.backgroundColor = [UIColor clearColor];
        
        //初始化默认值
        self.diameter = default_dot_width; 
        self.space = default_dots_offset; 
        self.amount = default_dots_amount;
        
        //初始化状态值
        self.dotsFlashing = NO;  //是否正在闪烁
        
        //添加点击事件
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tapGesture];
        
        //添加圆点
        self.dot2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _diameter, _diameter)];
        _dot2.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
        _dot2.userInteractionEnabled = NO;
        _dot2.backgroundColor = dots_color_waiting;
        _dot2.alpha = 0.0;
        [self addRadiusToView:_dot2 radius:_diameter/2];
        [self addSubview:_dot2];
        
        self.dot1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _diameter, _diameter)];
        _dot1.center = CGPointMake(CGRectGetMidX(_dot2.frame)-_space-_diameter, CGRectGetMidY(_dot2.frame));
        _dot1.userInteractionEnabled = NO;
        _dot1.backgroundColor = dots_color_waiting;
        _dot1.alpha = 0.0;
        [self addRadiusToView:_dot1 radius:_diameter/2];
        [self addSubview:_dot1];
        
        self.dot3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _diameter, _diameter)];
        _dot3.center = CGPointMake(CGRectGetMidX(_dot2.frame)+_space+_diameter, CGRectGetMidY(_dot2.frame));
        _dot3.userInteractionEnabled = NO;
        _dot3.backgroundColor = dots_color_waiting;
        _dot3.alpha = 0.0;
        [self addRadiusToView:_dot3 radius:_diameter/2];
        [self addSubview:_dot3];
        
//        self.dot4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dot_width, dot_width)];
//        _dot4.center = CGPointMake(CGRectGetMidX(_dot2.frame)+dots_offset+dot_width, CGRectGetMidY(_dot2.frame));
//        _dot4.userInteractionEnabled = NO;
//        _dot4.backgroundColor = dots_color_waiting;
//        _dot4.alpha = 0.0;
//        [self addRadiusToView:_dot4 radius:dot_width/2];
//        [self addSubview:_dot4];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
}

- (void)addRadiusToView:(UIView*)view radius:(float)radius
{
    if(!view) return;
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}


- (void)tapAction:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapActionFromConnectDots:)])
    {
        [_delegate didTapActionFromConnectDots:self];
    }
}




//触发等待和结束
- (void)startWaiting
{
    if(_dotsFlashing) return;
    _dotsFlashing = YES;
    
    //先全部还原
    _dot1.alpha = 0.0;
    _dot2.alpha = 0.0;
    _dot3.alpha = 0.0;
    
    //开始闪烁
    [self runFulling];

}
- (void)stopWaitingForState:(RDConnectDotsFinishState)state
{
    _dotsFlashing = NO;
    
    //更改状态
    switch (state) {
        case RDConnectDotsFinishStateHide:
        {
            _dot1.backgroundColor = dots_color_hide;
            _dot2.backgroundColor = dots_color_hide;
            _dot3.backgroundColor = dots_color_hide;
        }
            break;
        case RDConnectDotsFinishStateSuccess:
        {
            _dot1.backgroundColor = dots_color_success;
            _dot2.backgroundColor = dots_color_success;
            _dot3.backgroundColor = dots_color_success;
        }
            break;
        case RDConnectDotsFinishStateFailure:
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
                    
                    if(_dotsFlashing)
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








@end
