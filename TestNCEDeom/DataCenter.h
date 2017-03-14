//
//  DataCenter.h
//  TestNCEDeom
//
//  Created by Radar on 2017/3/14.
//  Copyright © 2017年 Radar. All rights reserved.
//
//  数据中心，用来做整个app的数据中央处理工作，对于本类与plugin模块之间的关系，可以采用主动下发、请求下发、请求处理 几种模式，但不可以模块对其直接操作，以免耦合

#import <Foundation/Foundation.h>

@interface DataCenter : NSObject

+ (instancetype)sharedCenter; //单实例


#pragma mark - 数据收集&获取
- (void)collectGroupMessages; //从group里边收集未展示的消息payloads



#pragma mark - 数据请求下发



#pragma mark - 数据请求处理





@end
