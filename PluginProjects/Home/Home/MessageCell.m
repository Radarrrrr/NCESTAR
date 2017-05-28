//
//  MessageCell.m
//  Radar Use
//
//  Created by Radar on 11-5-3.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#define MessageCell_default_cell_height 200
#define MessageCell_face_width 45
#define MessageCell_limit_msglabel_height 30
#define MessageCell_msg_font        DDFONT(15)


#import "MessageCell.h"


@interface MessageCell ()

@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *faceView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, copy)   NSString *selfDeviceToken; 

@end


@implementation MessageCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
        
        //保存一下本机的token，用来做判断
        self.selfDeviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_SELF_DEVICE_TOKEN];
        
        //添加一个背景框
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, SCR_WIDTH-16, MessageCell_default_cell_height-8)];
        _backView.backgroundColor = RGBS(240);
        _backView.alpha = 0.8;
        _backView.userInteractionEnabled = NO;
        [DDFunction addRadiusToView:_backView radius:14];
        [self.contentView addSubview:_backView];
        
        //添加头像
        self.faceView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_backView.frame)+8, CGRectGetMaxY(_backView.frame)-8-MessageCell_face_width, MessageCell_face_width, MessageCell_face_width)];
        _faceView.backgroundColor = [UIColor clearColor];
        [DDFunction addRadiusToView:_faceView radius:15];
        _faceView.image = [UIImage imageNamed:@"face_star.png" forme:self];
        [self.contentView addSubview:_faceView];
  
		//add _tLabel
		self.msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_backView.frame)+8, CGRectGetMinY(_backView.frame)+8, CGRectGetWidth(_backView.frame)-8-8-MessageCell_face_width-5, CGRectGetHeight(_backView.frame)-8-10-MessageCell_face_width)];
		_msgLabel.backgroundColor = [UIColor clearColor];
		_msgLabel.font = MessageCell_msg_font;
		_msgLabel.textColor = DDCOLOR_TEXT_A;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _msgLabel.numberOfLines = 0;
        _msgLabel.userInteractionEnabled = NO;
		[self.contentView addSubview:_msgLabel];
		
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //add line
        self.line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_faceView.frame)+MessageCell_face_width+8, CGRectGetMinY(_faceView.frame)+14, CGRectGetWidth(_backView.frame)-24-MessageCell_face_width-2, 0.5)];
        _line.userInteractionEnabled = NO;
        _line.backgroundColor = RGBS(200);
        [self.contentView addSubview:_line];
        
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
-(void)setCellData:(id)data atIndexPath:(NSIndexPath*)indexPath
{
    NSString *msg = (NSString*)[DDFunction getValueForKey:@"body" inData:data];
    if(!STRVALID(msg)) return;

	_msgLabel.text = msg;
    

    //判断是不是自己发出去的消息
    BOOL isMymsg = NO;
    
    NSString *fromToken = (NSString*)[DDFunction getValueForKey:@"from_token" inData:data];
    if(STRVALID(_selfDeviceToken) && STRVALID(fromToken) && [_selfDeviceToken isEqualToString:fromToken])
    {
        isMymsg = YES;
    }
    
    
    //修改发送人的头像
    if(STRVALID(fromToken))
    {
        NSString *faceid = [[DataCenter sharedCenter] userInfoForToken:fromToken item:@"face_id"];
        if(!STRVALID(faceid)) faceid = @"star";
        
        NSString *facepicN = [NSString stringWithFormat:@"face_%@.png", faceid];
        _faceView.image = [UIImage imageNamed:facepicN forme:self];
    }
    else
    {
        _faceView.image = [UIImage imageNamed:@"face_star.png" forme:self];
    }
    
    
    //获取文字高度和宽度
    float msgHeight = [DDFunction getHeightForString:msg font:MessageCell_msg_font width:CGRectGetWidth(_msgLabel.frame)];
    if(msgHeight < MessageCell_limit_msglabel_height)
    {
        msgHeight = MessageCell_limit_msglabel_height;
    }
    
    //修改各个组件高度
    float backDelta = 20.0; //头像和背景之间的偏移量
    
    //计算消息文字宽高行数，暂时不删除
//    float msgWidth = [DDFunction getWidthForString:msg font:MessageCell_msg_font height:CGRectGetHeight(_msgLabel.frame)];
//    NSInteger lines = [DDFunction getLinesForString:msg font:MessageCell_msg_font width:CGRectGetWidth(_msgLabel.frame)];
//    if(lines<=1 && (msgWidth > CGRectGetWidth(_backView.frame)-8*2-MessageCell_face_width*2))
//    {
//        backDelta = 0.0;
//    }
    
    [DDFunction changeHeightForView:_msgLabel to:msgHeight];
    
    float backHeight = msgHeight+8+MessageCell_face_width+8-backDelta;
    [DDFunction changeHeightForView:_backView to:backHeight];
    
    if(!isMymsg)
    {
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        CGRect mframe = _msgLabel.frame;
        mframe.origin.x = CGRectGetMinX(_backView.frame)+8+MessageCell_face_width+5;
        _msgLabel.frame = mframe;
        
        CGRect fframe = _faceView.frame;
        fframe.origin.y = CGRectGetMaxY(_backView.frame)-8-MessageCell_face_width;
        fframe.origin.x = CGRectGetMinX(_backView.frame)+8;
        _faceView.frame = fframe;
        
        CGRect lframe = _line.frame;
        lframe.origin.y = CGRectGetMinY(_faceView.frame)+30;
        lframe.origin.x = CGRectGetMinX(_faceView.frame)+MessageCell_face_width+8;
        _line.frame = lframe;
    }
    else
    {
        _msgLabel.textAlignment = NSTextAlignmentRight;
        CGRect mframe = _msgLabel.frame;
        mframe.origin.x = CGRectGetMinX(_backView.frame)+8;
        _msgLabel.frame = mframe;
        
        CGRect fframe = _faceView.frame;
        fframe.origin.y = CGRectGetMaxY(_backView.frame)-8-MessageCell_face_width;
        fframe.origin.x = CGRectGetMaxX(_backView.frame)-8-MessageCell_face_width;
        _faceView.frame = fframe;
        
        CGRect lframe = _line.frame;
        lframe.origin.y = CGRectGetMinY(_faceView.frame)+30;
        lframe.origin.x = CGRectGetMinX(_faceView.frame)-8-lframe.size.width;
        _line.frame = lframe;
    }
    
    //设定contentview的高度，这个很重要，关系到外部tableview的cell的高度设定多高，那个高度就是从这里来的
    float height = backHeight + 8;
        
    //最下面这段用来给DDTableView容器使用，无须更改。
	CGRect newRect = self.contentView.frame;
	newRect.size.height = height;
	
	self.contentView.frame = newRect;
	self.frame = newRect;
}

