//
//  MsgInputView.h
//  Home
//
//  Created by Radar on 2017/4/27.
//  Copyright © 2017年 Radar. All rights reserved.
//


/* payload完整结构，这里只用一部分即可
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
    "goto_page":"cms://page_id=14374"
}
*/        
        

#import <UIKit/UIKit.h>

@interface MsgInputView : UIView

+ (instancetype)sharedInstance; //单实例

- (void)callMsgInputToToken:(NSString*)toToken pushReport:(void(^)(PTPushReport *report))pushReportHandler completion:(void (^)(void))closeHandler;

@end
