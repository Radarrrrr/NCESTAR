//
//  MsgFunctionView.m
//  Home
//
//  Created by Radar on 2017/6/8.
//  Copyright © 2017年 Radar. All rights reserved.
//

#define func_btn_width 80

#import "MsgFunctionView.h"

@interface MsgFunctionView ()

@end


@implementation MsgFunctionView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        self.backgroundColor = [UIColor clearColor];
        
        //添加呼叫按钮
        UIButton *attentionBtn = [UIButton buttonWithColor:DDCOLOR_ORANGE selColor:RGBS(150)];
        attentionBtn.frame = CGRectMake(0, 0, func_btn_width, func_btn_width);
        attentionBtn.center = CGPointMake(frame.size.width/2, frame.size.height-func_btn_width/2-70);
        [attentionBtn setTitle:@"呼叫" forState:UIControlStateNormal];
        attentionBtn.titleLabel.textColor = DDCOLOR_TEXT_A;
        attentionBtn.titleLabel.font = DDFONT_B(14);
        [DDFunction addRadiusToView:attentionBtn radius:func_btn_width/2];
        [attentionBtn addTarget:self action:@selector(functionAction:) forControlEvents:UIControlEventTouchUpInside];
        attentionBtn.tag = MSGFunctionActionAttention;
        [self addSubview:attentionBtn];
        
    }
    return self;
}

- (void)functionAction:(UIButton*)btn
{
    //返回上层，在功能区点击的操作事件
    if(_delegate && [_delegate respondsToSelector:@selector(msgFunctionViewTargetAction:)])
    {
        [_delegate msgFunctionViewTargetAction:btn.tag];
    }
}



@end








