//
//  MessageCell.h
//  Radar Use
//
//  Created by Radar on 11-5-3.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/* data结构：
{
    notifyid = "44B28B55-B732-44E3-96B2-BF6BAE551EC0";
    payload =     {
        aps =         {
            alert =             {
                body = "it is a beautiful day";
                subtitle = "\U6211\U662f\U526f\U6807\U9898";
                title = "\U6211\U662f\U539f\U88c5\U6807\U9898";
            };
            attach = "https://picjumbo.imgix.net/HNCK8461.jpg?q=40&w=200&sharp=30";
            badge = 1;
            category = myNotificationCategory;
            "from_token" = xxxxxxxx;
            "mutable-content" = 1;
            sound = default;
            "to_token" = xxxxxxxx;
        };
        "goto_page" = "cms://page_id=14374";
    };
    receivetime = "17-04-19 16:53:32";
 }
*/ 


@interface MessageCell : UITableViewCell {

	UILabel *_tLabel;
}



#pragma mark -
#pragma mark in use functions



#pragma mark -
#pragma mark out use functions
-(void)setCellData:(id)data; //{"notifyid":"xxx", "receivetime":"xxxx", "payload":{xxxxxx}}



@end
