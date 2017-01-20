//
//  DDTLogoView.m
//  CMSTableViewDemo
//
//  Created by Radar on 13-5-28.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import "DDTLogoView.h"


@interface DDTLogoView ()

- (void)adjustLogoViewPositon:(float)showHeight;

@end


@implementation DDTLogoView
@dynamic logo;

- (id)initWithFrame:(CGRect)frame withPosition:(LogoViewPosition)position
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _position = position;
        
        //add _logoView
        _logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_logoView];
        
    }
    return self;
}

- (void)dealloc
{
    [_logo release];
    [_logoView release];
    
    [super dealloc];
}


- (void)setLogo:(UIImage*)alogo
{
    [_logo release];
    
    if(alogo)
    {
        _logo = [alogo retain];
    }
    else
    {
        _logo = nil;
    }
    
    _logoView.image = _logo;
    
    //根据图片大小，调整_logoView的大小和位置
    CGRect sframe = self.frame;
    CGRect lframe = _logoView.frame;
    
    //如果图片过大，按照最宽处理
    CGSize logoSize = _logo.size;
    if(logoSize.width > sframe.size.width)
    {
        float k = logoSize.width/logoSize.height;
        
        logoSize.width = sframe.size.width;
        logoSize.height = logoSize.width/k;
    }
    
        
    lframe.size = logoSize;
    lframe.origin.x = (self.frame.size.width-logoSize.width)/2;
    
    if(_position == positionHeader)
    {
        lframe.origin.y = sframe.size.height - logoSize.height;
    }
    else if(_position == positionFooter)
    {
        lframe.origin.y = 0;
    }
    
    _logoView.frame = lframe;
}





#pragma mark -
#pragma mark in use functions
- (void)adjustLogoViewPositon:(float)showHeight
{
    if(!_logo) return;
    
    //根据当前frame的大小，调整_logoView的显示位置
    CGRect sframe = self.frame;
    CGRect lframe = _logoView.frame;
    
    float logoH = _logoView.frame.size.height;
    float logoY = 0.0;
    
    if(showHeight <= logoH)
    {
        //如果可显示区域比logo小，那么贴着一边放置
        if(_position == positionHeader)
        {
            logoY = sframe.size.height - lframe.size.height;
        }
        else if(_position == positionFooter)
        {
            logoY = 0.0;
        }
    }
    else
    {
        //如果可显示区域比logo大，那么放在可见区域的中间
        float blank = (showHeight-logoH)/2;
        
        if(_position == positionHeader)
        {
            
            logoY = sframe.size.height - lframe.size.height - blank;
        }
        else if(_position == positionFooter)
        {
            logoY = blank;
        }
    }
    
    //修改_logoView的位置
    lframe.origin.y = logoY;
    _logoView.frame = lframe;
}




#pragma mark -
#pragma mark out use functions
- (void)setShowHeight:(float)height
{
    //设置显示高度，这个高度就是从外面看到的部分的高度
    [self adjustLogoViewPositon:height];
}





@end
