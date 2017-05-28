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


@interface MsgInputView () <DDMoveableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) DDMoveableView *containerView;

@property (nonatomic, copy) NSString *selfToken; //自己的devicetoken
@property (nonatomic, copy) NSString *pushToToken; //要发送到的devicetoken

@property (nonatomic, strong) void (^pushReportHandler)(PTPushReport *report);
@property (nonatomic, strong) void (^closeHandler)(void);

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
        _inputField.delegate = self;
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

- (void)callMsgInputToToken:(NSString*)toToken pushReport:(void(^)(PTPushReport *report))pushReportHandler completion:(void (^)(void))closeHandler
{
    self.pushReportHandler = pushReportHandler;
    self.closeHandler = closeHandler;
    
    if(!STRVALID(toToken)) return;
    self.pushToToken = toToken;
    
    NSString *myToken = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_SELF_DEVICE_TOKEN];
    if(!STRVALID(myToken)) return;
    self.selfToken = myToken;
    
    
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
        
        if(_closeHandler)
        {
            _closeHandler();
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


//UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text && ![textField.text isEqualToString:@""])
    {
        NSString *message = textField.text;
        NSDictionary *payload = [self assemblePayload:message attach:nil]; //表情可以当作attach发过来
    
        [[RDPushTool sharedTool] pushPayload:payload toToken:_pushToToken completion:^(PTPushReport *report) {
            
            if(report.status == PTPushReportStatusPushSuccess)
            {
                _inputField.text = nil;
                
                //存储发送成功的消息字典 {"notifyid":"xxx", "receivetime":"xxxx", "payload":{xxxxxx}}
                NSMutableDictionary *notiDic = [[NSMutableDictionary alloc] init];
                [notiDic setObject:@"" forKey:@"notifyid"];
                [notiDic setObject:@"" forKey:@"receivetime"];
                [notiDic setObject:report.payload forKey:@"payload"];
                
                [[DataCenter sharedCenter] appendNotifyData:notiDic];
                
                //发送成功声音
                [[AudioPlayer sharedAudioPlayer] setAudio:@"msg_sendout" withType:@"wav" withLoop:NO];
                [[AudioPlayer sharedAudioPlayer] play];
            }
            
            if(_pushReportHandler)
            {
                _pushReportHandler(report);
            }
        }];
        
        [self closeAction:nil];
        
        
        return YES;
    }
    
    return NO;
}



#pragma mark - payload相关
- (NSDictionary *)assemblePayload:(NSString *)message attach:(NSString *)attach //attach就是一个url，无论上传了什么都是一个url
{    
    if(!STRVALID(message)) message = @"";
    if(!STRVALID(attach)) attach = @"";
    
    NSString *sendtime = [DDFunction stringFromDate:[NSDate date] useFormat:@"YY-MM-dd HH:mm:ss"];
    
    //用from_token+to_token+sendtime做MD5,生成验证码
    NSString *ntokenString = [NSString stringWithFormat:@"%@_%@_%@", _selfToken, _pushToToken, sendtime];
    NSString *notifyToken = [DDFunction md5FormString:ntokenString];
    
    NSDictionary *payload = 
    @{
        @"aps":
        @{
            @"alert":
            @{
                @"title":@"",
                @"subtitle":@"",
                @"body":message
            },
            @"badge":@"1",
            @"sound":@"msg_new.mp3",
            @"mutable-content":@"1",
            @"category":@"myNotificationCategory",
            @"attach":attach,
            @"from_token":_selfToken,
            @"to_token":_pushToToken
        },
        @"goto_page":@"",
        @"sendtime":sendtime,
        
        @"notifytoken":notifyToken, 
        
        @"msgtype":@"message",
        @"confirm_notifyid":@""
        
    };

    return payload;
}




@end
