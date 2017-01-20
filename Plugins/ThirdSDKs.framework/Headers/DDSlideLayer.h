//
//  DDSlideLayer.h
//  DangDangHD
//
//  Created by Radar on 13-8-29.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DDMoveShowView.h"


@interface DDSlideLayer : NSObject <DDMoveShowDelegate> {
    
    DDMoveShowView *_slipPage;
    UINavigationController *_slipNav;
    
    id  _target;
    SEL _closedAction;
    
}
@property (nonatomic, retain) DDMoveShowView *slipPage;
@property (nonatomic, retain) UINavigationController *slipNav;


+ (DDSlideLayer*)sharedLayer;



/**
 * 获取浮层中的最顶层
 * 如果浮层不存在，则返回nil
 * 如果浮层的内容是view，则返回顶层view
 * 如果浮层的内容是viewcontroller，则返回顶层的viewcontroller
 */
- (id)visibleSlideLayer; 



/**
 * 呼叫浮层模块 #浮层内部content是一个UIView
 * @param aview     需要显示在浮层上的view
 * @param position  需要浮层出现的位置
 * @param limitRect 需要限制浮层容器的区域 如果不限制则设定为CGRectZero
 * @param lockBlank 是否锁定空白区域点击关闭浮层
 * @param lockPan   是否锁定手势滑动关闭
 * @param target    需要接收关闭事件返回的对象
 * @param action    需要接收关闭事件返回的方法
 */
- (void)callSlideLayerWithView:(UIView*)aview position:(ContentPosition)position limitRect:(CGRect)limitRect lockBlank:(BOOL)lockBlank lockPan:(BOOL)lockPan onTarget:(id)target closedAction:(SEL)action;
- (void)callSlideLayerWithView:(UIView*)aview position:(ContentPosition)position lockBlank:(BOOL)lock onTarget:(id)target closedAction:(SEL)action;//不限制浮层区域,需要手势关闭
- (void)callSlideLayerWithView:(UIView*)aview position:(ContentPosition)position lockBlank:(BOOL)lock; //不需要监测关闭事件返回,需要手势关闭
- (void)callSlideLayerWithView:(UIView*)aview position:(ContentPosition)position; //不需要监测关闭事件返回，且不需要锁屏,需要手势关闭



/**
 * 呼叫浮层模块 #浮层内部content是一个UIViewController
 * @param actrlor   需要显示在浮层上的viewcontroller
 * @param position  需要浮层出现的位置
 * @param limitRect 需要限制浮层容器的区域 如果不限制则设定为CGRectZero
 * @param lockBlank 是否锁定空白区域点击关闭浮层
 * @param lockPan   是否锁定手势滑动关闭
 * @param target    需要接收关闭事件返回的对象
 * @param action    需要接收关闭事件返回的方法
 */
- (void)callSlideLayerWithViewCtrlor:(UIViewController*)actrlor position:(ContentPosition)position limitRect:(CGRect)limitRect lockBlank:(BOOL)lockBlank lockPan:(BOOL)lockPan onTarget:(id)target closedAction:(SEL)action;
- (void)callSlideLayerWithViewCtrlor:(UIViewController*)actrlor position:(ContentPosition)position lockBlank:(BOOL)lock onTarget:(id)target closedAction:(SEL)action;//不限制浮层区域,需要手势关闭
- (void)callSlideLayerWithViewCtrlor:(UIViewController*)actrlor position:(ContentPosition)position lockBlank:(BOOL)lock; //不需要监测关闭事件返回,需要手势关闭
- (void)callSlideLayerWithViewCtrlor:(UIViewController*)actrlor position:(ContentPosition)position; //不需要监测关闭事件返回，且不需要锁屏,需要手势关闭



/**
 * 呼叫浮层模块 #浮层内部content可以是view或者viewcontroller
 * @param object    需要显示在浮层上的object
 * @param position  需要浮层出现的位置
 * @param limitRect 需要限制浮层容器的区域 如果不限制则设定为CGRectZero
 * @param lockBlank 是否锁定空白区域点击关闭浮层
 * @param lockPan   是否锁定手势滑动关闭
*/
- (void)callSlideLayerWithObject:(id)object 
                        position:(ContentPosition)position 
                       limitRect:(CGRect)limitRect 
                       lockBlank:(BOOL)lockBlank 
                         lockPan:(BOOL)lockPan
                      completion:(void (^)(void))completion;



/** 
 * 关闭浮层模块
 * 注意，同一时间只能有一个浮层，如果当前已经有浮层没有关闭，那么不能再呼叫新浮层
 */
- (void)closeSlideLayer;
- (void)closeSlideLayer:(void (^)(void))completion;


@end
