//
//  NotificationService.m
//  NotificationService
//
//  Created by Radar on 2016/11/29.
//  Copyright © 2016年 Radar. All rights reserved.
//

#import "NotificationService.h"


@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    

    //----测试用，暂时保留-----------------------------------------------------------
    //重写一些东西
    //    self.bestAttemptContent.title = @"我是新标题，说明我拦截到通知了";
    //    self.bestAttemptContent.subtitle = @"我是子标题";
    //    self.bestAttemptContent.body = @"changed text hallo";
    
    //这里添加一些点击事件，可以在收到通知的时候，添加，也可以在拦截通知的这个扩展中添加
    //self.bestAttemptContent.categoryIdentifier = @"myNotificationCategory";
    //----------------------------------------------------------------------------
    
    

    //-测试确认接收功能--------------------------------------------------------------------------------------------------------------
//    NSString *payloadStr = @"{\n\t\"aps\":\n\t{\n\t\t\"alert\":\n\t\t{\n\t\t\t\"title\":\"我接受到了一条新消息！！！\",\n\t\t\t\"subtitle\":\"我是副标题\",\n\t\t\t\"body\":\"it is a beautiful day\"\n\t\t},\n\t\t\"badge\":1,\n\t\t\"sound\":\"default\",\n\t\t\"mutable-content\":\"1\",\n\t\t\"category\":\"myNotificationCategory\",\n\t\t\"attach\":\"http://img3x2.ddimg.cn/29/14/1128514592-1_h_6.jpg\"\n\t},\n\t\"goto_page\":\"link://page=14374\"\n}";
//
//    payloadStr = [payloadStr stringByReplacingOccurrencesOfString:@" " withString:@""];
//    payloadStr = [payloadStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    payloadStr = [payloadStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//    payloadStr = [payloadStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//    
//    NSData *jsonData = [payloadStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *payloadDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
//        
//    [[RDPushTool sharedTool] pushPayload:payloadDictionary toToken:@"c79b18192ea895c33a58bd411dd4309d01f6ae6b8fd8804def2ecad4510a40c7" completion:^(PTPushReport *report) {
//        
//    }];
    
//    测试结果：
//    568] Unable to read p12 file: PKCS12 data is empty
//    2017-05-26 14:53:46.454081 NotificationService[8100:4413568] push failure...no connection with apns!
//    2017-05-26 14:53:46.454629 NotificationService[8100:4413568] Disconnected
//    2017-05-26 14:53:46.454850 NotificationService[8100:4413568] Connecting..
//    2017-05-26 14:53:49.161287 NotificationService[8100:4413568] dataUrl: (null)
//    2017-05-26 14:53:49.163707 NotificationService[8100:4413496] Unable to connect: (null)
    //---------------------------------------------------------------------------------------------------------------
    
    
    
    
    //同步更新一下发送人的user_id和device_token
    [self syncUserInfomationsForPayload:request.content.userInfo];
    
    
    //根据payload里边的信息，修改某些信息的显示状态
    NSDictionary *payload = request.content.userInfo;
    NSString *from_userid = [DDFunction getValueForKey:@"from_userid" inData:payload];
    NSString *body        = [DDFunction getValueForKey:@"body" inData:payload];
    NSString *msgtype     = [DDFunction getValueForKey:@"msgtype" inData:payload];
    NSString *nick_name   = [[DataCenter sharedCenter] userInfoForId:from_userid onitem:@"nick_name"];
    
    //根据消息类型不同，修改显示效果
    if(STRVALID(msgtype))
    {
        if([msgtype isEqualToString:MSG_TYPE_MESSAGE])
        {
            self.bestAttemptContent.body = [NSString stringWithFormat:@"%@ : %@", nick_name, body];
        }
        else if([msgtype isEqualToString:MSG_TYPE_ATTENTION])
        {
            self.bestAttemptContent.body = [NSString stringWithFormat:@"[%@] 发来一个呼叫", nick_name];
        }
    }
    
    
    
    //截获attach和其他数据，下载并存储    
    NSString *link = [RDUserNotifyCenter getValueForKey:@"goto_page" inNotification:request];
    NSString *dataUrl = [self dataUrlForLink:link]; 
    NSLog(@"dataUrl: %@", dataUrl);
    
    
    //把payload存下来
    [RDUserNotifyCenter savePayloadToGroupForNotify:request];
    
    //获取attachment并且存入group
    [RDUserNotifyCenter downAndSaveAttachmentForNotifyRequest:request completion:^(UNNotificationAttachment *attach) {
        
        //attach先弄下来，起码保证推送过来的图片能看到
        if(attach)
        {
            self.bestAttemptContent.attachments = [NSArray arrayWithObject:attach];
        }
        
        //接下来下载对应的数据        
        [RDUserNotifyCenter downAndSaveDataToGroup:dataUrl forceKey:@"goto_page" forNotification:request completion:^(id data) {
        
            //分析并下载存储图片资源
            NSArray *downUrls = [self urlsAnalysedFormData:data forLink:link];
            if(downUrls && [downUrls count] != 0)
            {
                [RDUserNotifyCenter downAndSaveDatasToGroup:downUrls completion:^{
                    NSLog(@"ServiceExtension 拦截操作完成，返回通知上层");
                    self.contentHandler(self.bestAttemptContent);
                }];
            }
            else
            {
                NSLog(@"ServiceExtension 拦截操作完成，返回通知上层");
                self.contentHandler(self.bestAttemptContent);
            }
        }];
    }];
    
    
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    NSLog(@"ServiceExtension 拦截操作超时！直接返回通知上层");
    self.contentHandler(self.bestAttemptContent);
}





