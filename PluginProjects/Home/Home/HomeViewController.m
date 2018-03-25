//
//  HomeViewController.m
//  Home
//
//  Created by Radar on 2017/1/18.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import "HomeViewController.h"
#import "MessageCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MsgInputView.h"


#define write_button_width 60


@interface HomeViewController () <DDTableViewDelegate, RDConnectDotsDelegate>

//PS: 目前本类并不保存列表数据，所有数据都只是第一次从DataCenter同步过来以后做一次刷新工作，新消息插入以后，直接插入到列表里边，并不插入到这个列表数据数组里边
@property (nonatomic, strong)   NSMutableArray *messageArray; //所有的消息数据 //[{"notifyid":"xxx", "receivetime":"xxxx", "payload":{xxxxxx}}, {"notifyid":"xxx", "receivetime":"xxxx", "payload":{xxxxxx}}, ...]
@property (nonatomic, strong)   DDTableView *listTable;
@property (nonatomic, strong)   UIImageView *backImgView; //背景图片层
@property (nonatomic, strong)   UIButton *writeBtn;
@property (nonatomic, strong)   UIView *statusDot;  //写消息按钮上的状态小点

@property (nonatomic, strong)   UIView *stateView; //发送状态条
@property (nonatomic, strong)   UIView *sbackV;     //发送状体条背景
@property (nonatomic, strong)   UILabel *stateLabel;//发送状态文字

@property (nonatomic, strong)   UIButton *myfaceBtn;    //我的头像
@property (nonatomic, strong)   UIButton *tofaceBtn;    //发送的好友头像
@property (nonatomic, strong)   UILabel *toNameLabel;   //发送的好友名称

@property (nonatomic, strong)   NSString *pushToUserID; //发送的好友的user_id

@property (nonatomic, strong)   RDConnectDots *connectStatusDots; //连接状态小点


@end



static BOOL bFirstTriggerWaiting = YES;  //第一次触发连接状态waiting
static BOOL needTriggerWating = NO;      //需要触发连接状态waiting 给appdelegate触发连接状态等待专用


