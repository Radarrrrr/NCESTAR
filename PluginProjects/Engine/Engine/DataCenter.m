//
//  DataCenter.m
//  TestNCEDeom
//
//  Created by Radar on 2017/3/14.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import "DataCenter.h"



@interface DataCenter ()

@property (nonatomic, strong) NSMutableArray *allMessages; //所有的消息数据，目前未有数据库，所以暂时只存储开启一次从group里边获取到的全部消息

@end



@implementation DataCenter

- (id)init{
    self = [super init];
    if(self){
        //do something
        self.allMessages = [[NSMutableArray alloc] init];
    }
    return self;
}
+ (instancetype)sharedCenter
{
    static dispatch_once_t onceToken;
    static DataCenter *center;
    dispatch_once(&onceToken, ^{
        center = [[DataCenter alloc] init];
    });
    return center;
}




#pragma mark - 数据收集&获取
- (void)collectGroupMessages
{
    NSArray *payloads = [RDUserNotifyCenter loadPayloadsFromGroup];
    if(!ARRAYVALID(payloads)) return;
//    
//    [_allMessages addObjectsFromArray:payloads];
    
}



#pragma mark - 数据请求下发



#pragma mark - 数据请求处理





@end













