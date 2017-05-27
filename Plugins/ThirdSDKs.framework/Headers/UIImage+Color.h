//
//  UIImage+Color.h
//  TestNewIOS7
//
//  Created by Radar on 13-8-31.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorImage)

+ (UIImage*)imageWithColor:(UIColor *)color andSize:(CGSize)size;  //根据颜色做图片
+ (UIImage*)imageNamed:(NSString *)name forme:(id)me;  //从me所在的framework的bundle里边，获取图片，me使用时必须写为self

@end
