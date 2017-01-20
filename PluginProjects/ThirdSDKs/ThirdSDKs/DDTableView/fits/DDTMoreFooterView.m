//
//  DDTMoreFooterView.m
//  Radar Use
//
//  Created by Radar on 13-1-11.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import "DDTMoreFooterView.h"


@interface DDTMoreFooterView ()

- (void)triggerLoadMoreAction:(id)sender;

@end


@implementation DDTMoreFooterView
@synthesize delegate = _delegate;
@synthesize backGroundButton = _backGroundButton;
@synthesize spinner = _spinner;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = more_footer_back_ground_color;
        
        //add _backGroundButton
        self.backGroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backGroundButton.frame = CGRectMake(0, 0, frame.size.width, more_footer_height);
        [_backGroundButton addTarget:self action:@selector(triggerLoadMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backGroundButton];
        
        //设定一些属性
        _backGroundButton.titleLabel.font = more_footer_text_font;
        [_backGroundButton setTitleColor:more_footer_text_color forState:UIControlStateNormal];
        [_backGroundButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [_backGroundButton setTitle:more_footer_place_holder forState:UIControlStateNormal];
        

        //add _spinner;
        self.spinner = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((frame.size.width-20)/2, (more_footer_height-20)/2, 20, 20)] autorelease];
        _spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [_spinner stopAnimating];
        _spinner.alpha = 0.0;
        [self addSubview:_spinner];
        
    }
    return self;
}

- (void)dealloc
{
    [_spinner release];
    [_backGroundButton release];
    
    [super dealloc];
}





#pragma mark -
#pragma mark in use functions
- (void)triggerLoadMoreAction:(id)sender
{
    //返回给代理
    if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(moreFooterViewDidTapTrigger)])
    {
        [self.delegate moreFooterViewDidTapTrigger];
    }
}





#pragma mark -
#pragma mark out use functions
- (void)startWaiting
{
    _titleCache = _backGroundButton.titleLabel.text;
    
    [UIView beginAnimations:@"start_wait" context:nil];
	[UIView setAnimationDuration:0.2];
	
    _spinner.alpha = 1.0;
    [_backGroundButton setTitle:nil forState:UIControlStateNormal];
    
	[UIView commitAnimations];
    
    
    [_spinner startAnimating];
    
}
- (void)stopWaiting
{
    [_spinner stopAnimating];
    
    
    [UIView beginAnimations:@"stop_wait" context:nil];
	[UIView setAnimationDuration:0.2];
	
    _spinner.alpha = 0.0;
    [_backGroundButton setTitle:_titleCache forState:UIControlStateNormal];
    
	[UIView commitAnimations];
    
}






@end
