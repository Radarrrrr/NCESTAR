//
//  SettingViewController.m
//  TestNCEDeom
//
//  Created by radar on 2018/3/25.
//  Copyright © 2018年 Radar. All rights reserved.
//

#import "SettingViewController.h"
#import "MyQRCodeVC.h"


@interface SettingViewController ()

@property (nonatomic, copy)   NSDictionary *myInfoDic; //自己的个人信息
@property (nonatomic, strong) UIImageView *faceView;   
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *relationLabel;
@property (nonatomic, strong) UITextView *introTextView;

@property (nonatomic, strong) UITableView *infoTable;


@end


@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = DDCOLOR_BACK_GROUND;
    self.navigationItem.title = @"我的设置";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]; 
    
    //获取我的信息
    self.myInfoDic = [[DataCenter sharedCenter] myInfoOnItem:nil];
    if(!_myInfoDic)
    {
        self.myInfoDic = [[NSDictionary alloc] init];
    }
    
    //添加列表
    self.infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, SCR_HEIGHT-64) style:UITableViewStylePlain];
    _infoTable.delegate = self;
    _infoTable.dataSource = self;
    [self.view addSubview:_infoTable];
    
    UIView *footV = [[UIView alloc] initWithFrame:CGRectZero];
    _infoTable.tableFooterView = footV;
    
    
}



//@"user_id":@"00001",
//@"device_token":@"", 
//@"nick_name":@"", 
//@"face_id":@"", 
//@"introduce":@"",
//@"relation":@""

//[[DataCenter sharedCenter] updateUserInfo:@"00000" onitem:@"nick_name" useinfo:@"宁小盒"];
//[[DataCenter sharedCenter] updateUserInfo:@"00000" onitem:@"face_id" useinfo:@"wang"];
//[[DataCenter sharedCenter] updateUserInfo:@"00000" onitem:@"introduce" useinfo:@"我是宁小盒，天天旺旺旺"];
//[[DataCenter sharedCenter] updateUserInfo:@"00000" onitem:@"relation" useinfo:@"home"];
//[[DataCenter sharedCenter] updateUserInfo:myuserid onitem:@"device_token" useinfo:deviceToken];




#pragma mark -
#pragma mark 内部方法
- (void)setDataToCell:(UITableViewCell *)cell onIndexPath:(NSIndexPath *)indexPath
{
    if(!cell) return;
    if(!indexPath) return;
    
    switch (indexPath.row) {
        case 0: //头像+昵称+签名
            {
                cell.imageView.image = [[DataCenter sharedCenter] faceImageForMine];
                
                cell.textLabel.text = [_myInfoDic objectForKey:@"nick_name"];
                cell.detailTextLabel.text = [_myInfoDic objectForKey:@"introduce"];
            }
            break;
        case 1: //二维码
        {
            cell.textLabel.text = @"我的二维码";
        }
            break;
        case 2: //其他
        {
            cell.textLabel.text = @"推送调试模拟器";
        }
            break;
        default:
            break;
    }

}

- (void)jumpToFuncPageForIndexPath:(NSIndexPath *)indexPath
{
    if(!indexPath) return;
    
    switch (indexPath.row) {
        case 0: //头像+昵称+签名
        {
        }
            break;
        case 1: //二维码
        {
            MyQRCodeVC *myqrVC = [[MyQRCodeVC alloc] init];
            [self.navigationController pushViewController:myqrVC animated:YES];
        }
            break;
        case 2: //推送调试模拟器
        {
            [DDRouter actionForLinkURL:@"pushsimulator://"];
        }
            break;
        default:
            break;
    }
}




#pragma mark -
#pragma mark Table View DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellID = @"settingCell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:kCellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    [self setDataToCell:cell onIndexPath:indexPath];
    
    return cell;
}


#pragma mark -
#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self jumpToFuncPageForIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 44;
    if(indexPath.row ==0 )
    {
        height = 88;
    }
    
    return height;
}





@end
