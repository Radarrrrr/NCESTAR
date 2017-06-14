//
//  RDConnectDots.m
//  TestSth
//
//  Created by Radar on 2017/5/31.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import "RDConnectDots.h"


#define default_dot_width   8  //默认圆点直径
#define default_dots_space  8  //默认圆点间隔
#define default_dots_amount 4  //默认圆点数量
#define default_dots_duration 0.5  //默认圆点动画时间

//#define 


#define dots_color_hide    [UIColor clearColor]

#define dots_color_connect_waiting  [UIColor colorWithRed:255.0f/255.0f green:150.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
#define dots_color_send_waiting     [UIColor colorWithRed:50.0f/255.0f green:220.0f/255.0f blue:210.0f/255.0f alpha:1.0f]

#define dots_color_connect_success  [UIColor colorWithRed:50.0f/255.0f green:220.0f/255.0f blue:210.0f/255.0f alpha:1.0f]
#define dots_color_send_success     [UIColor colorWithRed:50.0f/255.0f green:220.0f/255.0f blue:210.0f/255.0f alpha:1.0f]

#define dots_color_connect_failure  [UIColor lightGrayColor]
#define dots_color_send_failure     [UIColor colorWithRed:255.0f/255.0f green:30.0f/255.0f blue:0.0f/255.0f alpha:1.0f]


@interface RDConnectDots ()

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
        self.space = default_dots_space; 
        self.amount = default_dots_amount;
        self.duration = default_dots_duration;
        
        //初始化状态值
        self.dotsFlashing = NO;  //是否正在闪烁
        
        //添加点击事件
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tapGesture];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    //计算一下第一个圆点的起点
    float x1 = (CGRectGetWidth(self.frame)-_diameter*_amount-_space*(_amount-1))/2;
    
    //添加指定数量圆点, 初始化全部隐藏
    for(int i=0; i<_amount; i++)
    {
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(x1+i*(_diameter+_space), (CGRectGetHeight(self.frame)-_diameter)/2, _diameter, _diameter)];
        dot.userInteractionEnabled = NO;
        dot.backgroundColor = dots_color_hide;
        dot.alpha = 0.0;
        dot.tag = 100+i;
        [self addRadiusToView:dot radius:_diameter/2];
        [self addSubview:dot];
    }
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
- (void)startWaiting:(RDConnectDotsWaitingState)state
{
    if(_dotsFlashing) return;
    _dotsFlashing = YES;
    
    //先全部隐藏
    [self hideAllDots];
    
    //根据启动状态改变颜色
    switch (state) {
        case RDConnectDotsWaitingStateConnecting:
        {
            [self changeDotsColor:dots_color_connect_waiting];
        }
            break;
        case RDConnectDotsWaitingStateSending:
        {
            [self changeDotsColor:dots_color_send_waiting];
        }
            break;
        default:
            break;
    }
    
    //开始闪烁
    //[self runFulling];
    [self runFulling:0];

}
- (void)stopWaitingForState:(RDConnectDotsFinishState)state
{
    _dotsFlashing = NO;
    
    //更改状态
    switch (state) {
        case RDConnectDotsFinishStateHide:
        {
            [self changeDotsColor:dots_color_hide];
        }
            break;
        case RDConnectDotsFinishStateConnectSuccess:
        {
            [self changeDotsColor:dots_color_connect_success];
        }
            break;
        case RDConnectDotsFinishStateConnectFailure:
        {
            [self changeDotsColor:dots_color_connect_failure];
        }
            break;
        case RDConnectDotsFinishStateSendSuccess:
        {
            [self changeDotsColor:dots_color_send_success];
        }
            break;
        case RDConnectDotsFinishStateSendFailure:
        {
            [self changeDotsColor:dots_color_send_failure];
        }
            break;
        default:
            break;
    }
}


//填满滚动方式RDWaitingDotsFlashStyleFulling
- (void)runFulling:(int)index
{
    if(index >= _amount) return;
        
    int tag = 100+index;
    UIView *dot = [self viewWithTag:tag]; //dot一定存在，不判断了
    
    [UIView animateWithDuration:_duration animations:^{
        
        dot.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        if(index+1 < _amount)
        {
            //如果还有下一个,继续动画
            [self runFulling:index+1];
        }
        else
        {
            //如果是最后一个完成了
            [UIView animateWithDuration:0.5 animations:^{
                    
                //先全部隐藏
                [self hideAllDots];
                    
            } completion:^(BOOL finished) {
                    
                if(_dotsFlashing)
                {
                    [self runFulling:0];
                }
                else
                {
                    [UIView animateWithDuration:0.5 animations:^{
                        [self showAllDots];
                    }];
                }
                    
            }];
        }
    }];
}

- (void)hideAllDots
{
    //隐藏所有dots
    for(int i=0; i<_amount; i++)
    {
        int tag = 100+i;
        UIView *dot = [self viewWithTag:tag]; //dot一定存在，不判断了
        dot.alpha = 0.0;
    }
}
- (void)showAllDots
{
    //显示所有dots
    for(int i=0; i<_amount; i++)
    {
        int tag = 100+i;
        UIView *dot = [self viewWithTag:tag]; //dot一定存在，不判断了
        dot.alpha = 1.0;
    }
}

- (void)changeDotsColor:(UIColor *)color
{
    //修改所有dots颜色
    for(int i=0; i<_amount; i++)
    {
        int tag = 100+i;
        UIView *dot = [self viewWithTag:tag]; //dot一定存在，不判断了
        dot.backgroundColor = color;
        
        //追加改动一下颜色
        if(_amount >= 2)
        {
            if(color == dots_color_send_failure)
            {
                //如果是发送失败，前两个原点变成绿色，表示连接是成功的单是发送失败而已
                if(i==0 || i==1)
                {
                    dot.backgroundColor = dots_color_connect_success;
                }
            }
        }
    }
}





@end
