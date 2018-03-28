//
//  MyQRCodeVC.m
//  TestNCEDeom
//
//  Created by radar on 2018/3/26.
//  Copyright © 2018年 Radar. All rights reserved.
//

#import "MyQRCodeVC.h"
#import "RDQRCodeCreator.h"

@interface MyQRCodeVC ()

@property (nonatomic, copy)   NSDictionary *myInfoDic; //自己的个人信息
@property (nonatomic, strong) UIImageView *codeView; //二维码

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
    
    //添加二维码容器
    self.codeView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, SCR_WIDTH-100, SCR_WIDTH-100)];
    [self.view addSubview:_codeView];
    
    //设定二维码
    [self setMyCode];
}

- (void)setMyCode
{
    /*
    @{
      @"user_id":@"00000",
      @"device_token":@"", 
      @"nick_name":@"", 
      @"face_id":@"", 
      @"introduce":@"",
      @"relation":@""
      },
    */
    
    //获取头像
    UIImage *faceImage = [[DataCenter sharedCenter] faceImageForMine];
    
    //获取二维码串
    NSString *codeString = [DDFunction jsonStringFormData:_myInfoDic];
    
    //创建二维码
    UIImage *codeImage = [RDQRCodeCreator createQRCode:codeString withFace:faceImage];
    
    //设定
    _codeView.image = codeImage;
    
}




@end