- (void)flashCell
{
    //让背景view闪动    
    [UIView animateWithDuration:0.5 
                     animations:^{
                         //_backView.alpha = 0.0;
                         _backView.backgroundColor = RGB(255, 249, 206);
                     } 
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.5 
                                          animations:^{
                                              //_backView.alpha = 1.0;
                                              _backView.backgroundColor = RGBS(240);
                                          } 
                                          completion:^(BOOL finished) {
                                              
                                              [UIView animateWithDuration:0.5 
                                                               animations:^{
                                                                   //_backView.alpha = 0.0;
                                                                   _backView.backgroundColor = RGB(255, 249, 206);
                                                               } 
                                                               completion:^(BOOL finished) {
                                                                   
                                                                   [UIView animateWithDuration:0.5 
                                                                                    animations:^{
                                                                                        //_backView.alpha = 1.0;
                                                                                        _backView.backgroundColor = RGBS(240);
                                                                                    } 
                                                                                    completion:^(BOOL finished) {
                                                                                    }];
                                                                   
                                                               }];
                                          }];
                         
                     }];
}


//- (void)recoverState
//{
//    [UIView animateWithDuration:0.25 animations:^{
//        _backView.backgroundColor = RGBS(240);
//        _line.backgroundColor = RGBS(200);
//    }];
//    
//}


@end