@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.navigationItem.title = @"HOME";
    self.view.backgroundColor = DDCOLOR_BACK_GROUND;
    self.messageArray = [[NSMutableArray alloc] init];
    
    //直接决定发送用户的user_id了
    [self determinePushToUserID];
    

    //添加背景图片层
    self.backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, SCR_HEIGHT-64)];
    _backImgView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_backImgView];
    
    UIImage *backImg = [UIImage imageNamed:@"img_back.jpg"];
    UIImage *effectImg = [backImg applyLightEffect];
    _backImgView.image = effectImg;
    
    
    //左上角添加自己头像和好友头像
    UIView *peoplesV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 350, 44)];
    peoplesV.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *friendItem = [[UIBarButtonItem alloc] initWithCustomView:peoplesV];
    self.navigationItem.leftBarButtonItem = friendItem;
    
    self.myfaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _myfaceBtn.frame = CGRectMake(-6, 7, 30, 30);
    [DDFunction addRadiusToView:_myfaceBtn radius:CGRectGetWidth(_myfaceBtn.frame)/2];
    [_myfaceBtn addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    [peoplesV addSubview:_myfaceBtn];
    [self changeMyInfomation];
    
    self.tofaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _tofaceBtn.frame = CGRectMake(135, 4, 36, 36);
    [DDFunction addRadiusToView:_tofaceBtn radius:CGRectGetWidth(_tofaceBtn.frame)/2];
    [peoplesV addSubview:_tofaceBtn];
    
    self.toNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_tofaceBtn.frame)+4, 12, CGRectGetWidth(peoplesV.frame)-CGRectGetMaxX(_tofaceBtn.frame)-4, 20)];
    _toNameLabel.backgroundColor = [UIColor clearColor];
    _toNameLabel.userInteractionEnabled = NO;
    _toNameLabel.textAlignment = NSTextAlignmentLeft;
    _toNameLabel.font = DDFONT_B(14);
    _toNameLabel.textColor = RGBS(100);
    [peoplesV addSubview:_toNameLabel];
    
    [self changeToUserInfomation];
    
    
    //添加两个头像之间的状态小点
    self.connectStatusDots = [[RDConnectDots alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_myfaceBtn.frame), 0, CGRectGetMinX(_tofaceBtn.frame)-CGRectGetMaxX(_myfaceBtn.frame), CGRectGetHeight(peoplesV.frame))];
    _connectStatusDots.delegate = self;
    _connectStatusDots.diameter = 6;
    _connectStatusDots.space = 4;
    _connectStatusDots.amount = 6;
    _connectStatusDots.duration = 0.2;
    [peoplesV addSubview:_connectStatusDots];
    
    
    
    //右上角添加写推送按钮
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMsgAction:)];
    self.navigationItem.rightBarButtonItem = addItem;

    //添加聊天列表
    self.listTable = [[DDTableView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, SCR_HEIGHT-64)];
    _listTable.delegate = self;
    [self.view addSubview:_listTable];
    
    //设定list属性
    _listTable.backgroundColor = [UIColor clearColor];
    _listTable.tableView.backgroundColor = [UIColor clearColor];             
    _listTable.tableView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    _listTable.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //设定header和footer
    [_listTable setSection:0 headerHeight:0 footerHeight:8];
    
    UIView *fview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, 8)];
    fview.backgroundColor = [UIColor clearColor];
    [_listTable setSection:0 headerView:nil footerView:fview];
    
    
    
    //添加写信息按钮
    self.writeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _writeBtn.frame = CGRectMake(SCR_WIDTH-write_button_width, SCR_HEIGHT-64-write_button_width, write_button_width, write_button_width);
    [_writeBtn setBackgroundImage:[UIImage imageNamed:@"face_star.png" forme:self] forState:UIControlStateNormal];
    [_writeBtn addTarget:self action:@selector(writeMsgAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_writeBtn];
    
    //做状态圆点
    self.statusDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    _statusDot.center = CGPointMake(CGRectGetWidth(_writeBtn.frame)/2, CGRectGetHeight(_writeBtn.frame)/2);
    _statusDot.userInteractionEnabled = NO;
    _statusDot.backgroundColor = [UIColor clearColor];
    [DDFunction addRadiusToView:_statusDot radius:4];
    [_writeBtn addSubview:_statusDot];
        
    
    //TO DO: 添加好友菜单
    
    
    //发送状态条
    float stateWidth = SCR_WIDTH-CGRectGetWidth(_writeBtn.frame)-10-60;
    
    //CGRectMake(60, SCR_HEIGHT-64-35-10, SCR_WIDTH-CGRectGetWidth(_writeBtn.frame)-10-60, 30)
    self.stateView = [[UIView alloc] initWithFrame:CGRectMake(60+stateWidth/2, SCR_HEIGHT-64-write_button_width/2-10-2.5, 25, 25)];
    _stateView.backgroundColor = [UIColor clearColor];
    _stateView.clipsToBounds = YES;
    _stateView.alpha = 0.0;
    [self.view addSubview:_stateView];
    
    self.sbackV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_stateView.frame), CGRectGetHeight(_stateView.frame))];
    _sbackV.backgroundColor = [UIColor blackColor];
    _sbackV.userInteractionEnabled = NO;
    _sbackV.alpha = 0.75;
    [DDFunction addRadiusToView:_sbackV radius:CGRectGetHeight(_sbackV.frame)/2];
    [_stateView addSubview:_sbackV];
    
    self.stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_stateView.frame), CGRectGetHeight(_stateView.frame))];
    _stateLabel.backgroundColor = [UIColor clearColor];
    _stateLabel.userInteractionEnabled = NO;
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    _stateLabel.font = DDFONT(13);
    _stateLabel.textColor = RGBS(200);
    _stateLabel.alpha = 0.0;
    [_stateView addSubview:_stateLabel];
    
    
    
    //延时刷新聊天列表
    [self performSelector:@selector(refreshMsgList) withObject:nil afterDelay:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(bFirstTriggerWaiting)
    {
        bFirstTriggerWaiting = NO;
        
        if(needTriggerWating)
        {
            [_connectStatusDots startWaiting:RDConnectDotsWaitingStateConnecting];
        }
    }
}


- (void)determinePushToUserID
{
    //决定要发送的用户的user_id, 暂时使用固定的userid选择发送人
    NSString *touserid = nil;
    
    NSString *myuserid = [[DataCenter sharedCenter] myInfoOnItem:@"user_id"];
    if(STRVALID(myuserid))
    {
        if([myuserid isEqualToString:@"00000"])
        {
            touserid = @"00001";
        }
        else if([myuserid isEqualToString:@"00001"])
        {
            touserid = @"00000";
        }
    }

    self.pushToUserID = touserid;
}


- (void)settingAction:(id)sender
{
    
}


- (void)addMsgAction:(id)sender
{    
    RDPushSimuVC *simuVC = [[RDPushSimuVC alloc] init];
    [self.navigationController pushViewController:simuVC animated:YES];
}

