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
 qrscaner://                        //二维码扫描器
 plaintext://text=xxxx              //进入空白文字页面，用于二维码扫描以后直接显示二维码中的内容
 friendcode://info=xxxx             //扫描二维码获得的好友信息，如果是已经添加的好友，则覆盖修改本地存储的信息
 http://                            //http和https都直接开启web页面显示
 https://

*/
 
 
 
#import <Foundation/Foundation.h>

@interface DDRouter : NSObject

+ (void)actionForLinkURL:(NSString*)linkURL; //中央控制器跳转字典接口，使用字典触发

@end