#pragma mark -
#pragma mark 一些配套方法
- (NSString *)dataUrlForLink:(NSString *)link
{
    if(!link || ![link isKindOfClass:[NSString class]] || [link isEqualToString:@""])
    {
        return nil;
    }
    
    NSString *dataUrl = nil;
    
    if([link hasPrefix:@"category://"])
    {
        NSString *cid = [self getProperty:@"cid" formLinkURL:link];
        dataUrl = [NSString stringWithFormat:@"http://search.mapi.dangdang.com/index.php?action=list_category&user_client=iphone&client_version=6.3.0&udid=C468039A2648F6CDC79E77EDAC68C4FE&time_code=55029C0906B363E848DB2A969CF17E7A&timestamp=1481122253&union_id=537-50&permanent_id=20161107192044709529023687781578603&page=1&page_size=10&sort_type=default_0&cid=%@&img_size=h", cid];
    }
    else if([link hasPrefix:@"product://"])
    {
        NSString *pid = [self getProperty:@"pid" formLinkURL:link];
        dataUrl = [NSString stringWithFormat:@"http://product.mapi.dangdang.com/index.php?action=get_product&user_client=iphone&client_version=6.3.0&udid=C468039A2648F6CDC79E77EDAC68C4FE&time_code=08BD43CAAA3586463EB6FA43687A6069&timestamp=1481112463&union_id=537-50&permanent_id=20161107192044709529023687781578603&pid=%@&expand=1,2,3,4,5,6&is_abtest=1&img_size=h&lunbo_img_size=h", pid];
    }
    
    return dataUrl;
}

- (NSArray *)urlsAnalysedFormData:(id)data forLink:(NSString *)link
{
    if(!data) return nil;
    if(!link || ![link isKindOfClass:[NSString class]] || [link isEqualToString:@""]) return nil;
    
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if(!dataDic || ![dataDic isKindOfClass:[NSDictionary class]]) return nil;
    
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    
    if([link hasPrefix:@"category://"])
    {
        //分析并下载存储图片资源
        NSArray *products = [dataDic objectForKey:@"products"];
        if(!products || ![products isKindOfClass:[NSArray class]] || [products count] == 0) return nil;
        
        for(NSDictionary *pdic in products)
        {
            NSString *imgUrl = [pdic objectForKey:@"image_url"];
            if(imgUrl && [imgUrl isKindOfClass:[NSString class]] && ![link isEqualToString:@""])
            {
                [urls addObject:imgUrl];
            }
        }
    }
    else if([link hasPrefix:@"product://"])
    {
        //获取4张轮播图
        NSDictionary *infoDic = [dataDic objectForKey:@"product_info_new"];
        NSArray *images = [infoDic objectForKey:@"images_big"];
        if(images && images.count != 0)
        {
            urls = [NSMutableArray arrayWithArray:images];
        }
        
        //追加一张店铺logo图
        NSDictionary *shopDic = [dataDic objectForKey:@"shop_info"];
        NSString *logoUrl = [shopDic objectForKey:@"shop_logo"];
        if(logoUrl)
        {
            [urls addObject:logoUrl];
        }
    }
    
    return urls;
}

- (NSString*)getProperty:(NSString*)propertyName formLinkURL:(NSString*)linkURL
{
    //从linkURL里拆分出pageID，如 cms://page_id=9527&seq=1,从中拆分出page_id的内容是9527
    if(!linkURL || [linkURL compare:@""] == NSOrderedSame) return nil;
    if(!propertyName || [propertyName compare:@""] == NSOrderedSame) return nil;
    
    //找到://后面的部分串
    NSRange range = [linkURL rangeOfString:@"://"];
    if(range.length == 0) return nil;
    
    NSString *paramsString = [linkURL substringFromIndex:(range.location+range.length)]; //page_id=9527&seq=1
    if(!paramsString || [paramsString compare:@""] == NSOrderedSame) return nil;
    
    NSArray *params = [paramsString componentsSeparatedByString:@"&"];
    if(!params || [params count] == 0) return nil;
    
    
    NSString *property = nil;
    
    for(NSString *par in params) //page_id=9527 和 seq=1
    {
        
        NSArray *keyAndValue = [par componentsSeparatedByString:@"="];
        
        if(!keyAndValue || [keyAndValue count] != 2) continue;
        if([[keyAndValue objectAtIndex:0] isEqualToString:propertyName])
        {
            property = [keyAndValue objectAtIndex:1];
        }
    }
    
    return property;
}


//根据发送过来的payload，同步更新一下用户信息
- (void)syncUserInfomationsForPayload:(NSDictionary*)payload
{
    if(!DICTIONARYVALID(payload)) return;
    
    NSString *from_userid = [DDFunction getValueForKey:@"from_userid" inData:payload];
    if(!STRVALID(from_userid)) return;
    
    NSString *from_token = [DDFunction getValueForKey:@"from_token" inData:payload];
    if(!STRVALID(from_token)) return;
    
    BOOL exist = [[DataCenter sharedCenter] checkUserExist:from_userid];
    if(!exist) return;
    
    NSString *savedToken = [[DataCenter sharedCenter] userInfoForId:from_userid onitem:@"device_token"];
    if(STRVALID(savedToken) && [savedToken isEqualToString:from_token]) return;
    
    //更新token
    [[DataCenter sharedCenter] updateUserInfo:from_userid onitem:@"device_token" useinfo:from_token];
}



@end












