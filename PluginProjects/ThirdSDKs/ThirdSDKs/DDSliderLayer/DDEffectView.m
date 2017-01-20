//
//  DDEffectView.m
//  TestSthDemo
//
//  Created by RYD on 13-9-1.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import "DDEffectView.h"
#import "UIImage+ImageEffects.h"


static DDEffectView *_sharedView;


@interface DDEffectView ()

- (UIImage*)capture; //抓图

@end



@implementation DDEffectView


- (id)init {
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    
        //add _backView
        _backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _backView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backView];
        
        //add _effectView
        _effectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _effectView.backgroundColor = [UIColor clearColor];
        _effectView.alpha = 0.0;
        [self addSubview:_effectView];
        
        //add _maskview
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.0;
        [self addSubview:_maskView];
        
        //@Radar 暂时关闭_maskView的黑色效果
        _maskView.hidden = YES;
        
    }
    return self;
}

+ (DDEffectView*)sharedView
{
	if (!_sharedView) {
		_sharedView = [[DDEffectView alloc] init];
	}
	return _sharedView;
}

- (void)dealloc
{		
    [_backView release];
    [_effectView release];
    [_maskView release];
    
	[_sharedView release];
	[super dealloc];
}


#pragma mark -
#pragma mark in use functions
- (UIImage *)capture
{
    UIWindow *topWindow = [UIApplication sharedApplication].keyWindow;
    CGRect rect = [UIScreen mainScreen].bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        //注释：第二个参数，如果没做iPhone6+适配，必须为YES，否则效果出错，如果已经做了适配，则为NO也没问题
        [topWindow drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    }
    else
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [topWindow.layer renderInContext:ctx];
    }
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}




#pragma mark -
#pragma mark out use functions
- (void)showEffectWithin:(NSTimeInterval)timeInterval
{
    //抓图并渲染
    //NSLog(@"开始抓图");
    UIImage *screenShot = [self capture];
    //NSLog(@"抓图完成");
    UIImage *effectShot = [screenShot applyLightEffect];
    //NSLog(@"模糊完成");
    
    //test 保存到桌面 ----------
    //NSData *imageData = UIImageJPEGRepresentation(screenShot, 1.0);
    //[imageData writeToFile:@"/Users/dangdangmobile/Desktop/compiledPhoto.jpg" atomically:YES];
    //-------------------
    
    
    //显示本类
    UIView *topView = [UIApplication sharedApplication].keyWindow;
    [topView addSubview:self];
    
    //图片添加
    _backView.image = screenShot;
    _effectView.image = effectShot;
    _effectView.alpha = 0.0;
    
    //动画显示模糊效果    
    [UIView animateWithDuration:timeInterval 
                     animations:^{
                         _effectView.alpha = max_effect_percent;
                         _maskView.alpha = 0.1;
                     }
    ];
    
    
//    //显示本类
//    UIView *topView = [UIApplication sharedApplication].keyWindow;
//    [topView addSubview:self];
//    
//    NSLog(@"开始子线程");
//    //异步抓图并返回主线程显示
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        //抓图并渲染
//        NSLog(@"开始抓图");
//        UIImage *screenShot = [self capture];
//        NSLog(@"抓图完成");
//        UIImage *effectShot = [screenShot applyLightEffect];
//        NSLog(@"模糊完成");
//        
//        //保存到桌面 ----------
//        //NSData *imageData = UIImageJPEGRepresentation(screenShot, 1.0);
//        //[imageData writeToFile:@"/Users/dangdangmobile/Desktop/compiledPhoto.jpg" atomically:YES];
//        //-------------------
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            NSLog(@"回到主线程");
//            
//            
//            //图片添加
//            _backView.image = screenShot;
//            _effectView.image = effectShot;
//            _effectView.alpha = 0.0;
//            
//            NSLog(@"添加图片完成");
//            
//            //动画显示模糊效果
//            [UIView animateWithDuration:timeInterval delay:0 
//                                options:UIViewAnimationOptionCurveEaseOut
//                             animations:^{
//                                 _effectView.alpha = 1.0;
//                             }
//                             completion:^(BOOL finished){
//                                 
//                             }
//             ];
//
//        });
//    });
}

- (void)closeEffectWithin:(NSTimeInterval)timeInterval
{
    if(_effectView.alpha == 0) return;
    if(![self superview]) return;
    
    //动画关闭模糊效果
    [UIView animateWithDuration:timeInterval delay:0 
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         _effectView.alpha = 0.0;
                         _maskView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
 
                        [self removeFromSuperview];
                     }
     ];
}

- (void)fixEffectByPercent:(float)percent
{
    //根据模糊的百分比来修正模糊的比例，0～1 之间， percent越大越模糊
    if(_effectView.alpha == 0) return;
    if(![self superview]) return;
    
    _effectView.alpha = percent*max_effect_percent;
    
    //如果是完全不需要模糊了，就把本类移除了
    if(percent == 0.0 && [self superview])
    {
        [self removeFromSuperview];
    }
    
}




@end
