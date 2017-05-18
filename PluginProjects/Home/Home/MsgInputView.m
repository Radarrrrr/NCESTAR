//
//  MsgInputView.m
//  Home
//
//  Created by Radar on 2017/4/27.
//  Copyright © 2017年 Radar. All rights reserved.
//


#define MsgInputView_container_height       400

#define MsgInputView_container_position_down    SCR_HEIGHT - MsgInputView_container_height
#define MsgInputView_container_position_up      MsgInputView_container_position_down - 200


static float inputLastPosition;


#import "MsgInputView.h"


@interface MsgInputView () <DDMoveableViewDelegate>

@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) DDMoveableView *containerView;

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
        self.containerView = [[DDMoveableView alloc] initWithFrame:CGRectMake(0, SCR_HEIGHT, SCR_WIDTH, MsgInputView_container_height)];
        _containerView.backgroundColor = DDCOLOR_BLUE_GRAY_BACK_GROUND;
        _containerView.verticalOnly = YES;
        _containerView.delegate = self;
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

- (void)moveContainerViewToY:(float)toY
{
    CGRect cframe = _containerView.frame;
    cframe.origin.y = toY;
    _containerView.frame = cframe;
}


- (void)callMsgInputView:(void (^)(void))completion
{
    UIWindow *topWindow = [UIApplication sharedApplication].keyWindow;
    if(![self superview])
    {
        [topWindow addSubview:self];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        _backView.alpha = 0.5;
        
        [self moveContainerViewToY:MsgInputView_container_position_down];
        inputLastPosition = MsgInputView_container_position_down;
        
        [_inputField becomeFirstResponder];
        
    } completion:^(BOOL finished) {
        
    }];
    
    
}

- (void)closeAction:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        
        _backView.alpha = 0.0;
        
        [self moveContainerViewToY:SCR_HEIGHT];
        
        [_inputField resignFirstResponder];
        
    } completion:^(BOOL finished) {
        
        if([self superview])
        {
            [self removeFromSuperview];
        }
    }];
}

//DDMoveableViewDelegate
- (void)DDMoveableViewTouchUp:(DDMoveableView*)theView
{
    if(!theView) return;
    
    
    float moveToY;
    
    if(inputLastPosition == MsgInputView_container_position_down)
    {
        if(theView.frame.origin.y < MsgInputView_container_position_down-50)
        {
            //向上打开
            moveToY = MsgInputView_container_position_up;
        }
        else
        {
            //恢复向下关闭
            moveToY = MsgInputView_container_position_down;
        }
    }
    else if(inputLastPosition == MsgInputView_container_position_up)
    {
        if(theView.frame.origin.y < MsgInputView_container_position_up+50)
        {
            //恢复向上打开
            moveToY = MsgInputView_container_position_up;
        }
        else
        {
            //向下关闭
            moveToY = MsgInputView_container_position_down;
        }
    }
    

    [UIView animateWithDuration:0.15 animations:^{
        
        [self moveContainerViewToY:moveToY];
        inputLastPosition = moveToY;
        
    }];
    
}




@end
