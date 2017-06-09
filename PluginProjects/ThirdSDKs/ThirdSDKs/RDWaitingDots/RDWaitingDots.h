//
//  RDWaitingDots.h
//  TestSth
//
//  Created by Radar on 2017/5/31.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    RDWaitingDotsFlashStyleFulling = 0,    //从前向后逐渐填满
    RDWaitingDotsFlashStyleRolling = 1     //前后滚动
    
} RDWaitingDotsFlashStyle;


typedef enum {
    RDWaitingDotsFinishStateHide    = 0,    //隐藏，不再显示
    RDWaitingDotsFinishStateSuccess = 1,    //不隐藏，显示成功状态
    RDWaitingDotsFinishStateFailure = 2     //不隐藏，显示失败状态
    
} RDWaitingDotsFinishState;


@class RDWaitingDots;
@protocol RDWaitingDotsDelegate <NSObject>
@optional

//返回点击事件
- (void)didTapActionFromWaitingDots:(RDWaitingDots*)waitingDots;

@end


@interface RDWaitingDots : UIView

@property (assign) id <RDWaitingDotsDelegate> delegate;

@property (nonatomic) RDWaitingDotsFlashStyle flashStyle; //设定闪烁风格 //默认为 RDWaitingDotsFlashStyleFulling


//触发等待和结束
- (void)startWaiting;
- (void)stopWaitingForState:(RDWaitingDotsFinishState)state;


@end
