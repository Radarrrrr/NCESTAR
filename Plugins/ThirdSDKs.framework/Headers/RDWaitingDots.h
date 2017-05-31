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
- (void)startFlashing;
- (void)stopFlashing;


@end
