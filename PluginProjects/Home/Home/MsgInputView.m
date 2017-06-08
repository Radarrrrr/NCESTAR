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
#import "MsgFunctionView.h"


@interface MsgInputView () <DDMoveableViewDelegate, UITextFieldDelegate, MsgFunctionViewDelegate>

@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) DDMoveableView *containerView;

@property (nonatomic, copy) NSString *selfToken; //自己的devicetoken
@property (nonatomic, copy) NSString *selfUserId;//自己的userid
@property (nonatomic, copy) NSString *pushToToken; //要发送到的devicetoken

@property (nonatomic, strong) void (^pushReportHandler)(PTPushReport *report);
@property (nonatomic, strong) void (^closeHandler)(void);

@property (nonatomic, strong) MsgFunctionView *functionView; //快捷功能区

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
        
        
        //添加快捷功能区
        self.functionView = [[MsgFunctionView alloc] initWithFrame:CGRectMake(8, CGRectGetMaxY(_inputField.frame)+8, SCR_WIDTH-16, CGRectGetHeight(_containerView.frame)-CGRectGetMaxY(_inputField.frame)-8-8)];
        _functionView.delegate = self;
        [_containerView addSubview:_functionView];
        
    }
    return self;
}

- (void)moveContainerViewToY:(float)toY
{
    CGRect cframe = _containerView.frame;
    cframe.origin.y = toY;
    _containerView.frame = cframe;
}

- (void)callMsgInputToUser:(NSDictionary*)userInfo pushReport:(void(^)(PTPushReport *report))pushReportHandler completion:(void (^)(void))closeHandler
{
    self.pushReportHandler = pushReportHandler;
    self.closeHandler = closeHandler;
    
    if(!DICTIONARYVALID(userInfo)) return;
    
    NSString *toToken = [userInfo objectForKey:@"device_token"];
    if(!STRVALID(toToken)) return;
    self.pushToToken = toToken;
    
    NSString *myToken = [[DataCenter sharedCenter] myInfoOnItem:@"device_token"];
    if(!STRVALID(myToken)) return;
    self.selfToken = myToken;
    
    NSString *myUserId = [[DataCenter sharedCenter] myInfoOnItem:@"user_id"];
    if(!STRVALID(myUserId)) return;
    self.selfUserId = myUserId;
    
    
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
        [self pushMessage:message attach:nil msgtype:MSG_TYPE_MESSAGE];
                
        return YES;
    }
    
    return NO;
}


//MsgFunctionViewDelegate
- (void)msgFunctionViewTargetAction:(MSGFunctionAction)action
{
    //返回选择了那种操作事件
    switch (action) {
        case MSGFunctionActionAttention:
        {
            //收到呼叫提醒
            [self pushMessage:@"求关注" attach:nil msgtype:MSG_TYPE_ATTENTION];
        }
            break;
        default:
            break;
    }
}



#pragma mark - payload及发送相关
- (void)pushMessage:(NSString *)message attach:(NSString *)attach msgtype:(NSString*)msgtype
{
    //发送消息
    NSDictionary *payload = [self assemblePayload:message attach:attach msgtype:msgtype]; //表情可以当作attach发过来
    
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
            [[AudioPlayer sharedAudioPlayer] setAudio:@"msg_send" withType:@"wav" withLoop:NO];
            [[AudioPlayer sharedAudioPlayer] play];
        }
        
        if(_pushReportHandler)
        {
            _pushReportHandler(report);
        }
    }];
    
    [self closeAction:nil];
}

- (NSDictionary *)assemblePayload:(NSString *)message attach:(NSString *)attach msgtype:(NSString*)msgtype//attach就是一个url，无论上传了什么都是一个url
{    
//#define MSG_TYPE_MESSAGE        @"message"      //标准信息
//#define MSG_TYPE_CONFIRM        @"confirm"      //确认信息
//#define MSG_TYPE_ATTENTION      @"attention"    //提醒注意信息
    
    
    if(!STRVALID(message)) message = @"";
    if(!STRVALID(attach)) attach = @"";
    if(!STRVALID(msgtype)) msgtype = MSG_TYPE_MESSAGE;
    
    NSString *sendtime = [DDFunction stringFromDate:[NSDate date] useFormat:@"YY-MM-dd HH:mm:ss"];
    
    //用from_token+to_token+sendtime做MD5,生成验证码
    NSString *ntokenString = [NSString stringWithFormat:@"%@_%@_%@", _selfToken, _pushToToken, sendtime];
    NSString *notifyToken = [DDFunction md5FormString:ntokenString];
    
    
    //根据不同消息类型，设定声音, mutable-content状态等
    NSString *sound = @"default";
    NSString *mutcontent = @"1";
    
    //修改设定
    if([msgtype isEqualToString:MSG_TYPE_MESSAGE])
    {
        sound = @"default";
        mutcontent = @"1";
    }
    else if([msgtype isEqualToString:MSG_TYPE_CONFIRM])
    {
        sound = @"Submarine.aiff";
        mutcontent = @"0";
    }
    else if([msgtype isEqualToString:MSG_TYPE_ATTENTION])
    {
        sound = @"msg_new.mp3";
        mutcontent = @"0";
    }
    
    
    
    //组合payload
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
            @"badge":@1,
            @"sound":sound,
            @"mutable-content":mutcontent,
            @"category":@"myNotificationCategory",
            @"attach":attach,
            @"from_token":_selfToken,
            @"from_userid":_selfUserId,
            @"to_token":_pushToToken
        },
        @"goto_page":@"",
        @"sendtime":sendtime,
        
        @"notifytoken":notifyToken, 
        
        @"msgtype":msgtype,
        @"confirm_notifyid":@""
        
    };

    return payload;
}

- (NSString*)soundForMsgtype:(NSString*)msgtype
{
    //根据消息类型，选择不同的提示声音
    NSString *sound = @"default";
    if(STRVALID(msgtype))
    {
        if([msgtype isEqualToString:MSG_TYPE_MESSAGE])
        {
            sound = @"default";
        }
        else if([msgtype isEqualToString:MSG_TYPE_CONFIRM])
        {
            sound = @"Submarine.aiff";
        }
        else if([msgtype isEqualToString:MSG_TYPE_ATTENTION])
        {
            sound = @"msg_new.mp3";
        }
    }
    
    return sound;
}





@end




