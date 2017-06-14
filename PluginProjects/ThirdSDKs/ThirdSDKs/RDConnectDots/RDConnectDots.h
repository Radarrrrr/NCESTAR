//
//  RDConnectDots.h
//  TestSth
//
//  Created by Radar on 2017/5/31.
//  Copyright © 2017年 Radar. All rights reserved.
//

//PS: 为连接状态和发送状态定制的小点效果，如果需要封装通用模块，还需要再整理

#import <UIKit/UIKit.h>



typedef enum {
    RDConnectDotsWaitingStateConnecting    = 0,    //等待连接中
    RDConnectDotsWaitingStateSending       = 1,    //等待发送中
    
} RDConnectDotsWaitingState;


typedef enum {
    RDConnectDotsFinishStateHide    = 0,    //隐藏，不再显示
    
    RDConnectDotsFinishStateConnectSuccess = 1,    //不隐藏，显示连接成功状态
    RDConnectDotsFinishStateConnectFailure = 2,           //不隐藏，显示连接失败状态
    
    RDConnectDotsFinishStateSendSuccess = 3,     //不隐藏，显示发送成功状态
    RDConnectDotsFinishStateSendFailure = 4      //不隐藏，显示发送失败状态
    
} RDConnectDotsFinishState;



@class RDConnectDots;
@protocol RDConnectDotsDelegate <NSObject>
@optional

//返回点击事件
- (void)didTapActionFromConnectDots:(RDConnectDots*)connectDots;

@end


@interface RDConnectDots : UIView

@property (assign) id <RDConnectDotsDelegate> delegate;

@property (nonatomic) float diameter;           //圆点直径 //不设定默认 8
@property (nonatomic) float space;              //原电间距 //不设定默认 8
@property (nonatomic) NSInteger amount;         //原点个数 //不设定默认 3
@property (nonatomic) NSTimeInterval duration;  //原点动画时间 //不设定默认0.5


//触发等待和结束
- (void)startWaiting:(RDConnectDotsWaitingState)state;
- (void)stopWaitingForState:(RDConnectDotsFinishState)state;


@end
