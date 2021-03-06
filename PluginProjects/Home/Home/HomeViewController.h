//
//  HomeViewController.h
//  Home
//
//  Created by Radar on 2017/1/18.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeViewController : UIViewController 

- (void)refreshMsgList; //刷新聊天列表
- (void)insertMessage:(NSDictionary*)msgData; //插入一行消息数据，在最前面插入

- (void)moveListPositionToTop; //恢复到列表最顶部
- (void)flashFirstMessage; //让第一条信息闪动一下

- (void)changeConnectStatus:(NSInteger)status;

@end
