//
//  MsgInputView.m
//  Home
//
//  Created by Radar on 2017/4/27.
//  Copyright © 2017年 Radar. All rights reserved.
//


#define MsgInputView_default_height 400

#import "MsgInputView.h"

@implementation MsgInputView



- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        self.backgroundColor = DDCOLOR_RED;
        
        //TO DO: 添加输入框和其他组件
        
    }
    return self;
}

/*
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


+ (void)callMsgInputView:(void (^)(void))completion
{
    MsgInputView *inputV = [[MsgInputView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, MsgInputView_default_height)];
    
    [[DDSlideLayer sharedLayer] callSlideLayerWithObject:inputV 
                                                position:positionDown 
                                               limitRect:CGRectZero //CGRectMake(0, 64, SCR_WIDTH, SCR_HEIGHT-64) 
                                               lockBlank:NO 
                                                 lockPan:NO 
                                              completion:^{
                                                  
                                                  if(completion)
                                                  {
                                                      completion();
                                                  }
                                                  
                                              }];

}




@end