- (void)writeMsgAction:(id)sender
{
    //弹出输入框
    if(!STRVALID(_pushToUserID)) return;
    
    NSDictionary *toUserInfo = [[DataCenter sharedCenter] userInfoForId:_pushToUserID onitem:nil];    
    
    [[MsgInputView sharedInstance] callMsgInputToUser:toUserInfo pushReport:^(PTPushReport *report) {
        
        switch (report.status) {
            case PTPushReportStatusConnecting:
            {
                _statusDot.backgroundColor = [UIColor grayColor];  //正在连接 灰色
                [_writeBtn startSpining];
                [_statusDot startFlash];
                [_connectStatusDots startWaiting:RDConnectDotsWaitingStateConnecting];
                
                //状态
                _stateLabel.text = @"正在连接发送服务";
                [self showStateView];
            }
                break;
            case PTPushReportStatusConnectFailure:
            {
                _statusDot.backgroundColor = [UIColor lightGrayColor];  //连接失败 浅灰色
                [_writeBtn stopSpining];
                [_statusDot stopFlash];
                [_connectStatusDots stopWaitingForState:RDConnectDotsFinishStateConnectFailure];
                
                //状态
                _stateLabel.text = @"无法与服务器建立连接";
            }
                break;
            case PTPushReportStatusPushing:
            {
                _statusDot.backgroundColor = DDCOLOR_ORANGE;    //正在发送 橘色
                [_writeBtn startSpining];
                [_statusDot startFlash];
                [_connectStatusDots startWaiting:RDConnectDotsWaitingStateSending];
                
                //状态
                _stateLabel.text = @"正在发送消息";
                [self showStateView];
            }
                break;
            case PTPushReportStatusPushSuccess:
            {
                _statusDot.backgroundColor = DDCOLOR_BLUE;     //发送成功 蓝色
                [_writeBtn stopSpining];
                [_statusDot stopFlash];
                [_connectStatusDots stopWaitingForState:RDConnectDotsFinishStateSendSuccess];
                
                //状态
                _stateLabel.text = @"发送成功!";
                [self performSelector:@selector(hideStateView) withObject:nil afterDelay:2];
                
                
                //插入列表数据
                //获取这条新消息的消息token
                NSString *notifytoken = [DDFunction getValueForKey:@"notifytoken" inData:report.payload];
                if(STRVALID(notifytoken))
                {
                    //去DataCenter里边获取到该条消息的data
                    NSDictionary *notiDic = [[DataCenter sharedCenter] getNotiDataForNotifyToken:notifytoken];
                    
                    //根据获取到的消息数据，做增加消息的列表
                    [self insertMessage:notiDic];
                }
            }
                break;
            case PTPushReportStatusPushFailure:
            {
                _statusDot.backgroundColor = DDCOLOR_RED;       //发送失败 红色
                [_writeBtn stopSpining];
                [_statusDot stopFlash];
                [_connectStatusDots stopWaitingForState:RDConnectDotsFinishStateSendFailure];
            }
                break;
            default:
                break;
        }
        
        
    } completion:^{
        NSLog(@"输入浮层关闭");
    }];

}


- (void)syncAllMessagesFromDataCenter
{
    //从数据中心获取所有的消息，并做一下倒序转换，把最新的放在第一个
    NSMutableArray *allMsgs = [[DataCenter sharedCenter] getAllMessages];
    if(!ARRAYVALID(allMsgs)) return;
    
    NSArray* reversedArray = [[allMsgs reverseObjectEnumerator] allObjects];
    
    if([_messageArray count] != 0) 
    {
        [_messageArray removeAllObjects];
    }
    [_messageArray addObjectsFromArray:reversedArray];
}

- (void)refreshMsgList //刷新聊天列表
{
    //在做页面渲染前，获取一下数据源列表
    [self syncAllMessagesFromDataCenter];
    
    //刷新列表
    [_listTable clearDatas];
    [_listTable appendDataArray:_messageArray useCell:@"MessageCell" toSection:0];
    [_listTable refreshTable];
}

- (void)insertMessage:(NSDictionary*)msgData
{
    if(!DICTIONARYVALID(msgData)) return;
    
    //滚动到最顶
    [self moveListPositionToTop];
    
    //插入一条信息到第一个位置
    NSIndexPath *indexPath = [DDTableView indexPathWithSection:0 row:0];
    [_listTable insertData:msgData useCell:@"MessageCell" toIndexPath:indexPath];
    [_listTable refreshTableWithAnimation:UITableViewRowAnimationTop];
    
    //让插入的信息闪动一下
    MessageCell *insertCell = [_listTable.tableView cellForRowAtIndexPath:indexPath];
    [insertCell flashCell];
    
}

