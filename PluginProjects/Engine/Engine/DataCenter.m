//
//  DataCenter.m
//  TestNCEDeom
//
//  Created by Radar on 2017/3/14.
//  Copyright © 2017年 Radar. All rights reserved.
//



#define KEYCHAIN_KEY_MY_USER_ID                 @"com.dangdang.unc.myuserid"
#define KEYCHAIN_KEY_ALL_USERS                  @"com.dangdang.unc.allusers"

#define DataCenter_all_messages_save_list       @"DataCenter all messages save list"

#define DataCenter_saved_messages_limit_count   60     //总存储容量，超过60以后，则修正为20条
#define DataCenter_saved_messages_fix_count     20      




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

        //最早先进行一下初始化默认用户的存储
        [self onceSetupDefaultUsers];  //此方法只会在第一次安装并启动的时候，运行一次，以后都不会运行了
        
        //然后再获取其他各种信息
        self.allMessages = [[NSMutableArray alloc] init];
        self.allUserInfos = [self loadAllUserInfos];  //初始化就把所有的用户信息放在内存里
        self.myUserInfo = [self myInfoOnItem:nil];
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




#pragma mark - 数据收集&获取相关
//数据收集和存储
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
    
    //保存列表
    [[NSUserDefaults standardUserDefaults] setObject:_allMessages forKey:DataCenter_all_messages_save_list];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)appendNotifyData:(NSDictionary*)notiDic
{
    if(!DICTIONARYVALID(notiDic)) return;
    
    [_allMessages addObject:notiDic];
    
    //保存列表
    [[NSUserDefaults standardUserDefaults] setObject:_allMessages forKey:DataCenter_all_messages_save_list];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)fixMessageStorageCapacity
{
    //修正消息存储容量
    NSInteger count = [_allMessages count];
    if(count > DataCenter_saved_messages_limit_count)
    {
        [_allMessages removeObjectsInRange:NSMakeRange(0, (count - DataCenter_saved_messages_fix_count) )];
        //保存列表
        [[NSUserDefaults standardUserDefaults] setObject:_allMessages forKey:DataCenter_all_messages_save_list];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


//数据请求
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
//初始化自己的个人ID，只需要第一次安装时执行一次，以后都从keychain里边取了
- (void)onceInitMyUserID:(NSString*)userID
{
    if(!STRVALID(userID)) return;
    
    NSString *myUserid = [CHKeyChain load:KEYCHAIN_KEY_MY_USER_ID];
    
    //只要keychain里边有自己的userid了，那么以后都不再存储了，始终保持同一个
    if(STRVALID(myUserid)) return;
    
    [CHKeyChain save:KEYCHAIN_KEY_MY_USER_ID data:userID];
}

- (id)myInfoOnItem:(NSString*)itemName
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
                NSString *myUserid = [CHKeyChain load:KEYCHAIN_KEY_MY_USER_ID];
                NSString *userid = [infodic objectForKey:@"user_id"];
                if(STRVALID(userid) && [userid isEqualToString:myUserid])
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
    
    NSDictionary *savedAllInfos = [CHKeyChain load:KEYCHAIN_KEY_ALL_USERS];
    
    if(DICTIONARYVALID(savedAllInfos))
    {
        allInfos = [NSMutableDictionary dictionaryWithDictionary:savedAllInfos];
    }
    
    return allInfos;
}


- (void)onceSetupDefaultUsers 
{
    //只做一次，初始化一些空用户，只有user_id内置一下
    //如果已经存储过了用户，那么就不再存储默认用户了
    NSDictionary *savedAllInfos = [CHKeyChain load:KEYCHAIN_KEY_ALL_USERS];
    if(DICTIONARYVALID(savedAllInfos)) return;
    
    //创建默认用户
    NSDictionary *defaultUsers = 
    @{
      @"00000":  
          @{
              @"user_id":@"00000",
              @"device_token":@"", 
              @"nick_name":@"", 
              @"face_id":@"", 
              @"introduce":@"",
              @"relation":@""
              },
      @"00001":  
          @{
              @"user_id":@"00001",
              @"device_token":@"", 
              @"nick_name":@"", 
              @"face_id":@"", 
              @"introduce":@"",
              @"relation":@""
              }
      };
    
    //存储到钥匙串
    [CHKeyChain save:KEYCHAIN_KEY_ALL_USERS data:defaultUsers];
}


- (void)saveUserInfo:(NSDictionary*)userInfoDic
{    
    if(!DICTIONARYVALID(userInfoDic)) 
    {
        return;
    }
    
    //先拿到userid
    NSString *userid = [userInfoDic objectForKey:@"user_id"];
    if(!STRVALID(userid))
    {
        return;
    }
    
    //存储userinfo
    [_allUserInfos setObject:userInfoDic forKey:userid];
    
    //存储到钥匙串
    [CHKeyChain save:KEYCHAIN_KEY_ALL_USERS data:_allUserInfos];
}

- (void)updateUserInfo:(NSString*)userid onitem:(NSString*)item useinfo:(NSString*)info
{
    if(!STRVALID(userid)) return;
    if(!STRVALID(info)) return;
    if(!DICTIONARYVALID(_allUserInfos)) return;
    
    NSDictionary *userInfo = [_allUserInfos objectForKey:userid];
    if(!DICTIONARYVALID(userInfo)) return;
    
    NSMutableDictionary *mInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    
    [mInfo setObject:info forKey:item];
    [self saveUserInfo:mInfo];
}

- (BOOL)checkUserExist:(NSString*)userid
{
    if(!STRVALID(userid)) return NO;
    if(!DICTIONARYVALID(_allUserInfos)) return NO;
    
    NSArray *allIDs = [_allUserInfos allKeys];
    if(!ARRAYVALID(allIDs)) return NO;
    
    for(NSString *kid in allIDs)
    {
        if([kid isEqualToString:userid])
        {
            return YES;
        }
    }
    
    return NO;
}

- (id)userInfoForId:(NSString*)userid onitem:(NSString*)itemName
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


- (UIImage *)faceImageForMine
{
    NSString *myUserid = [self myInfoOnItem:@"user_id"];
    UIImage *faceImg = [self createFaceImageForUserId:myUserid];
    return faceImg;
}
- (UIImage *)faceImageForUser:(NSString *)userid
{
    UIImage *faceImg = [self createFaceImageForUserId:userid];
    return faceImg;
}


//根据userid获取对应的头像image
- (UIImage*)createFaceImageForUserId:(NSString*)userid
{
    NSString *faceid = @"star";
    
    if(STRVALID(userid)) 
    {
        NSString *ufaceid = [[DataCenter sharedCenter] userInfoForId:userid onitem:@"face_id"];
        if(STRVALID(ufaceid)) 
        {
            faceid = ufaceid;
        }
    }
    
    NSString *facepicN = [NSString stringWithFormat:@"face_%@.png", faceid];
    return [UIImage imageNamed:facepicN];
}




@end













