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


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
        @"device_token":@"c79b18192ea895c33a58bd411dd4309d01f6ae6b8fd8804def2ecad4510a40c7", 
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








