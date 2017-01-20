//
//  DDTLogoView.h
//  CMSTableViewDemo
//
//  Created by Radar on 13-5-28.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    positionHeader = 0, //logoView放在滚动页面header的位置
    positionFooter      //logoView放在滚动页面footer的位置
} LogoViewPosition;


@interface DDTLogoView : UIView {
 
    UIImageView *_logoView;
    LogoViewPosition _position;//logo要放置在DDTLogoView的顶部还是底部，用于区别放在外面滚动页的上方还是下方
    
    
    UIImage *_logo;
}

@property (nonatomic, retain) UIImage *logo;        //要显示的logo图片，必须从外部设定，否则就无效果


- (id)initWithFrame:(CGRect)frame withPosition:(LogoViewPosition)position; //初始化方法

- (void)setShowHeight:(float)height; //设置显示高度，这个高度就是从外面看到的部分的高度


@end
