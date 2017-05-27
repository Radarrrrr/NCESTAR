//
//  UIView+Effect.m
//  TestNewIOS7
//
//  Created by Radar on 13-8-31.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import "UIView+Effect.h"


@implementation UIView (EffectView)


//扩展方法
static BOOL spinAnimating; 
- (void)spinWithOptions: (UIViewAnimationOptions)options {  
    // this spin completes 360 degrees every 2 seconds  
    [UIView animateWithDuration: 0.3f  
                          delay: 0.0f  
                        options: options  
                     animations: ^{  
                         self.transform = CGAffineTransformRotate(self.transform, M_PI / 2);  
                     }  
                     completion: ^(BOOL finished) {  
                         if (finished) {  
                             if (spinAnimating) {  
                                 // if flag still set, keep spinning with constant speed  
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];  
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {  
                                 // one last spin, with deceleration  
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];  
                             }  
                         }  
                     }];  
}  

- (void)startSpining
{
    if (!spinAnimating) {  
        spinAnimating = YES;  
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];  
    } 
}
- (void)stopSpining
{
    spinAnimating = NO;  
}




//扩展闪烁方法
static BOOL flashAnimating; 
- (void)flashRun {  
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        self.alpha = 1.0;
        
        if(flashAnimating)
        {
            [self flashRun];
        }
        
    }];
}  
- (void)startFlash
{
    if (!flashAnimating) {  
        flashAnimating = YES;  
        [self flashRun];  
    } 
}
- (void)stopFlash
{
    flashAnimating = NO;
}









@end
