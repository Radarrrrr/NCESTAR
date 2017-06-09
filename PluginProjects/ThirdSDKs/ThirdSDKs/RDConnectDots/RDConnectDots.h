//
//  RDConnectDots.h
//  TestSth
//
//  Created by Radar on 2017/5/31.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef enum {
    RDConnectDotsFinishStateHide    = 0,    //隐藏，不再显示
    RDConnectDotsFinishStateSuccess = 1,    //不隐藏，显示成功状态
    RDConnectDotsFinishStateFailure = 2     //不隐藏，显示失败状态
    
} RDConnectDotsFinishState;


@class RDConnectDots;
@protocol RDConnectDotsDelegate <NSObject>
@optional

//返回点击事件
- (void)didTapActionFromConnectDots:(RDConnectDots*)connectDots;

@end


@interface RDConnectDots : UIView

@property (assign) id <RDConnectDotsDelegate> delegate;

@property (nonatomic) float diameter;       //圆点直径 //不设定默认 8
@property (nonatomic) float space;          //原电间距 //不设定默认 8
@property (nonatomic) NSInteger amount;     //原点个数 //不设定默认 3


//触发等待和结束
- (void)startWaiting;
- (void)stopWaitingForState:(RDConnectDotsFinishState)state;


@end