- (void)moveListPositionToTop
{
    //滚动到最顶
    [_listTable.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
}
- (void)flashFirstMessage
{
    //让第一条信息闪动一下
    NSIndexPath *indexPath = [DDTableView indexPathWithSection:0 row:0];
    MessageCell *insertCell = [_listTable.tableView cellForRowAtIndexPath:indexPath];
    [insertCell flashCell];
}



//DDTableViewDelegate
- (void)DDTableViewDidSelectIndexPath:(NSIndexPath*)indexPath withData:(id)data ontable:(DDTableView*)table
{
    
}

- (void)DDTableViewDidScroll:(DDTableView*)table
{
    
}


//RDConnectDotsDelegate
- (void)didTapActionFromConnectDots:(RDConnectDots*)connectDots
{
    //返回点击事件,手动重新连接
    //[DDRouter actionForLinkURL:@"connectapns://disconnectneed=1"];
}





#pragma mark - 状态条相关
static BOOL stateViewShowing = NO;

- (void)showStateView
{
    if(stateViewShowing) return;
    stateViewShowing = YES;
    
    CGRect sframe = _stateView.frame;
    CGRect bframe = _sbackV.frame;
    CGRect lframe = _stateLabel.frame;
    
    float swidth = SCR_WIDTH-CGRectGetWidth(_writeBtn.frame)-10-60;
    
    bframe.size.width = swidth;
    lframe.size.width = swidth;
    
    sframe.origin.x = 60;
    sframe.size.width = swidth;
    

    [UIView animateWithDuration:0.1 animations:^{
        
        _stateView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25 animations:^{
            
            _stateView.frame = sframe;
            _sbackV.frame = bframe;
            _stateLabel.frame = lframe;
            _stateLabel.alpha = 1.0;
            
        }]; 
    }];

}

- (void)hideStateView
{
    if(!stateViewShowing) return;
    stateViewShowing = NO;
    
    
    CGRect sframe = _stateView.frame;
    CGRect bframe = _sbackV.frame;
    CGRect lframe = _stateLabel.frame;
    
    float swidth = SCR_WIDTH-CGRectGetWidth(_writeBtn.frame)-10-60;
    
    bframe.size.width = 30;
    lframe.size.width = 30;
    
    sframe.origin.x = 60+swidth/2;
    sframe.size.width = 30;
    
    _stateLabel.alpha = 0.0;

    [UIView animateWithDuration:0.25 animations:^{
        
        _stateView.frame = sframe;
        _sbackV.frame = bframe;
        _stateLabel.frame = lframe;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            _stateView.alpha = 0.0;
            
        }];
    }];

}


#pragma mark - 修改导航条头像
- (UIImage*)faceImageForUserId:(NSString*)userid
{
    NSString *faceid = @"star";
    
    if(STRVALID(userid)) 
    {
        NSString *ufaceid = [[DataCenter sharedCenter] userInfoForId:userid onitem:@"face_id"];
        if(STRVALID(ufaceid)) 
        {
            faceid = ufaceid;
        }
    }
    
    NSString *facepicN = [NSString stringWithFormat:@"face_%@.png", faceid];
    return [UIImage imageNamed:facepicN forme:self];
}

- (void)changeMyInfomation
{
    //改变自己信息
    NSString *myuserid = [[DataCenter sharedCenter] myInfoOnItem:@"user_id"];
    
    UIImage *faceImg = [self faceImageForUserId:myuserid];
    [_myfaceBtn setBackgroundImage:faceImg forState:UIControlStateNormal];
}
- (void)changeToUserInfomation
{
    //改变发送对象信息    
    UIImage *faceImg = [self faceImageForUserId:_pushToUserID];
    [_tofaceBtn setBackgroundImage:faceImg forState:UIControlStateNormal];
    
    NSString *nick = [[DataCenter sharedCenter] userInfoForId:_pushToUserID onitem:@"nick_name"];
    _toNameLabel.text = nick;
}

- (void)changeConnectStatus:(NSInteger)status
{
    switch (status) {
        case PTConnectReportStatusConnecting:
        {
            needTriggerWating = YES;
            [_connectStatusDots startWaiting:RDConnectDotsWaitingStateConnecting];
        }
            break;
        case PTConnectReportStatusConnectSuccess:
        {
            needTriggerWating = NO;
            [_connectStatusDots stopWaitingForState:RDConnectDotsFinishStateConnectSuccess];
        }  
            break;
        case PTConnectReportStatusConnectFailure:
        {
            needTriggerWating = NO;
            [_connectStatusDots stopWaitingForState:RDConnectDotsFinishStateConnectFailure];
        }  
            break;
        default:
            break;
    }
}



@end









