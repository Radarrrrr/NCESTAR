//
//  HomeViewController.m
//  Home
//
//  Created by Radar on 2017/1/18.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import "HomeViewController.h"


@interface HomeViewController () <DDTableViewDelegate>

@property (nonatomic, copy)     NSMutableArray *messageArray; //所有的消息数据 //[{"notifyid":"xxx", "receivetime":"xxxx", "payload":{xxxxxx}}, {"notifyid":"xxx", "receivetime":"xxxx", "payload":{xxxxxx}}, ...]
@property (nonatomic, strong)   DDTableView *listTable;
@property (nonatomic, strong)   UIImageView *backImgView; //背景图片层

@end


@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"HOME";
    self.view.backgroundColor = DDCOLOR_BACK_GROUND;
    
    //添加背景图片层
    self.backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, SCR_HEIGHT-64)];
    _backImgView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_backImgView];
    
    UIImage *backImg = [UIImage imageNamed:@"img_back.jpg"];
    UIImage *effectImg = [backImg applyLightEffect];
    _backImgView.image = effectImg;
    
    
    
    //在做页面渲染前，获取一下数据源列表
    [self syncAllMessagesFromDataCenter];
    
    //右上角添加写推送按钮
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMsgAction:)];
    self.navigationItem.rightBarButtonItem = addItem;

    //TO DO: 添加聊天列表
    self.listTable = [[DDTableView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, SCR_HEIGHT-64)];
    _listTable.delegate = self;
//    _listTable.loadMoreStyle = LoadMoreStyleAuto;
//    _listTable.refreshStyle = RefreshStyleDrag;
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
    

    //TO DO: 添加右侧滑动条操作键盘
    
    
    //TO DO: 添加好友菜单
    
    
    //延时刷新聊天列表
    [self performSelector:@selector(refreshMsgList) withObject:nil afterDelay:0];
}

- (void)viewDidAppear:(BOOL)animated
{
//    CGRect frame = self.view.frame;
//    int i=0;
}

- (void)addMsgAction:(id)sender
{
    RDPushSimuVC *simuVC = [[RDPushSimuVC alloc] init];
    [self.navigationController pushViewController:simuVC animated:YES];
}

- (void)syncAllMessagesFromDataCenter
{
    //从数据中心获取所有的消息，并做一下倒序转换，把最新的放在第一个
    NSMutableArray *allMsgs = [[DataCenter sharedCenter] getAllMessages];
    if(!ARRAYVALID(allMsgs)) return;
    
    NSArray* reversedArray = [[allMsgs reverseObjectEnumerator] allObjects];
    self.messageArray = [NSMutableArray arrayWithArray:reversedArray];
}

- (void)refreshMsgList //刷新聊天列表
{
    //准备数据源
    
    
    //刷新列表
    [_listTable appendDataArray:_messageArray useCell:@"MessageCell" toSection:0];
    [_listTable refreshTable];
}


//DDTableViewDelegate
- (void)DDTableViewDidSelectIndexPath:(NSIndexPath*)indexPath withData:(id)data ontable:(DDTableView*)table
{
    
}




@end









