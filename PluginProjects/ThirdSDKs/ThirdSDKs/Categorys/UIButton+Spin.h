//
//  UIButton+Spin.h
//  TestNewIOS7
//
//  Created by Radar on 13-8-31.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//
//本类目前只扩展到无限旋转，如果需要限定旋转次数，再继续扩展

#import <UIKit/UIKit.h>

@interface UIButton (SpinButton)

//扩展方法
- (void)startSpining;   //开始旋转
- (void)stopSpining;    //停止旋转


@end
