//
//  MyQRCodeVC.m
//  TestNCEDeom
//
//  Created by radar on 2018/3/26.
//  Copyright © 2018年 Radar. All rights reserved.
//

#import "MyQRCodeVC.h"

@interface MyQRCodeVC ()

@property (nonatomic, copy)   NSDictionary *myInfoDic; //自己的个人信息

@end



@implementation MyQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = DDCOLOR_BACK_GROUND;
    self.navigationItem.title = @"我的二维码";
    
    //获取我的信息
    self.myInfoDic = [[DataCenter sharedCenter] myInfoOnItem:nil];
    if(!_myInfoDic)
    {
        self.myInfoDic = [[NSDictionary alloc] init];
    }
    
    
}


@end
