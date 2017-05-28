//
//  AudioPlayer.h
//  SohuColor
//
//  Created by Radar on 11-5-5.
//  Copyright 2011 sohu.com. All rights reserved.
//
// PS: 需要添加两个FrameWork :  AudioToolbox.framework 和 AVFoundation.framework

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@class AudioPlayer;
@protocol AudioPlayerDelegate <NSObject>
@optional
- (void)audioPlayerDidStartPlaying:(AudioPlayer*)audioPlayer;
- (void)audioPlayerDidPausePlaying:(AudioPlayer*)audioPlayer;
- (void)audioPlayerDidFinishPlaying:(AudioPlayer*)audioPlayer;

- (void)audioPlayerReplayStart:(AudioPlayer*)audioPlayer;
@end


@interface AudioPlayer : NSObject <AVAudioPlayerDelegate> {

	AVAudioPlayer *avPlayer;
	NSURL *mAudioFileURL;
	BOOL _bLoop;
	
@private
	id _delegate;		
}

@property (assign) id<AudioPlayerDelegate> delegate;
@property (nonatomic, retain) AVAudioPlayer *avPlayer;
@property (nonatomic, retain) NSURL *mAudioFileURL;

+ (AudioPlayer *)sharedAudioPlayer; //可以不用单实例，alloc方式也可以



#pragma mark -
#pragma mark in use functions
-(void)shutPlayer;



#pragma mark -
#pragma mark out use functions
//这两个函数分别使用，看参数是什么
-(void)setAudio:(NSString*)audio withType:(NSString*)type withLoop:(BOOL)bLoop; //type里边不带“.” 
-(void)setLocalURLAudio:(NSString*)audioPath withLoop:(BOOL)bLoop; //only can support the local file URL, not support the http URL

-(void)play;
-(void)stop;
-(void)pause;


@end
