//
//  DataCenter.m
//  TestNCEDeom
//
//  Created by Radar on 2017/3/14.
//  Copyright © 2017年 Radar. All rights reserved.
//


#define DataCenter_all_messages_save_list @"DataCenter all messages save list"


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
    //先从userdefault里边取出以前存储的
    if([_allMessages count] == 0)
    {
        NSArray *savedArr = (NSArray*)[[NSUserDefaults standardUserDefaults] objectForKey:DataCenter_all_messages_save_list];
        if(ARRAYVALID(savedArr))
        {
            [_allMessages addObjectsFromArray:savedArr];
        }
    }
    
    //获取到通知group里边还未取出来过的
    NSArray *payloads = [RDUserNotifyCenter loadPayloadsFromGroup];
    if(!ARRAYVALID(payloads)) return;
    
    //把group里边的添加到总列表里边
    [_allMessages addObjectsFromArray:payloads];
    
    //TO DO: 限定最多数量，超出的删掉不保存
    
    //保存列表
    [[NSUserDefaults standardUserDefaults] setObject:_allMessages forKey:DataCenter_all_messages_save_list];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark - 数据请求下发



#pragma mark - 数据请求
- (NSMutableArray *)getAllMessages
{
    return _allMessages;
}

- (NSDictionary *)getNotiDataForNotifyid:(NSString*)notifyid
{
    if(!STRVALID(notifyid)) return nil;
    if(!ARRAYVALID(_allMessages)) return nil;
    
    //遍历循环所有的消息，找到notifyid对应的那个并返回
    for(NSDictionary *notiDic in _allMessages)
    {
        NSString *nid = [notiDic objectForKey:@"notifyid"];
        if(STRVALID(nid) && [nid isEqualToString:notifyid])
        {
            return notiDic;
        }
    }
    
    return nil;
}


@end













