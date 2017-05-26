//
//  MsgInputView.h
//  Home
//
//  Created by Radar on 2017/4/27.
//  Copyright © 2017年 Radar. All rights reserved.
//


//data结构：在DataCenter.h里边看       
        

#import <UIKit/UIKit.h>

@interface MsgInputView : UIView

+ (instancetype)sharedInstance; //单实例

- (void)callMsgInputToToken:(NSString*)toToken pushReport:(void(^)(PTPushReport *report))pushReportHandler completion:(void (^)(void))closeHandler;

@end
