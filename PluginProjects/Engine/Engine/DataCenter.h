//
//  DataCenter.h
//  TestNCEDeom
//
//  Created by Radar on 2017/3/14.
//  Copyright © 2017年 Radar. All rights reserved.
//
//  数据中心，用来做整个app的数据中央处理工作，对于本类与plugin模块之间的关系，可以采用主动下发、请求下发、请求更改 几种模式，但不可以模块对其直接操作，以免耦合
//  数据中心的数据都是copy以后下发，相当于在app内部做了一个数据备份，每个pulgin模块都会独立拥有自己的数据，如果需要修改，也是模块和数据中心在做一次同步，这么做是为了解耦，可以接受双份数据。


#import <Foundation/Foundation.h>

@interface DataCenter : NSObject

+ (instancetype)sharedCenter; //单实例


#pragma mark - 数据收集&获取
- (void)collectGroupMessages; //从group里边收集未展示的消息payloads



#pragma mark - 数据请求
- (NSMutableArray *)getAllMessages; //获取所有已经存储的messages 返回顺序为时间正序，最新的在最后面

- (NSDictionary *)getNotiDataForNotifyid:(NSString*)notifyid; //根据notifyid在数据中心的所有消息表中获取对应的消息字典


@end
