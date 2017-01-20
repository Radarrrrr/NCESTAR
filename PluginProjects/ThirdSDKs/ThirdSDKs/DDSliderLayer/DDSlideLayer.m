//
//  DDSlideLayer.m
//  dddemo
//
//  Created by Radar on 13-8-29.
//  Copyright (c) 2013年 www.dangdang.com. All rights reserved.
//

#import "DDSlideLayer.h"
#import "DDEffectView.h"

static DDSlideLayer *_sharedLayer;

@interface DDSlideLayer ()

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL closedAction;
@property (nonatomic, copy) void (^closeCompletionBlock)(void);

@end


@implementation DDSlideLayer
@synthesize slipPage = _slipPage;
@synthesize slipNav = _slipNav;
@synthesize target = _target;
@synthesize closedAction = _closedAction;

+ (DDSlideLayer*)sharedLayer
{
	if (!_sharedLayer) {
		_sharedLayer = [[DDSlideLayer alloc] init];
	}
	return _sharedLayer;
}

- (void)dealloc
{		
    if(_slipPage)
    {
        _slipPage.delegate = nil;
        [_slipPage release];
    }
    [_slipNav release];
    
    Block_release(_closeCompletionBlock);
    
	[_sharedLayer release];
	[super dealloc];
}





#pragma mark -
#pragma mark out use functions
- (id)visibleSlideLayer
{
    if(!_slipPage) return nil;
    
    if(_slipNav)
    {
        //是VC结构的
        return _slipNav.topViewController;
    }
    else
    {
        //是view结构的
        return _slipPage.contentView;
    }
}


//view相关的
- (void)callSlideLayerWithView:(UIView*)aview position:(ContentPosition)position limitRect:(CGRect)limitRect lockBlank:(BOOL)lockBlank lockPan:(BOOL)lockPan onTarget:(id)target closedAction:(SEL)action
{
    if(!aview) return;
    
    //如果当前已经有浮层了，那么直接返回，不能同时有两个浮层
    if(_slipPage) return;
    
    if(CGRectEqualToRect(limitRect, CGRectZero))
    {
        //先添加模糊效果
        [[DDEffectView sharedView] showEffectWithin:0.25];
    }
    
    //获取返回的事件
    self.target = nil;
    self.closedAction = nil;
    if(target && action)
    {
        self.target = target;
        self.closedAction = action;
    }
    
    //    ddDemoAppDelegate *dele = (ddDemoAppDelegate*)[UIApplication sharedApplication].delegate;
    //    UIWindow *topWindow = dele.window;    
    UIWindow *topWindow = [UIApplication sharedApplication].keyWindow;
    
    //设定位置
    CGRect mframe = [UIScreen mainScreen].bounds;
    CGRect sframe = CGRectMake(0, 0, mframe.size.width, mframe.size.height);
    if(!CGRectEqualToRect(limitRect, CGRectZero))
    {
        sframe = limitRect;
    }
    
    //创建并呼叫浮层
    self.slipPage = [[[DDMoveShowView alloc] initWithFrame:sframe contentPosition:position contentSize:aview.frame.size] autorelease];
    _slipPage.contentView = aview;
    _slipPage.sizeLocked = NO;
    _slipPage.lockBlank = lockBlank;
    _slipPage.delegate = self;
    _slipPage.panEnabled = !lockPan;
    
    //如果限制区域是0，那么就不用黑色背景，否则就使用黑色背景
    if(CGRectEqualToRect(limitRect, CGRectZero))
    {
        _slipPage.useBackGround = NO;
    }
    else
    {
        _slipPage.useBackGround = YES;
    }
    
    [_slipPage callInView:topWindow];
    
}
- (void)callSlideLayerWithView:(UIView*)aview position:(ContentPosition)position lockBlank:(BOOL)lock onTarget:(id)target closedAction:(SEL)action
{
    [self callSlideLayerWithView:aview position:position limitRect:CGRectZero lockBlank:lock lockPan:NO onTarget:target closedAction:action];
}
- (void)callSlideLayerWithView:(UIView*)aview position:(ContentPosition)position lockBlank:(BOOL)lock
{
    [self callSlideLayerWithView:aview position:position lockBlank:lock onTarget:nil closedAction:nil];
}
- (void)callSlideLayerWithView:(UIView*)aview position:(ContentPosition)position
{
    [self callSlideLayerWithView:aview position:position lockBlank:NO onTarget:nil closedAction:nil];
}


