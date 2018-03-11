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
@property (nonatomic, copy)   NSString *selfUserId; 
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *blankLabel;

@end


@implementation MessageCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
        
        //保存一下本机的token，用来做判断
        self.selfUserId = [[DataCenter sharedCenter] myInfoOnItem:@"user_id"];
        
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
		self.msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_backView.frame)+8, CGRectGetMinY(_backView.frame)+8, CGRectGetWidth(_backView.frame)-8-8-MessageCell_face_width-10, CGRectGetHeight(_backView.frame)-8-10-MessageCell_face_width)];
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
        
        //add timeLabel
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_faceView.frame)+8, CGRectGetMinY(_line.frame)+2, CGRectGetWidth(_backView.frame)-MessageCell_face_width*2-8*4, 20)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.userInteractionEnabled = NO;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.textColor = DDCOLOR_TEXT_C;
        _timeLabel.font = DDFONT(12);
        [self.contentView addSubview:_timeLabel];
        
        
        //add lastBlank date
        self.blankLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_backView.frame)+8, SCR_WIDTH, 20)];
        _blankLabel.backgroundColor = [UIColor clearColor];
        _blankLabel.userInteractionEnabled = NO;
        _blankLabel.textAlignment = NSTextAlignmentCenter;
        _blankLabel.textColor = RGBS(200);
        _blankLabel.font = DDFONT(12);
        _blankLabel.text = nil;
        [self.contentView addSubview:_blankLabel];
    
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
    //设定msg
    NSString *msg = (NSString*)[DDFunction getValueForKey:@"body" inData:data];
    _msgLabel.text = msg;
    
    //设定时间
    NSString *sendtime = (NSString*)[DDFunction getValueForKey:@"sendtime" inData:data];
    NSDate *sendDate = [DDFunction dateFromString:sendtime useFormat:@"YY-MM-dd HH:mm:ss"];
    NSTimeInterval delta = -[sendDate timeIntervalSinceNow];  //发送时间距离现在的时间偏移量
    
    if(STRVALID(sendtime))
    {
        if(delta <= 60*60*24)
        {
            NSRange range = [sendtime rangeOfString:@" "];
            if(range.length)
            {
                sendtime = [sendtime substringFromIndex:range.location+1];
            }
        }
        
        _timeLabel.text = sendtime;
    }

    //判断是不是自己发出去的消息
    BOOL isMymsg = NO;
    
    NSString *fromUserId = (NSString*)[DDFunction getValueForKey:@"from_userid" inData:data];
    if(STRVALID(_selfUserId) && STRVALID(fromUserId) && [_selfUserId isEqualToString:fromUserId])
    {
        isMymsg = YES;
    }
    
    
    //修改发送人的头像
    if(STRVALID(fromUserId))
    {
        NSString *faceid = [[DataCenter sharedCenter] userInfoForId:fromUserId onitem:@"face_id"];
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
    float backDelta = 25.0; //头像和背景之间的偏移量
    
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
        //不是自己发出去的消息
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        CGRect mframe = _msgLabel.frame;
        mframe.origin.x = CGRectGetMinX(_backView.frame)+8+MessageCell_face_width+8;
        _msgLabel.frame = mframe;
        
        CGRect fframe = _faceView.frame;
        fframe.origin.y = CGRectGetMaxY(_backView.frame)-8-MessageCell_face_width;
        fframe.origin.x = CGRectGetMinX(_backView.frame)+8;
        _faceView.frame = fframe;
        
        CGRect lframe = _line.frame;
        lframe.origin.y = CGRectGetMinY(_faceView.frame)+30;
        lframe.origin.x = CGRectGetMinX(_faceView.frame)+MessageCell_face_width+8;
        _line.frame = lframe;
        
        CGRect tframe = _timeLabel.frame;
        tframe.origin.y = CGRectGetMinY(_line.frame)+2;
        _timeLabel.frame = tframe;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        //自己发出去的消息
        CGSize msgSize = [_msgLabel.text sizeWithFont:MessageCell_msg_font constrainedToSize:_msgLabel.frame.size];
        
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        CGRect mframe = _msgLabel.frame;
        mframe.origin.x = CGRectGetMinX(_backView.frame)+(CGRectGetWidth(_backView.frame)-8-MessageCell_face_width-8-msgSize.width);
        _msgLabel.frame = mframe;
        
        CGRect fframe = _faceView.frame;
        fframe.origin.y = CGRectGetMaxY(_backView.frame)-8-MessageCell_face_width;
        fframe.origin.x = CGRectGetMaxX(_backView.frame)-8-MessageCell_face_width;
        _faceView.frame = fframe;
        
        CGRect lframe = _line.frame;
        lframe.origin.y = CGRectGetMinY(_faceView.frame)+30;
        lframe.origin.x = CGRectGetMinX(_faceView.frame)-8-lframe.size.width;
        _line.frame = lframe;
        
        CGRect tframe = _timeLabel.frame;
        tframe.origin.y = CGRectGetMinY(_line.frame)+2;
        _timeLabel.frame = tframe;
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    
    //设定contentview的高度，这个很重要，关系到外部tableview的cell的高度设定多高，那个高度就是从这里来的
    float height = backHeight + 8;
    
    
    //修改空白时间区域的位置
    CGRect bframe = _blankLabel.frame;
    bframe.origin.y = CGRectGetMaxY(_backView.frame)+8;
    _blankLabel.frame = bframe;
    
    //根据本条信息和上条信息的时间差，决定是否增加空白，以便把聊天记录分块显示
    NSString *blankStr = [self checkNeedsBlankForMsgData:data];
    if(STRVALID(blankStr))
    {
        height += 20;
        _blankLabel.text = blankStr;
    }
    else
    {
        _blankLabel.text = nil;
    }
    
        
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



- (NSString *)checkNeedsBlankForMsgData:(id)data
{
    //根据notifyToken指定的消息，来判断这条消息与上一条消息之间是否需要添加分块空白
    if(!data) return nil;
    
    //获取本条信息的check时间
    NSString *myCheckTime = (NSString*)[DDFunction getValueForKey:@"receivetime" inData:data];
    if(!STRVALID(myCheckTime)) 
    {
        myCheckTime = (NSString*)[DDFunction getValueForKey:@"sendtime" inData:data];
    }
    
    if(!STRVALID(myCheckTime)) return nil;
    
    //获取本条的前一条信息的check时间
    NSArray *allMsgs = [[DataCenter sharedCenter] getAllMessages]; //时间正序的，最新的在最后面
    if(!ARRAYVALID(allMsgs)) return nil;
    
    //定位本条信息
    NSInteger myindex = -1;
    NSString *mytoken = (NSString*)[DDFunction getValueForKey:@"notifytoken" inData:data];
    
    for(int i=0; i<[allMsgs count]; i++)
    {
        id msg = [allMsgs objectAtIndex:i];
        NSString *token = (NSString*)[DDFunction getValueForKey:@"notifytoken" inData:msg];
        
        if(STRVALID(token) && [token isEqualToString:mytoken])
        {
            myindex = i;
            break;
        }
    }
    
    if(myindex <= 0) return nil;
    
    
    //找到本条信息的上一条
    NSInteger preindex = myindex - 1;    
    id preMsg = [allMsgs objectAtIndex:preindex];
    if(!preMsg) return nil;
    
    
    //获取上一条信息的checktime
    NSString *preCheckTime = (NSString*)[DDFunction getValueForKey:@"receivetime" inData:preMsg];
    if(!STRVALID(preCheckTime)) 
    {
        preCheckTime = (NSString*)[DDFunction getValueForKey:@"sendtime" inData:preMsg];
    }
    
    if(!STRVALID(preCheckTime)) return nil;
    
    //对比myCheckTime和preCheckTime，判断是否需要添加时间块空白
    NSDate *mydate  = [DDFunction dateFromString:myCheckTime useFormat:@"YY-MM-dd HH:mm:ss"];
    NSDate *predate = [DDFunction dateFromString:preCheckTime useFormat:@"YY-MM-dd HH:mm:ss"];
    
    NSTimeInterval delta = [mydate timeIntervalSinceDate:predate];
    if(delta >= MSGLIST_TIME_BLOCK_DELTA)
    {
        //如果时间差超过了预设，则返回上一次信息的日期
        return [DDFunction stringFromDate:predate useFormat:@"YYYY-MM-dd"];
    }
    
    return nil;
}


//- (BOOL)checkNeedsBlankForMsgData:(id)data
//{
//    //根据notifyToken指定的消息，来判断这条消息与上一条消息之间是否需要添加分块空白
//    if(!data) return NO;
//    
//    //获取本条信息的check时间
//    NSString *myCheckTime = (NSString*)[DDFunction getValueForKey:@"receivetime" inData:data];
//    if(!STRVALID(myCheckTime)) 
//    {
//        myCheckTime = (NSString*)[DDFunction getValueForKey:@"sendtime" inData:data];
//    }
//    
//    if(!STRVALID(myCheckTime)) return NO;
//    
//    //获取本条的前一条信息的check时间
//    NSArray *allMsgs = [[DataCenter sharedCenter] getAllMessages]; //时间正序的，最新的在最后面
//    if(!ARRAYVALID(allMsgs)) return NO;
//    
//    //定位本条信息
//    NSInteger myindex = -1;
//    NSString *mytoken = (NSString*)[DDFunction getValueForKey:@"notifytoken" inData:data];
//    
//    for(int i=0; i<[allMsgs count]; i++)
//    {
//        id msg = [allMsgs objectAtIndex:i];
//        NSString *token = (NSString*)[DDFunction getValueForKey:@"notifytoken" inData:msg];
//        
//        if(STRVALID(token) && [token isEqualToString:mytoken])
//        {
//            myindex = i;
//            break;
//        }
//    }
//    
//    if(myindex <= 0) return NO;
//    
//    
//    //找到本条信息的上一条
//    NSInteger preindex = myindex - 1;    
//    id preMsg = [allMsgs objectAtIndex:preindex];
//    if(!preMsg) return NO;
//
//    
//    //获取上一条信息的checktime
//    NSString *preCheckTime = (NSString*)[DDFunction getValueForKey:@"receivetime" inData:preMsg];
//    if(!STRVALID(preCheckTime)) 
//    {
//        preCheckTime = (NSString*)[DDFunction getValueForKey:@"sendtime" inData:preMsg];
//    }
//    
//    if(!STRVALID(preCheckTime)) return NO;
//    
//    //对比myCheckTime和preCheckTime，判断是否需要添加时间块空白
//    NSDate *mydate  = [DDFunction dateFromString:myCheckTime useFormat:@"YY-MM-dd HH:mm:ss"];
//    NSDate *predate = [DDFunction dateFromString:preCheckTime useFormat:@"YY-MM-dd HH:mm:ss"];
//    
//    NSTimeInterval delta = [mydate timeIntervalSinceDate:predate];
//    if(delta >= MSGLIST_TIME_BLOCK_DELTA)
//    {
//        return YES;
//    }
//    
//    return NO;
//}


@end
