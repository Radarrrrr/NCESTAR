//
//  DDTRefreshCoverView.h
//  CMSTableViewDemo
//
//  Created by Radar on 13-5-27.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import <UIKit/UIKit.h>


#define refresh_cover_back_ground_color   [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0] //[UIColor whiteColor];

#define refresh_cover_place_holder        @"抱歉，数据载入失败\n请点击屏幕刷新"
#define refresh_cover_place_holder_font   [UIFont systemFontOfSize:12.0]          
#define refresh_cover_place_holder_color  [UIColor grayColor]

#define refresh_cover_waiting_text        @""  //@"载入中,请稍候..."
#define refresh_cover_waiting_font        [UIFont systemFontOfSize:12.0]          
#define refresh_cover_waiting_color       [UIColor grayColor]


@class DDTRefreshCoverView;
@protocol DDTRefreshCoverViewwDelegate <NSObject> 
@optional
- (void)refreshCoverViewDidTapTrigger;
@end


@interface DDTRefreshCoverView : UIView {
    
    UIActivityIndicatorView *_spinner;
    UIButton *_backGroundButton;
    UILabel *_placeHolderLabel;
    UILabel *_waitingLabel;
    
@private
	id _delegate;	
}
@property (assign) id<DDTRefreshCoverViewwDelegate> delegate;

@property (nonatomic, retain) UIButton *backGroundButton;       //作为背景用的按钮，可以在外部修改此属性以改动点击或者此footview的背景风格
@property (nonatomic, retain) UIActivityIndicatorView *spinner; //旋转的部分，可以在外面改大小和属性
@property (nonatomic, retain) UILabel *placeHolderLabel;        //默认文字的label,可以在外面修改属性，如果换文字需要换行，参考 @"抱歉，数据载入失败\n请点击屏幕刷新"

//等待旋转时候的等待文字label，可以在外面修改属性，不可以换行, 可以随时修改，下次调用startWaiting的时候效果就会变化
//PS: 默认没有文字，如果有文字的话，将在等待的时候出现在spinner的后面，
//PS: 可以通过外部调用waitingLabel.text来修改文字，也可以在本类内部修改宏来修改文字
@property (nonatomic, retain) UILabel *waitingLabel;           


- (void)startWaiting;
- (void)stopWaiting;


@end

