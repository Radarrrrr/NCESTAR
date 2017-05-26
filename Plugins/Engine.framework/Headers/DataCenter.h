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
            "from_token" = "xxxxxxxx",
            "from_avatar" = "idxxxx",
            "to_token" = "xxxxxxxx"
        },
        "goto_page":"cms://page_id=14374",
        "msgtype":"message/confirm",             //消息类型，是message还是confirm，如果是message类型会存入DataCenter，confirm类型的不会存储
        "confirm_notifyid":"xxxxxxxxxxx"         //接收到confirm_token对应的消息时候的官方消息id
    },
    
    "receivetime":"17-04-19 16:53:32",                      //接收时间
    "notifyid":"44B28B55-B732-44E3-96B2-BF6BAE551EC0",      //官方消息id，所有操作以这个为准
    
    "sendtime":"17-04-19 16:53:32",                         //发送时间
    "confirm_token":"xxxxxxxxxxxxxxx",                      //本条消息的确认token，根据随时串做的唯一id，用于发送和接收两方验证消息是否已经收到
 
    "delivered":"0"         //是否已送达，0/1
}  
*/




#import <Foundation/Foundation.h>

@interface DataCenter : NSObject

+ (instancetype)sharedCenter; //单实例


#pragma mark - 数据收集&获取
- (void)collectGroupMessages; //从group里边收集未展示的消息payloads



#pragma mark - 数据请求
- (NSMutableArray *)getAllMessages; //获取所有已经存储的messages 返回顺序为时间正序，最新的在最后面

- (NSDictionary *)getNotiDataForNotifyid:(NSString*)notifyid; //根据notifyid在数据中心的所有消息表中获取对应的消息字典


@end
