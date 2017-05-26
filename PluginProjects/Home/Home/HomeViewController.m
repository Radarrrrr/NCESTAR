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



@interface HomeViewController () <DDTableViewDelegate>

//PS: 目前本类并不保存列表数据，所有数据都只是第一次从DataCenter同步过来以后做一次刷新工作，新消息插入以后，直接插入到列表里边，并不插入到这个列表数据数组里边
@property (nonatomic, strong)   NSMutableArray *messageArray; //所有的消息数据 //[{"notifyid":"xxx", "receivetime":"xxxx", "payload":{xxxxxx}}, {"notifyid":"xxx", "receivetime":"xxxx", "payload":{xxxxxx}}, ...]
@property (nonatomic, strong)   DDTableView *listTable;
@property (nonatomic, strong)   UIImageView *backImgView; //背景图片层
@property (nonatomic, strong)   UIButton *writeBtn;
@property (nonatomic, strong)   UIView *statusDot;

@end


@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"HOME";
    self.view.backgroundColor = DDCOLOR_BACK_GROUND;
    self.messageArray = [[NSMutableArray alloc] init];
    
    //添加背景图片层
    self.backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, SCR_HEIGHT-64)];
    _backImgView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_backImgView];
    
    UIImage *backImg = [UIImage imageNamed:@"img_back.jpg"];
    UIImage *effectImg = [backImg applyLightEffect];
    _backImgView.image = effectImg;
    
    
    //右上角添加写推送按钮
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMsgAction:)];
    self.navigationItem.rightBarButtonItem = addItem;

    //TO DO: 添加聊天列表
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
    _writeBtn.frame = CGRectMake(SCR_WIDTH-70, SCR_HEIGHT-64-70, 70, 70);
    [_writeBtn setBackgroundImage:[UIImage imageNamed:@"face_star.png" forUser:self] forState:UIControlStateNormal];
    [_writeBtn addTarget:self action:@selector(writeMsgAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_writeBtn];
    
    //做状态圆点
    self.statusDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _statusDot.center = CGPointMake(CGRectGetWidth(_writeBtn.frame)/2, CGRectGetHeight(_writeBtn.frame)/2);
    _statusDot.userInteractionEnabled = NO;
    _statusDot.backgroundColor = [UIColor clearColor];
    [DDFunction addRadiusToView:_statusDot radius:5];
    [_writeBtn addSubview:_statusDot];
    

    //TO DO: 添加右侧滑动条操作键盘
    
    
    //TO DO: 添加好友菜单
    
    
    //延时刷新聊天列表
    [self performSelector:@selector(refreshMsgList) withObject:nil afterDelay:0];
}

- (void)viewDidAppear:(BOOL)animated
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
    
    //TO DO: 暂时先发给自己
    NSString *toToken = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_SELF_DEVICE_TOKEN];
        
    [[MsgInputView sharedInstance] callMsgInputToToken:toToken pushReport:^(PTPushReport *report) {
        
        
        switch (report.status) {
            case PTPushReportStatusConnecting:
            {
                _statusDot.backgroundColor = [UIColor grayColor];  //正在连接 灰色
                [_writeBtn startSpining];
            }
                break;
            case PTPushReportStatusConnectFailure:
            {
                _statusDot.backgroundColor = [UIColor lightGrayColor];  //连接失败 浅灰色
                [_writeBtn stopSpining];
            }
                break;
            case PTPushReportStatusPushing:
            {
                _statusDot.backgroundColor = DDCOLOR_ORANGE;    //正在发送 橘色
                [_writeBtn startSpining];
            }
                break;
            case PTPushReportStatusPushSuccess:
            {
                _statusDot.backgroundColor = DDCOLOR_BLUE;     //发送成功 蓝色
                [_writeBtn stopSpining];
            }
                break;
            case PTPushReportStatusPushFailure:
            {
                _statusDot.backgroundColor = DDCOLOR_RED;       //发送失败 红色
                [_writeBtn stopSpining];
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
    
    //插入一条信息到第一个位置
    NSIndexPath *indexPath = [DDTableView indexPathWithSection:0 row:0];
    [_listTable insertData:msgData useCell:@"MessageCell" toIndexPath:indexPath];
    [_listTable refreshTableWithAnimation:UITableViewRowAnimationTop];
    
    //让插入的信息闪动一下
    MessageCell *insertCell = [_listTable.tableView cellForRowAtIndexPath:indexPath];
    [insertCell flashCell];
    
    //改变第二个cell的状态
//    NSIndexPath *secondIndex = [DDTableView indexPathWithSection:0 row:1];
//    MessageCell *secondCell = [_listTable.tableView cellForRowAtIndexPath:secondIndex];
//    [secondCell recoverState];
}





//DDTableViewDelegate
- (void)DDTableViewDidSelectIndexPath:(NSIndexPath*)indexPath withData:(id)data ontable:(DDTableView*)table
{
    
}

- (void)DDTableViewDidScroll:(DDTableView*)table
{
    
}




@end