//viewcontroller相关的
- (void)callSlideLayerWithViewCtrlor:(UIViewController*)actrlor position:(ContentPosition)position limitRect:(CGRect)limitRect lockBlank:(BOOL)lockBlank lockPan:(BOOL)lockPan onTarget:(id)target closedAction:(SEL)action
{
    if(!actrlor) return;
    
    //创建nav
    UINavigationController *sNav = [[UINavigationController alloc] initWithRootViewController:actrlor];
    sNav.navigationBarHidden = YES;
    sNav.view.frame = actrlor.view.frame;
    self.slipNav = sNav;
    [sNav release];
    
    //创建并呼叫浮层
    [self callSlideLayerWithView:_slipNav.view position:position limitRect:limitRect lockBlank:lockBlank lockPan:lockPan onTarget:target closedAction:action];
}
- (void)callSlideLayerWithViewCtrlor:(UIViewController*)actrlor position:(ContentPosition)position lockBlank:(BOOL)lock onTarget:(id)target closedAction:(SEL)action
{
    [self callSlideLayerWithViewCtrlor:actrlor position:position limitRect:CGRectZero lockBlank:lock lockPan:NO onTarget:target closedAction:action];
}
- (void)callSlideLayerWithViewCtrlor:(UIViewController*)actrlor position:(ContentPosition)position lockBlank:(BOOL)lock
{
    [self callSlideLayerWithViewCtrlor:actrlor position:position lockBlank:lock onTarget:nil closedAction:nil];
}
- (void)callSlideLayerWithViewCtrlor:(UIViewController*)actrlor position:(ContentPosition)position
{
    [self callSlideLayerWithViewCtrlor:actrlor position:position lockBlank:NO onTarget:nil closedAction:nil];
}



//不限定内部浮层类型
- (void)callSlideLayerWithObject:(id)object 
                        position:(ContentPosition)position 
                       limitRect:(CGRect)limitRect 
                       lockBlank:(BOOL)lockBlank 
                         lockPan:(BOOL)lockPan
                      completion:(void (^)(void))completion
{
    if(!object) return;
    if(![object isKindOfClass:[UIView class]] && ![object isKindOfClass:[UIViewController class]]) return;
    
    self.closeCompletionBlock = completion;
    
    if([object isKindOfClass:[UIView class]])
    {
        [self callSlideLayerWithView:object position:position limitRect:limitRect lockBlank:lockBlank lockPan:lockPan onTarget:nil closedAction:nil];
    }
    else if([object isKindOfClass:[UIViewController class]])
    {
        [self callSlideLayerWithViewCtrlor:object position:position limitRect:limitRect lockBlank:lockBlank lockPan:lockPan onTarget:nil closedAction:nil];
    }
}



//关闭浮层
- (void)closeSlideLayer
{
    if(_slipPage)
    {
        [_slipPage close];
    }
}
- (void)closeSlideLayer:(void (^)(void))completion
{
    self.closeCompletionBlock = completion;
    
    if(_slipPage)
    {
        [_slipPage close];
    }
}




#pragma mark -
#pragma mark delegate functions
//DDMoveShowDelegate
- (void)ddMoveShowViewWillClose:(DDMoveShowView*)moveShowView
{
    [[DDEffectView sharedView] closeEffectWithin:0.25];
}
- (void)ddMoveShowViewDidClose:(DDMoveShowView*)moveShowView
{
    if(_slipPage)
    {
        _slipPage.delegate = nil;
        [_slipPage release];
        _slipPage = nil;
    }
    if(_slipNav)
    {
        [_slipNav release];
        _slipNav = nil;
    }
    
    [[DDEffectView sharedView] closeEffectWithin:0.0];
    
    //如果有block，就返回block
    if(_closeCompletionBlock)
    {
        _closeCompletionBlock();
        Block_release(_closeCompletionBlock);
        _closeCompletionBlock = nil;
    }
    
    //返回给target浮层关闭事件
    if(_target && [_target respondsToSelector:_closedAction])
    {
        [_target performSelector:_closedAction];
    }
}
- (void)ddMoveShowViewChangeShowPercent:(DDMoveShowView*)moveShowView percent:(float)percent
{
    [[DDEffectView sharedView] fixEffectByPercent:percent];
}


@end
