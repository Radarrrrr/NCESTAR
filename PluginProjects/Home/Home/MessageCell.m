//
//  MessageCell.m
//  Radar Use
//
//  Created by Radar on 11-5-3.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageCell.h"


@implementation MessageCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		//add _tLabel
		_tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
		_tLabel.backgroundColor = [UIColor clearColor];
		_tLabel.textAlignment = NSTextAlignmentCenter;
		_tLabel.font = [UIFont boldSystemFontOfSize:16.0];
		_tLabel.textColor = [UIColor redColor];
		[self.contentView addSubview:_tLabel];
		
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}






#pragma mark -
#pragma mark in use functions



#pragma mark -
#pragma mark out use functions
-(void)setCellData:(id)data
{
	NSString *tString = (NSString*)data;
	if(tString == nil || [tString compare:@""] == NSOrderedSame) return;
	
	_tLabel.text = tString;
	
	//设定contentview的高度，这个很重要，关系到外部tableview的cell的高度设定多高，那个高度就是从这里来的
	float height = 44.0;
	
	CGRect newRect = self.contentView.frame;
	newRect.size.height = height;
	
	self.contentView.frame = newRect;
	self.frame = newRect;
}




@end
