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




#pragma mark - 数据收集&获取相关 (存储在UserDefault里)
/* payload完整结构
{
    "payload":
    {
        "aps":
        {
            "alert":
            {
                "title":"我是原装标题",
                "subtitle":"我是副标题",
                "body":"it is a beautiful day"
            },
            "badge":1,
            "sound":"default",
            "mutable-content":"1",
            "category":"myNotificationCategory",
            "attach":"https://picjumbo.imgix.net/HNCK8461.jpg?q=40&w=200&sharp=30",
            "from_token":"xxxxxxxx",          //如果from_token是自己，说明是发出去的，然后如果有notifyid，说明已送达，如果没有，说明尚不知道是否已送达
            "from_userid":"xxxxxxxx",
            "to_token":"xxxxxxxx"
        },
        "goto_page":"cms://page_id=14374",
        "sendtime":"17-04-19 16:53:32",          //发送时间
        
        "notifytoken":"xxxxxxxxxxxxxxx",         //每条消息的唯一标识token，用from_token+to_token+sendtime做MD5生成, 消息的取用和显示都用这个来取
 
        "msgtype":"message/confirm",             //消息类型，是message还是confirm，如果是message类型会存入DataCenter，confirm类型的不会存储
        "confirm_notifyid":"xxxxxxxxxxx"         //接收到notifytoken对应的那条消息的官方消息id
        
    },
    
    //以下信息是不发送给对方的，本地维护
    "receivetime":"17-04-19 16:53:32",                   //接收时间
    "notifyid":"44B28B55-B732-44E3-96B2-BF6BAE551EC0"    //官方消息id，所有操作以这个为准
}  
*/

//数据收集和存储
- (void)collectGroupMessages; //从group里边收集未展示的消息payloads
- (void)fixMessageStorageCapacity; //修正消息存储容量
- (void)appendNotifyData:(NSDictionary*)notiDic;//添加一条新的消息，到队列最后面


//数据请求
- (NSMutableArray *)getAllMessages; //获取所有已经存储的messages 返回顺序为时间正序，最新的在最后面
- (NSDictionary *)getNotiDataForNotifyid:(NSString*)notifyid; //根据notifyid在数据中心的所有消息表中获取对应的消息字典
- (NSDictionary *)getNotiDataForNotifyToken:(NSString*)notifytoken; //根据notifytoken在数据中心的所有消息表中获取对应的消息字典





#pragma mark - 个人信息相关数据 (存储在KeyChain里)
/* userInfos整体数据结构
{
    "user_id1":
    {
        "user_id":"xxxxxx",
        "device_token":"xxxxx", 
        "nick_name":"xxxx", 
        "face_id": "xxxx", 
        "introduce":"xxxxx",
        "relation":"myself"     //关系，myself/home/friend/workmate/others
    },
    "user_id2":{"":"", "":"", "": ""},
    "user_id3":{"":"", "":"", "": ""}
    ...
}
*/

//初始化自己的个人ID，只需要第一次安装时执行一次，以后都从keychain里边取了
- (void)onceInitMyUserID:(NSString*)userID;         //初始化我自己的用户id


//维护整个用户关系表
- (void)saveUserInfo:(NSDictionary*)userInfoDic; //保存一个用户信息到库里存储，使用user_id当key来存储，如果已有则覆盖
- (void)updateUserInfo:(NSString*)info onitem:(NSString*)item foruser:(NSString*)userid; //修改userid对应的用户的item对应字段的信息
- (BOOL)checkUserExist:(NSString*)userid; //检查一个userid对应的用户是否存在

- (id)myInfoOnItem:(NSString*)itemName;        //读取自己的用户信息，如果itemName为nil，则取出全部用户信息，如果不为空则取分项信息，例如：@"nick_name"
- (id)userInfoForId:(NSString*)userid onitem:(NSString*)itemName;//根据user_id获取用户的个人信息, 如果itemName为nil，则取出全部用户信息，如果不为空则取分项信息，例如：@"nick_name"



@end


















