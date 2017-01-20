//
//  UIButton+Color.h
//  TestNewIOS7
//
//  Created by Radar on 13-8-31.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ColorButton)

//扩展属性 数据data
@property (nonatomic,retain) id tagData;

//这个方法创建的button就只是一个设定了背景色的button，其他属性还必须自己去设定
+ (id)buttonWithColor:(UIColor*)nomalColor selColor:(UIColor*)selColor;

@end
