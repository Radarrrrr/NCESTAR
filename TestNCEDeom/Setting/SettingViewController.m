//
//  SettingViewController.m
//  TestNCEDeom
//
//  Created by radar on 2018/3/25.
//  Copyright © 2018年 Radar. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@property (nonatomic, copy) NSDictionary *myInfoDic; //自己的个人信息
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = DDCOLOR_BACK_GROUND;
    
    self.myInfoDic = [[DataCenter sharedCenter] myInfoOnItem:nil];
    
    if(DICTIONARYVALID(_myInfoDic))
    {
        self.navigationItem.title = [_myInfoDic objectForKey:@"nick_name"];
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    SettingViewController *nextVC = [[SettingViewController alloc] init];
//    [self.navigationController pushViewController:nextVC animated:YES];
}



@end
