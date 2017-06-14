//
//  AppDelegate.h
//  TestNCEDeom
//
//  Created by Radar on 2016/11/10.
//  Copyright © 2016年 Radar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UINavigationController *mainNav;


- (void)connectAPNsServer:(BOOL)needDisconnect;  //连接推送服务器, 是否需要断开连接再重连


@end

