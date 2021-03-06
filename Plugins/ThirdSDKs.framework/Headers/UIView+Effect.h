//
//  UIView+Flash.h
//  TestNewIOS7
//
//  Created by Radar on 13-8-31.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//
//本类目前只扩展到无限旋转，如果需要限定旋转次数，再继续扩展

#import <UIKit/UIKit.h>

@interface UIView (EffectView)

//扩展旋转方法
- (void)startSpining;   //开始旋转
- (void)stopSpining;    //停止旋转

//扩展闪烁方法  //初始状态alpha为1
- (void)startFlash; //开始闪烁
- (void)stopFlash;  //停止闪烁

@end
