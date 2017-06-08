//
//  DDMacros.h
//  ThirdSDKs
//
//  Created by Radar on 2017/4/20.
//  Copyright © 2017年 Radar. All rights reserved.
//

#pragma mark -
#pragma mark 一些通用的宏，用来全局使用，统一改动
#define SAVED_SELF_DEVICE_TOKEN @"saved self device token"  //存储本机的devicetoken

//消息类型，随payload发送
#define MSG_TYPE_MESSAGE        @"message"      //标准信息
#define MSG_TYPE_CONFIRM        @"confirm"      //确认信息
#define MSG_TYPE_ATTENTION      @"attention"    //提醒注意信息



#pragma mark - 
#pragma mark 远程通知相关



#pragma mark - 
#pragma mark 本地通知相关




#pragma mark - 
#pragma mark 字体和颜色相关

//颜色和字体相关的宏
#define RGB(r, g, b)        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBS(x)             [UIColor colorWithRed:x/255.0 green:x/255.0 blue:x/255.0 alpha:1.0]
#define RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define DDFONT(x)   [UIFont systemFontOfSize:x]
#define DDFONT_B(x) [UIFont boldSystemFontOfSize:x]
#define CUSFONT(x)  [UIFont fontWithName:@"DFPWaWaW7-B5" size:x] 


//新的套装颜色以后都替换成这里的，除此之外的其他特殊颜色，都使用RGB(r, g, b)或者RGBA(r, g, b, a)在页面内部实现
//文字颜色
#define DDCOLOR_TEXT_A          [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f]
#define DDCOLOR_TEXT_B          [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]
#define DDCOLOR_TEXT_C          [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f]

//文字输入框placeholder颜色
#define DDCOLOR_PLACE_HOLDER    [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f]

//分隔线颜色
#define DDCOLOR_LINE_A          [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f]
#define DDCOLOR_LINE_B          [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f]

//描边使用的颜色
#define DDCOLOR_BORDER          [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]

//背景颜色
#define DDCOLOR_CELL_SELECT     [UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1.0f]
#define DDCOLOR_BACK_GROUND     [UIColor colorWithRed:250.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f]

//蓝灰色背景颜色
#define DDCOLOR_BLUE_GRAY_BACK_GROUND     [UIColor colorWithRed:235.0f/255.0f green:240.0f/255.0f blue:243.0f/255.0f alpha:1.0f]

//标题栏背景颜色
#define DDCOLOR_TITLEBAR_BACK_GROUND     [UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1.0f]

//规定的特殊颜色
#define DDCOLOR_ORANGE          [UIColor colorWithRed:255.0f/255.0f green:150.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
#define DDCOLOR_BLUE            [UIColor colorWithRed:50.0f/255.0f green:220.0f/255.0f blue:210.0f/255.0f alpha:1.0f]
#define DDCOLOR_RED             [UIColor colorWithRed:255.0f/255.0f green:30.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
#define DDCOLOR_GOLD            [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:126.0f/255.0f alpha:1.0f]

//下拉水滴颜色
#define DDCOLOR_DROP_REFRESH    [UIColor colorWithRed:50.0f/255.0f green:220.0f/255.0f blue:210.0f/255.0f alpha:1.0f]




#pragma mark -
#pragma mark 实用工具

#define IS_IOS7_ORLATER     [DDFunction isiOS7orLater]          //判断当前操作系统是否iOS7以上
#define IS_FAST_DEVICE      [DDUIUtils checkIsFastDevice]       //用来判断是否是快机器
#define STRVALID(str)       [DDFunction checkStringValid:str]   //检查一个字符串是否有效
#define ARRAYVALID(array)   [DDFunction checkArrayValid:array]  //检查一个数组是否有效
#define DICTIONARYVALID(dict)   [DDFunction checkDictionaryValid:dict]  //检查一个数组是否有效
#define CHECKINARRAY(index, array) [DDFunction checkInArrayOfIndex:index ofArray:array] //检查一个index是否在数组的区域内

//从mainBundle中 拿图片
#define ImageFromResource(x) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:x ofType:nil]]

//获取屏幕高度
#define SCR_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCR_WIDTH  [UIScreen mainScreen].bounds.size.width




#import <Foundation/Foundation.h>

@interface DDMacros : NSObject

@end
