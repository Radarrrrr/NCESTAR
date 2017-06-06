//
//  DataCenter.m
//  TestNCEDeom
//
//  Created by Radar on 2017/3/14.
//  Copyright © 2017年 Radar. All rights reserved.
//


#define DataCenter_all_messages_save_list       @"DataCenter all messages save list"
#define DataCenter_saved_messages_limit_count   20


#define DataCenter_all_user_info_save_list  @"DataCenter all user info save list"



#import "DataCenter.h"



@interface DataCenter ()

@property (nonatomic, strong) NSMutableArray *allMessages; //所有的消息数据，目前未有数据库，所以暂时只存储开启一次从group里边获取到的全部消息

@property (nonatomic, strong) NSMutableDictionary *allUserInfos; //所有的用户信息

@property (nonatomic, strong) NSMutableDictionary *myUserInfo; //我自己的用户信息，因为一直常用，所以提前引出来，提高效率

@end



@implementation DataCenter

- (id)init{
    self = [super init];
    if(self){
        //do something
        self.allMessages = [[NSMutableArray alloc] init];
        self.allUserInfos = [self loadAllUserInfos];  //初始化就把所有的用户信息放在内存里
        self.myUserInfo = [self loadMyInfoForItem:nil];
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
    
    //限定最多数量，超出的删掉不保存
    if([_allMessages count] > DataCenter_saved_messages_limit_count)
    {
        [_allMessages removeObjectsInRange:NSMakeRange(0, [payloads count])];
    }
    
    //保存列表
    [[NSUserDefaults standardUserDefaults] setObject:_allMessages forKey:DataCenter_all_messages_save_list];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)appendNotifyData:(NSDictionary*)notiDic
{
    if(!DICTIONARYVALID(notiDic)) return;
    
    [_allMessages addObject:notiDic];
    
    //限定最多数量，超出的删掉不保存
    if([_allMessages count] > DataCenter_saved_messages_limit_count)
    {
        [_allMessages removeObjectAtIndex:0];
    }
    
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
- (NSDictionary *)getNotiDataForNotifyToken:(NSString*)notifytoken
{
    if(!STRVALID(notifytoken)) return nil;
    if(!ARRAYVALID(_allMessages)) return nil;
    
    //遍历循环所有的消息，找到notifytoken对应的那个并返回
    for(NSDictionary *notiDic in _allMessages)
    {
        NSString *token = [DDFunction getValueForKey:@"notifytoken" inData:notiDic];
        if(STRVALID(token) && [token isEqualToString:notifytoken])
        {
            return notiDic;
        }
    }
    
    return nil;
}



#pragma mark - 个人信息相关数据
- (void)updateMyUserInfo:(NSDictionary*)myInfo
{
    if(!DICTIONARYVALID(myInfo)) return;
    
    self.myUserInfo = [NSMutableDictionary dictionaryWithDictionary:myInfo];
    
    [self setUserInfo:_myUserInfo completion:^(BOOL finish) {
        
    }];
}
- (id)loadMyInfoForItem:(NSString*)itemName
{
    if(!DICTIONARYVALID(_allUserInfos)) return nil;
    
    NSMutableDictionary *useUserInfo = nil;
    
    if(DICTIONARYVALID(_myUserInfo))
    {
        useUserInfo = _myUserInfo;
    }
    else
    {
        NSArray *allkeys = [_allUserInfos allKeys];
        for(NSString *key in allkeys)
        {
            NSMutableDictionary *infodic = [_allUserInfos objectForKey:key];
            if(DICTIONARYVALID(infodic))
            {
                NSString *relation = [infodic objectForKey:@"relation"];
                if(STRVALID(relation) && [relation isEqualToString:@"myself"])
                {
                    //找到自己的信息了
                    useUserInfo = infodic;
                    break;
                }
            }
        }
        
    }
    
    //如果分项字段为nil，则返回整体用户信息
    if(!STRVALID(itemName))
    {
        return useUserInfo;
    }
    
    //如果分项字段存在，则返回分项信息
    id item = [useUserInfo objectForKey:itemName];
    return item;
}


- (NSMutableDictionary *)loadAllUserInfos
{
    NSMutableDictionary *allInfos = [[NSMutableDictionary alloc] init];
    
    NSDictionary *savedAllInfos = [[NSUserDefaults standardUserDefaults] objectForKey:DataCenter_all_user_info_save_list];
    if(DICTIONARYVALID(savedAllInfos))
    {
        allInfos = [NSMutableDictionary dictionaryWithDictionary:savedAllInfos];
    }
    
    return allInfos;
}

- (id)userInfoForId:(NSString*)userid item:(NSString*)itemName
{
    if(!STRVALID(userid)) return nil;
    if(!DICTIONARYVALID(_allUserInfos)) return nil;
    
    NSDictionary *userInfo = [_allUserInfos objectForKey:userid];
    if(!DICTIONARYVALID(userInfo)) return nil;
    
    //如果分项字段为nil，则返回整体用户信息
    if(!STRVALID(itemName)) return userInfo;
    
    //如果分项字段存在，则返回分项信息
    id item = [userInfo objectForKey:itemName];
    return item;
}

- (void)setUserInfo:(NSDictionary*)userInfoDic completion:(void (^)(BOOL finish))completion
{    
    if(!DICTIONARYVALID(userInfoDic)) 
    {
        if(completion)
        {
            completion(NO);
        }
        return;
    }
    
    //先拿到userid
    NSString *userid = [userInfoDic objectForKey:@"user_id"];
    if(!STRVALID(userid))
    {
        if(completion)
        {
            completion(NO);
        }
        return;
    }
    
    //存储userinfo
    [_allUserInfos setObject:userInfoDic forKey:userid];
    
    //存储到本地
    [[NSUserDefaults standardUserDefaults] setObject:_allUserInfos forKey:DataCenter_all_user_info_save_list];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(completion)
    {
        completion(YES);
    }
}




@end













