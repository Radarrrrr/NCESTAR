//
//  DDMoveableView.h
//  CMSMaker
//
//  Created by Radar on 14-1-15.
//  Copyright (c) 2014年 Radar. All rights reserved.
//


#import <UIKit/UIKit.h>


@class DDMoveableView;
@protocol DDMoveableViewDelegate <NSObject>
@optional

- (void)DDMoveableViewTouchUp:(DDMoveableView*)theView;
@end


@interface DDMoveableView : UIView {
    CGPoint beginPoint;
    
    UIImage *_image;
    UIImageView *_imageView;
    
@private
	id _delegate;	
}

@property (assign) id<DDMoveableViewDelegate> delegate;

@property (nonatomic) BOOL dragEnable;     //default is YES
@property (nonatomic) BOOL horizontalOnly; //default is NO 只允许水平移动
@property (nonatomic) BOOL verticalOnly;   //default is NO 只允许竖直移动

@property (nonatomic, retain) UIImage *image; //填充的图片


@end
