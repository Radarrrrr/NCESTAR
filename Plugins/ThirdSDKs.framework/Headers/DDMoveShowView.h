//
//  DDMoveShowView.h
//  DDDevLib
//
//  Created by Radar on 12-11-14.
//  Copyright (c) 2012年 www.dangdang.com. All rights reserved.
//
//PS: 本类可自动实现某个小view在整个页面上的滑入滑出效果
/* 使用方法:
1. 正常创建本类，传入ContentPosition，并指定内部小view容器的尺寸，然后呼叫本类
DDMoveShowView *slipPage = [[DDMoveShowView alloc] initWithFrame:msvframe contentPosition:positionRight contentSize:contSize];
slipPage.sizeLocked = NO;
slipPage.lockBlank = NO;
slipPage.contentView = contentView;
slipPage.tag = 10008;
slipPage.delegate = dele;

[slipPage callInView:self.view];
[slipPage release];
 
2. 关闭本类
[slipPage close];
 
3. PS:本类在完成自己点击空白区域关闭动作以后，会返回消息通知 lib_notification_DDMoveShowView_need_close
   如果外部需要获取本类的关闭事件，则需要实现此消息通知的接收
*/ 
 
 

#import <UIKit/UIKit.h>


#define lib_notification_DDMoveShowView_need_close @"lib notification ddmoveshowview did close"

typedef enum {
    positionUP,     
    positionDown,   
    positionLeft,         
    positionRight
} ContentPosition; //contentview处在整个view的哪个位置


@class DDMoveShowView;
@protocol DDMoveShowDelegate <NSObject>
@optional
- (void)ddMoveShowViewWillShow:(DDMoveShowView*)moveShowView; //本类要启动之前
- (void)ddMoveShowViewDidShow:(DDMoveShowView*)moveShowView;  //本类启动完成

- (void)ddMoveShowViewWillClose:(DDMoveShowView*)moveShowView; //本类要关闭之前
- (void)ddMoveShowViewDidClose:(DDMoveShowView*)moveShowView;  //本类关闭完成

- (void)ddMoveShowViewChangeShowPercent:(DDMoveShowView*)moveShowView percent:(float)percent;  //本类改变了内部的显示百分比

@end



@interface DDMoveShowView : UIView {
 
    UIView *_backView;
    UIView *_canvasView;
    CGRect _canvasShowRect;
    CGRect _canvasHideRect;
    ContentPosition _contentPosition; //contentview的位置，由初始化的时候指定，不可更改
    BOOL _showing; //是否正在显示中

    UIView *_contentView;
    BOOL    _sizeLocked;  
    BOOL    _lockBlank;
    BOOL    _useBackGround;
    BOOL    _panEnabled;
    
    float _currentX;
    
@private
    id _delegate;
}



@property (assign) id <DDMoveShowDelegate> delegate;
@property (nonatomic)         BOOL   sizeLocked;    //default is YES, contentSize是否锁定，如果为NO，则按照新传入的contentView的size更改canvasView的大小，反之则把contentView按照canvasView大小更改
@property (nonatomic, retain) UIView *contentView;  //用来添加在_canvasView上的具体内容的view，由外部设定, 必须用在sizeLocked之后。
@property (nonatomic)         BOOL   lockBlank;     //default is NO， 是否锁定空白区域点击关闭本类
@property (nonatomic)         BOOL   useBackGround; //default is YES, 是否使用黑色半透明背景，默认使用，如果外部指定模糊背景效果，则从外部设定模糊效果，此属性设为 NO
@property (nonatomic)         BOOL   panEnabled;    //default is YES, 是否使用手势关闭右滑出来的页面, 这个参数目前只能支持在初始化的时候设定一次，还不能支持随时更改

//创建本类:
//frame:本类在父类上的frame, 
//contentPosition: 内部容器在本类view上的位置, 
//contentSize:     内部容器的大小，up／down的时候，只使用高度，left／right的时候，只使用宽度
- (id)initWithFrame:(CGRect)frame contentPosition:(ContentPosition)position contentSize:(CGSize)contentSize; 

- (void)callInView:(UIView*)theView; //在theview上呼叫本类
- (void)close; //关闭本类




@end
