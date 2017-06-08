//
//  MsgFunctionView.h
//  Home
//
//  Created by Radar on 2017/6/8.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSInteger{
    MSGFunctionActionAttention = 1000  //呼叫提醒
    
} MSGFunctionAction;


@protocol MsgFunctionViewDelegate <NSObject>
@optional

- (void)msgFunctionViewTargetAction:(MSGFunctionAction)action; //返回选择了那种操作事件

@end



@interface MsgFunctionView : UIView

@property (assign) id <MsgFunctionViewDelegate> delegate;

@end
