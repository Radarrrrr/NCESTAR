//
//  CHKeyChain.h
//  ddDemo
//
//  Created by dangdang on 14-3-13.
//  Copyright (c) 2014年 DangDang. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface CHKeyChain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)remove:(NSString *)service;

@end
