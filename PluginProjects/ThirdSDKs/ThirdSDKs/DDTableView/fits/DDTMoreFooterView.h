//
//  DDTMoreFooterView.h
//  Radar Use
//
//  Created by Radar on 13-1-11.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import <UIKit/UIKit.h>


#define more_footer_height   40.0  //加载更多的部分的高度，默认40,可以改 //注意: 这个高度一定不能小于最后一个cell的高度，否则可能会出现显示错误


//_backGroundButton的默认文字和风格，外部可以随意更改
//更改的方式是直接使用 view或使用用 backGroundButton 属性
#define more_footer_place_holder        @"加载更多"
#define more_footer_text_font           [UIFont systemFontOfSize:14.0]
#define more_footer_text_color          [UIColor grayColor]
#define more_footer_back_ground_color   [UIColor clearColor];


@class DDTMoreFooterView;
@protocol DDTMoreFooterViewDelegate <NSObject> 
@optional
- (void)moreFooterViewDidTapTrigger;
@end


@interface DDTMoreFooterView : UIView {

    UIActivityIndicatorView *_spinner;
    NSString *_titleCache; //用来做背景按钮文字的缓存用的，点击滚动开始的时候缓存起来，滚动完成的时候再设定回去
    
    UIButton *_backGroundButton;
    
@private
	id _delegate;	
}
@property (assign) id<DDTMoreFooterViewDelegate> delegate;
@property (nonatomic, retain) UIButton *backGroundButton;       //作为背景用的按钮，可以在外部修改此属性以改动点击或者此footview的背景风格
@property (nonatomic, retain) UIActivityIndicatorView *spinner; //旋转的部分，可以在外面改大小和属性

- (void)startWaiting;
- (void)stopWaiting;


@end
