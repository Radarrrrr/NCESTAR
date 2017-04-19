//
//  HomeViewController.m
//  Home
//
//  Created by Radar on 2017/1/18.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import "HomeViewController.h"


@interface HomeViewController () <DDTableViewDelegate>

@property (nonatomic, copy)     NSMutableArray *messageArray; //所有的消息数据
@property (nonatomic, strong)   DDTableView *listTable;

@end


@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"HOME";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //在做页面渲染前，获取一下数据源列表
    self.messageArray = [[DataCenter sharedCenter] getAllMessages];
    
    //右上角添加写推送按钮
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMsgAction:)];
    self.navigationItem.rightBarButtonItem = addItem;

    //TO DO: 添加聊天列表
    self.listTable = [[DDTableView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, SCR_HEIGHT-64)];
    _listTable.delegate = self;
    _listTable.loadMoreStyle = LoadMoreStyleAuto;
    _listTable.refreshStyle = RefreshStyleDrag;
    _listTable.tableView.backgroundColor = [UIColor redColor];
    _listTable.tableView.separatorColor = [UIColor redColor];
    [self.view addSubview:_listTable];
    
    //设定list属性
    _listTable.tableView.backgroundColor = [UIColor whiteColor];             
    _listTable.tableView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    _listTable.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTable.tableView.separatorColor = [UIColor redColor];
    
    
    //TO DO: 添加右侧滑动条操作键盘

    
    //TO DO: 添加好友菜单
    
    
}

- (void)addMsgAction:(id)sender
{
    RDPushSimuVC *simuVC = [[RDPushSimuVC alloc] init];
    [self.navigationController pushViewController:simuVC animated:YES];
    
}






@end









