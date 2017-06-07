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
+ (UIImage*)imageNamed:(NSString *)name forme:(id)me;  //从me所在的framework的bundle里边，获取图片，me使用时必须写为self，使用场景为在framework里边使用图片。因为此时不在主bundle，所以不能使用普通的imageNamed方法

@end
