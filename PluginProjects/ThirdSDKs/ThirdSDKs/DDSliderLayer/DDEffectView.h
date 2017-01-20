//
//  DDEffectView.h
//  TestSthDemo
//
//  Created by RYD on 13-9-1.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#define max_effect_percent 0.97

@interface DDEffectView : UIView {
    
    UIImageView *_backView;
    UIImageView *_effectView;
    UIView *_maskView;
}

+ (DDEffectView*)sharedView;


- (void)showEffectWithin:(NSTimeInterval)timeInterval;      //在timeInterval时间段内显示完全模糊效果，如果时间为0，则直接显示模糊效果
- (void)closeEffectWithin:(NSTimeInterval)timeInterval;     //在timeInterval时间段内关闭模糊效果，如果时间为0，则直接关闭模糊效果

- (void)fixEffectByPercent:(float)percent; //根据模糊的百分比来修正模糊的比例，0～1 之间， percent越大越模糊


@end
