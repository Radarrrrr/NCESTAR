//
//  HomeViewController.m
//  Home
//
//  Created by Radar on 2017/1/18.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import "HomeViewController.h"



@interface HomeViewController ()

@property (nonatomic, copy) NSMutableArray *messageArray; //所有的消息数据

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"HOME";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //右上角添加写推送按钮
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMsgAction:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    
    //TO DO: 添加聊天列表
    //DDTableView *
    
    //TO DO: 添加右侧滑动条操作键盘

    
    //TO DO: 添加好友菜单
    
    
}


- (void)addMsgAction:(id)sender
{
    RDPushSimuVC *simuVC = [[RDPushSimuVC alloc] init];
    [self.navigationController pushViewController:simuVC animated:YES];
    
}

@end
