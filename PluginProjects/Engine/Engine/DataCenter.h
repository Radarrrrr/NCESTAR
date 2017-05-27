//
//  DataCenter.h
//  TestNCEDeom
//
//  Created by Radar on 2017/3/14.
//  Copyright © 2017年 Radar. All rights reserved.
//
//  数据中心，用来做整个app的数据中央处理工作，对于本类与plugin模块之间的关系，可以采用主动下发、请求下发、请求更改 几种模式，但不可以模块对其直接操作，以免耦合
//  数据中心的数据都是copy以后下发，相当于在app内部做了一个数据备份，每个pulgin模块都会独立拥有自己的数据，如果需要修改，也是模块和数据中心在做一次同步，这么做是为了解耦，可以接受双份数据。


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
            "from_token" = "xxxxxxxx",          //如果from_token是自己，说明是发出去的，然后如果有notifyid，说明已送达，如果没有，说明尚不知道是否已送达
            "to_token" = "xxxxxxxx"
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




#import <Foundation/Foundation.h>

@interface DataCenter : NSObject

+ (instancetype)sharedCenter; //单实例


#pragma mark - 数据收集&获取
- (void)collectGroupMessages; //从group里边收集未展示的消息payloads

- (void)appendNotifyData:(NSDictionary*)notiDic;//添加一条新的消息，到队列最后面


#pragma mark - 数据请求
- (NSMutableArray *)getAllMessages; //获取所有已经存储的messages 返回顺序为时间正序，最新的在最后面

- (NSDictionary *)getNotiDataForNotifyid:(NSString*)notifyid; //根据notifyid在数据中心的所有消息表中获取对应的消息字典

- (NSDictionary *)getNotiDataForNotifyToken:(NSString*)notifytoken; //根据notifytoken在数据中心的所有消息表中获取对应的消息字典




#pragma mark - 个人信息相关数据
/* userInfos整体数据结构
{
    "devicetoken1":
    {
        "device_token":"xxxxx", 
        "nick_name":"xxxx", 
        "face_id": "xxxx", 
        "introduce":"xxxxx"
    },
    "devicetoken2":{"":"", "":"", "": ""},
    "devicetoken3":{"":"", "":"", "": ""}
    ...
}
*/
- (id)userInfoForToken:(NSString*)deviceToken item:(NSString*)itemName; //根据deviceToken获取用户的个人信息, 如果itemName为nil，则取出全部用户信息，如果不为空则取分项信息，例如：@"nick_name"

- (void)addUserInfo:(NSDictionary*)userInfoDic completion:(void (^)(BOOL finish))completion; //添加一个用户信息到库里存储


@end


















