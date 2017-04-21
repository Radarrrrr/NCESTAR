//
//  MessageCell.m
//  Radar Use
//
//  Created by Radar on 11-5-3.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define default_cell_height 200

#import "MessageCell.h"


@interface MessageCell ()

@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *faceView;

@end


@implementation MessageCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
        
        //添加一个背景框
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, SCR_WIDTH-16, default_cell_height-8)];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.alpha = 0.25;
        _backView.userInteractionEnabled = NO;
        [DDFunction addRadiusToView:_backView radius:25];
        [self.contentView addSubview:_backView];
        
        //添加头像
        self.faceView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_backView.frame)+8, 16, 60, 60)];
        _faceView.backgroundColor = [UIColor clearColor];
        [DDFunction addRadiusToView:_faceView radius:25];
        _faceView.image = [UIImage imageNamed:@"face_ma.png" forUser:self];
        [self.contentView addSubview:_faceView];
        
		//add _tLabel
		self.msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
		_msgLabel.backgroundColor = [UIColor clearColor];
		_msgLabel.textAlignment = NSTextAlignmentCenter;
		_msgLabel.font = [UIFont boldSystemFontOfSize:16.0];
		_msgLabel.textColor = [UIColor redColor];
		[self.contentView addSubview:_msgLabel];
		
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //add line
        //[DDFunction addLineToViewBottom:self.contentView useColor:DDCOLOR_LINE_B];
        
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
    NSString *msg = (NSString*)[DDFunction getValueForKey:@"body" inData:data];
    if(!STRVALID(msg)) return;

	_msgLabel.text = msg;
	
	//设定contentview的高度，这个很重要，关系到外部tableview的cell的高度设定多高，那个高度就是从这里来的
	float height = default_cell_height;
    
    //改变背景高度
//    CGRect bframe = _backView.frame;
//    bframe.size.height = 150;
//    _backView.frame = bframe;
//    
//    height = 160;
    
    
    //最下面这段用来给DDTableView容器使用，无须更改。
	CGRect newRect = self.contentView.frame;
	newRect.size.height = height;
	
	self.contentView.frame = newRect;
	self.frame = newRect;
}




@end
