//
//  AppDelegate.m
//  TestNCEDeom
//
//  Created by Radar on 2016/11/10.
//  Copyright © 2016年 Radar. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "ViewController.h"


@interface AppDelegate ()

@property (nonatomic, strong) HomeViewController *homeVC;
@property (nonatomic, strong) UINavigationController *mainNav;
@property (nonatomic, strong) RDWaitingDots *serverStatusDots; //服务器状态小点

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //创建框架
    self.homeVC = [[HomeViewController alloc] init];
    self.mainNav = [[UINavigationController alloc] initWithRootViewController:_homeVC];
    _mainNav.navigationBarHidden = NO;
    _mainNav.navigationBar.translucent = NO; //不要导航条模糊，为了让页面从导航条下部是0开始，如果为YES，则从屏幕顶部开始是0
    self.window.rootViewController = _mainNav;
    
    
    //添加状态条上的连接状态
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, SCR_WIDTH, 20)];
    statusBarView.backgroundColor = [UIColor clearColor];
    [_mainNav.navigationBar addSubview:statusBarView];
    
    self.serverStatusDots = [[RDWaitingDots alloc] initWithFrame:CGRectMake(SCR_WIDTH-155, 0, 56, 20)];
    [statusBarView addSubview:_serverStatusDots];
    
    
    
    //注册和使用通知相关-----------------------------------------------------------------------------------------------------
    //注册
    [[RDUserNotifyCenter sharedCenter] registerUserNotification:self completion:^(BOOL success) {
        //do sth..
    }];
    
    //绑定action到category
    [[RDUserNotifyCenter sharedCenter] prepareBindingActions];
    [[RDUserNotifyCenter sharedCenter] appendAction:@"action_enter" actionTitle:@"进去看看" options:UNNotificationActionOptionForeground toCategory:@"myNotificationCategory"];
    [[RDUserNotifyCenter sharedCenter] appendAction:@"action_exit" actionTitle:@"关闭" options:UNNotificationActionOptionDestructive toCategory:@"myNotificationCategory"];
    [[RDUserNotifyCenter sharedCenter] bindingActions];
    //---------------------------------------------------------------------------------------------------------------------
    
    
    //清空本地通知badge数量
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    //获取存储在group里边的通知payloads
    [[DataCenter sharedCenter] collectGroupMessages];
    
    
    //TO DO: 模拟两个用户数据，以后会换成正式的
    [self createUsers];
    
    
    return YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //清空本地通知badge数量
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //获取存储在group里边的通知payloads
    [[DataCenter sharedCenter] collectGroupMessages];
    
    //刷新一下列表
    UIViewController *topVC = [_mainNav topViewController];
    if([topVC isKindOfClass:[HomeViewController class]])
    {
        [_homeVC refreshMsgList];
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSDate *lastConnectDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_connected_date"];
    
    //三分钟以内不主动断开
    if(!lastConnectDate || (-[lastConnectDate timeIntervalSinceNow] > 60*3))
    {
        [[RDPushTool sharedTool] disconnect];
    }
    
    //连接推送服务
    [[RDPushTool sharedTool] connect:^(PTConnectReport *report) {
        
        [self changeConnectStatus:report];
        
        if(report.status == PTConnectReportStatusConnectSuccess)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"last_connected_date"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

- (void)changeConnectStatus:(PTConnectReport*)report
{
    switch (report.status) {
        case PTConnectReportStatusConnecting:
        {
            [_serverStatusDots startWaiting];
        }
            break;
        case PTConnectReportStatusConnectSuccess:
        {
            [_serverStatusDots stopWaitingForState:RDWaitingDotsFinishStateSuccess];
        }  
            break;
        case PTConnectReportStatusConnectFailure:
        {
            [_serverStatusDots stopWaitingForState:RDWaitingDotsFinishStateFailure];
        }  
            break;
        default:
            break;
    }
}




/***********************************************************************************************************/
#pragma mark - APNS
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    NSString *newToken1 = [NSString stringWithFormat:@"%@",deviceToken];
//    //NSString *newToken2 = [newToken1 substringWithRange:NSMakeRange(1, [newToken1 length]-2)];
//    //NSString *newToken3 = [newToken2 stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"Received token from Apple: %@",newToken1);
    
    NSString *deviceTokenStr = [[[[deviceToken description]
                                 stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                 stringByReplacingOccurrencesOfString:@">" withString:@""]
                                 stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceTokenSt:%@",deviceTokenStr);
    
    
    //存储到userdefault里边，供全局使用
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenStr forKey:SAVED_SELF_DEVICE_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //给推送模拟器存一份
    [RDPushSimuVC saveAppDeviceToken:deviceTokenStr];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error 
{
    NSLog(@"register APNS failed reason: %@", error.description);
}
/***********************************************************************************************************/




#pragma mark -
#pragma mark RDUserNotifyCenterDelegate 相关返回方法
- (void)didReceiveNotificationResponse:(UNNotificationResponse*)response content:(UNNotificationContent*)content isLocal:(BOOL)blocal
{
    NSString     *actionID      = response.actionIdentifier;
    //    NSString     *categoryID    = content.categoryIdentifier;
    //    NSDictionary *userInfo      = content.userInfo;
    
    
    if([actionID isEqualToString:@"com.apple.UNNotificationDefaultActionIdentifier"])
    {
        //点击内容窗口进来的
        NSLog(@"点击内容窗口进来的");
        [_homeVC moveListPositionToTop];
        [_homeVC flashFirstMessage];
    }
    else
    {
        //点击自定义Action按钮进来的
        NSLog(@"点击自定义Action按钮进来的 actionID: %@", actionID);
    }
}
- (void)didReceiveNotificationAtForground:(UNNotification *)notification isLocal:(BOOL)blocal
{
    //前台收到通知事件
    if(!blocal)
    {
        //播放声音
        [[AudioPlayer sharedAudioPlayer] setAudio:@"Purr" withType:@"aiff" withLoop:NO];
        [[AudioPlayer sharedAudioPlayer] play];
        
        //获取存储在group里边的通知payloads
        [[DataCenter sharedCenter] collectGroupMessages];
        
        //获取这条新消息的消息token
        NSString *notifytoken = [RDUserNotifyCenter getValueForKey:@"notifytoken" inNotification:notification];
        if(!STRVALID(notifytoken)) return;
        
        //去DataCenter里边获取到该条消息的data
        NSDictionary *notiDic = [[DataCenter sharedCenter] getNotiDataForNotifyToken:notifytoken];
        
        //根据获取到的消息数据，做增加消息的列表
        [_homeVC insertMessage:notiDic];
        
    }
    else
    {
        //本地通知做别的事情。。。
        
    }
}



//----模拟两份用户数据--------------------------------------------------------------------------------------------------------------------
- (void)createUsers
{
    NSDictionary *userMe = 
    @{
        @"user_id":@"00001",
        @"device_token":@"17055f34cae68e9d99abed13cedf99ba1ece1b819f2dc61b8b075fc68d67e03b", 
        @"nick_name":@"天气不错", 
        @"face_id":@"ma", 
        @"introduce":@"今天天气不错"
     };
    
    NSDictionary *userBao = 
    @{
        @"user_id":@"00000",
        @"device_token":@"e78d0b60218a911f7d062ef5d42f0fe22a24ee8a9fca50f8d7bd86c89b8a6678", 
        @"nick_name":@"宁小盒", 
        @"face_id":@"star", 
        @"introduce":@"我是宁小盒，天天旺旺旺"
     };
    
    [[DataCenter sharedCenter] addUserInfo:userMe completion:^(BOOL finish) {
        
    }];
    
    [[DataCenter sharedCenter] addUserInfo:userBao completion:^(BOOL finish) {
        
    }];
    
}
//-----------------------------------------------------------------------------------------------------------------------



@end








