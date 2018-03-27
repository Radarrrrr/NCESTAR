//
//  DDRouter.h
//  TestNCEDeom
//
//  Created by Radar on 2017/3/16.
//  Copyright © 2017年 Radar. All rights reserved.
//

/* 支持的linkURL字典：

 connectapns://disconnectneed=0     //连接APNs服务器，disconnectneed参数表示是否需要先断开连接再重连 0/1
 setting://                         //唤起setting页面
 pushsimulator://                   //打开推送模拟器

*/
 
 
 
#import <Foundation/Foundation.h>

@interface DDRouter : NSObject

+ (void)actionForLinkURL:(NSString*)linkURL; //中央控制器跳转字典接口，使用字典触发

@end
