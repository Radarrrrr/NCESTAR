//
//  MsgInputView.m
//  Home
//
//  Created by Radar on 2017/4/27.
//  Copyright © 2017年 Radar. All rights reserved.
//


#define MsgInputView_container_height       400
#define MsgInputView_animation_duration     0.25


#import "MsgInputView.h"


@interface MsgInputView ()

@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *containerView;

@end


@implementation MsgInputView


+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MsgInputView *instance;
    dispatch_once(&onceToken, ^{
        instance = [[MsgInputView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, SCR_HEIGHT)];
    });
    return instance;
}


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        self.backgroundColor = [UIColor clearColor];//DDCOLOR_BLUE_GRAY_BACK_GROUND;
        
    
        //添加背景遮罩
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0.0;
        [self addSubview:_backView];
        
        //添加点击事件
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction:)];
        [_backView addGestureRecognizer:tapGesture];
        
        
        //添加输入内容浮层
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCR_HEIGHT, SCR_WIDTH, MsgInputView_container_height)];
        _containerView.backgroundColor = DDCOLOR_BLUE_GRAY_BACK_GROUND;
        [DDFunction addRadiusToView:_containerView radius:6];
        [self addSubview:_containerView];
        
        
        
        //添加输入框和其他组件
        self.inputField = [[UITextField alloc] initWithFrame:CGRectMake(8, 12, frame.size.width-16, 38)]; 
        _inputField.backgroundColor = DDCOLOR_BLUE;
        _inputField.borderStyle = UITextBorderStyleRoundedRect;
        _inputField.returnKeyType = UIReturnKeySend;
        [_containerView addSubview:_inputField];
        
        //添加拉动条
        UIView *dragLine = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_containerView.frame)-40)/2, 4, 40, 4)];
        dragLine.backgroundColor = RGBS(190);
        [DDFunction addRadiusToView:dragLine radius:2];
        [_containerView addSubview:dragLine];
        
        
    }
    return self;
}


- (void)callMsgInputView:(void (^)(void))completion
{
    UIWindow *topWindow = [UIApplication sharedApplication].keyWindow;
    if(![self superview])
    {
        [topWindow addSubview:self];
    }
    
    [UIView animateWithDuration:MsgInputView_animation_duration animations:^{
        
        _backView.alpha = 0.5;
        
        CGRect cframe = _containerView.frame;
        cframe.origin.y = SCR_HEIGHT-MsgInputView_container_height;
        _containerView.frame = cframe;
        
        [_inputField becomeFirstResponder];
        
    } completion:^(BOOL finished) {
        
    }];
    
    
}

- (void)closeAction:(id)sender
{
    [UIView animateWithDuration:MsgInputView_animation_duration animations:^{
        
        _backView.alpha = 0.0;
        
        CGRect cframe = _containerView.frame;
        cframe.origin.y = SCR_HEIGHT;
        _containerView.frame = cframe;
        
        [_inputField resignFirstResponder];
        
    } completion:^(BOOL finished) {
        
        if([self superview])
        {
            [self removeFromSuperview];
        }
    }];
}




//#pragma mark -
//#pragma mark touches functions
//- (void) touchesCanceled 
//{
//}
//- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event 
//{
//}
//- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event 
//{
//}
//- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event 
//{
//    NSSet *allTouches = [event allTouches];
//    
//    switch ([allTouches count]) {
//        case 1: 
//        {
//            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
//            CGPoint tapPoint = [touch locationInView:self];
//            
//            switch (touch.tapCount) 
//            {
//                case 1: 
//                {		
//
//                        BOOL bIn = CGRectContainsPoint(_canvasShowRect, tapPoint);
//                        if(!bIn)
//                        {
//                            //发送消息通知，本类关闭
//                            [[NSNotificationCenter defaultCenter] postNotificationName:lib_notification_DDMoveShowView_need_close object:nil userInfo:nil];
//                            
//                            //关闭本类
//                            [self close];
//                        }
//                    
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
//            break;
//        default:
//            break;
//    }
//}





@end
