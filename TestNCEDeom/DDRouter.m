//
//  DDRouter.m
//  TestNCEDeom
//
//  Created by Radar on 2017/3/16.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import "DDRouter.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "RDQRCodeScaner.h"


@implementation DDRouter


#pragma mark - 配套方法
+ (NSString*)valueForKey:(NSString *)key ofURL:(NSString*)url
{
    if(!key || [key compare:@""] == NSOrderedSame) return nil;
    if(!url || [url compare:@""] == NSOrderedSame) return nil;
    
    //做一个query
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *query = [[request URL] query];
    if(!query || [query compare:@""] == NSOrderedSame) return nil;
    
    //找到key对应的value
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    for(NSString *aPair in pairs)
    {
        NSArray *keyAndValue = [aPair componentsSeparatedByString:@"="];
        if([keyAndValue count] != 2) continue;
        if([[keyAndValue objectAtIndex:0] isEqualToString:key])
        {
            return [keyAndValue objectAtIndex:1];
        }
    }
    
    return nil;
}

+ (NSString*)getProperty:(NSString*)propertyName formLinkURL:(NSString*)linkURL
{
    //从linkURL里拆分出pageID，如 cms://page_id=9527&seq=1,从中拆分出page_id的内容是9527
    if(!linkURL || [linkURL compare:@""] == NSOrderedSame) return nil;
    if(!propertyName || [propertyName compare:@""] == NSOrderedSame) return nil;
    
    //做一个query,判断这个linkURL，是否是带有问号的那种，区别处理
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:linkURL]];
    NSString *query = [[request URL] query];
    if(query && [query compare:@""]!= NSOrderedSame)
    {
        //有问号
        NSString *property = [self valueForKey:propertyName ofURL:linkURL];
        return property;
    }
    
    //没问号
    
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

+ (void)handleQRCode:(NSString*)qrcode
{
    if(!STRVALID(qrcode)) return;
    
    NSString *linkUrl = qrcode;
    
    //如果没有://的字样，则当作普通文字串处理，放到一个空白页面中显示
    NSRange range = [qrcode rangeOfString:@"://"];
    if(range.length == 0)
    {
        linkUrl = [NSString stringWithFormat:@"plaintext://text=%@", qrcode];
    }
    
    [DDRouter actionForLinkURL:linkUrl];
}



#pragma mark - 控制器方法
+ (void)actionForLinkURL:(NSString*)linkURL
{
    if(!STRVALID(linkURL)) return;
    
    AppDelegate *appDele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navController  = (UINavigationController *)appDele.mainNav;
    UIViewController *topVC = navController.topViewController;
    
    //全部小写处理，去掉回车和前后空白
    linkURL = [linkURL lowercaseString];
    linkURL = [linkURL stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    linkURL = [linkURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //处理跳转逻辑
    if([linkURL hasPrefix:@"connectapns://"]) //连接APNs服务器，disconnectneed参数表示是否需要先断开连接再重连 0/1
    {
        //connectapns://disconnectneed=0 
        NSString *disconnectneed = [self getProperty:@"disconnectneed" formLinkURL:linkURL];
        [appDele connectAPNsServer:disconnectneed];
    }
    else if([linkURL hasPrefix:@"setting://"]) //进入setting页面
    {
        //setting://
        SettingViewController *settingVC = [[SettingViewController alloc] init];
        [navController pushViewController:settingVC animated:YES];
    }
    else if([linkURL hasPrefix:@"pushsimulator://"]) //打开推送模拟器
    {
        //pushsimulator://
        RDPushSimuVC *simuVC = [[RDPushSimuVC alloc] init];
        [navController pushViewController:simuVC animated:YES];
    }
    else if([linkURL hasPrefix:@"qrscaner://"]) //打开二维码扫描器
    {
        //qrscaner://
        [RDQRCodeScaner pushToOpenScanner:navController completion:^(NSString *qrcode) {
            NSLog(@"二维码：%@", qrcode);
            [self handleQRCode:qrcode];
        }];
    }
    else if([linkURL hasPrefix:@"http://"] || [linkURL hasPrefix:@"https://"]) //http和https都直接开启web页面显示
    {
        //http:// & https://
        //TO DO: //http和https都直接开启web页面显示
        
    }
    else if([linkURL hasPrefix:@"plaintext://"]) //进入空白文字页面，用于二维码扫描以后直接显示二维码中的内容
    {
        //plaintext://text=xxxx
        //TO DO: 进入空白文字页面，用于二维码扫描以后直接显示二维码中的内容
        
    }
    else if([linkURL hasPrefix:@"friendcode://"]) //扫描二维码获得的好友信息，如果是已经添加的好友，则覆盖修改本地存储的信息
    {
        //friendcode://info=xxxx
        //TO DO: ///扫描二维码获得的好友信息，如果是已经添加的好友，则覆盖修改本地存储的信息
        
    }
     
    
}






@end
