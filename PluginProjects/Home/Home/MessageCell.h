//
//  MessageCell.h
//  Radar Use
//
//  Created by Radar on 11-5-3.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//data结构：在DataCenter.h里边看


@interface MessageCell : UITableViewCell {

	
}

#pragma mark -
#pragma mark in use functions



#pragma mark -
#pragma mark out use functions
-(void)setCellData:(id)data atIndexPath:(NSIndexPath*)indexPath; //{"notifyid":"xxx", "receivetime":"xxxx", "payload":{xxxxxx}}

- (void)flashCell; //让cell闪动一下
//- (void)recoverState; //第二条以后恢复原始状态

- (BOOL)checkNeedsBlankForNotifytoken:(id)data; //根据notifyToken指定的消息，来判断这条消息与上一条消息之间是否需要添加分块空白


@end
