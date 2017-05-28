//
//  AudioPlayer.m
//  SohuColor
//
//  Created by Radar on 11-5-5.
//  Copyright 2011 sohu.com. All rights reserved.
//

#import "AudioPlayer.h"

static AudioPlayer *_sharedAudioPlayer;


@implementation AudioPlayer
@synthesize delegate=_delegate;
@synthesize avPlayer;
@synthesize mAudioFileURL;

#pragma mark -
#pragma mark system functions

+ (AudioPlayer *)sharedAudioPlayer
{
	if (!_sharedAudioPlayer) {
		_sharedAudioPlayer = [[AudioPlayer alloc] init];
	}
	return _sharedAudioPlayer;
}


- (void)dealloc
{		
	if(self.avPlayer && self.avPlayer.playing)
	{
		[self.avPlayer stop];
	}
	[avPlayer release];
	
	[mAudioFileURL release];
	[_sharedAudioPlayer release];
	
	[super dealloc];
}




#pragma mark -
#pragma mark in use functions
-(void)shutPlayer
{
	if(!self.avPlayer) return;
	if(self.avPlayer.playing)
	{
		[self.avPlayer stop];
	}
	
	self.avPlayer = nil;
}



#pragma mark -
#pragma mark out use functions
-(void)setAudio:(NSString*)audio withType:(NSString*)type withLoop:(BOOL)bLoop
{
	_bLoop = bLoop;
	
	NSString *audioPath = [[NSBundle mainBundle] pathForResource:audio ofType:type];
	if(audioPath == nil) 
	{
		self.mAudioFileURL = nil;
		return;
	}
	
	NSURL *fileURL = [[[NSURL alloc] initFileURLWithPath:audioPath] autorelease];
	self.mAudioFileURL = fileURL;
}
-(void)setLocalURLAudio:(NSString*)audioPath withLoop:(BOOL)bLoop
{
	_bLoop = bLoop;
	
	if(audioPath == nil) 
	{
		self.mAudioFileURL = nil;
		return;
	}
	
	NSURL *fileURL = [[[NSURL alloc] initFileURLWithPath:audioPath] autorelease];
	self.mAudioFileURL = fileURL;
}

-(void)play
{
	if(self.avPlayer && self.avPlayer.url) //resmue播放
	{
		[self.avPlayer play];
	}
	else								   //播放新的
	{
		[self shutPlayer];
		
		//init avPlayer
		if(self.avPlayer == nil)
		{
			AVAudioPlayer *aPlayer = [[AVAudioPlayer alloc] init];
			self.avPlayer = aPlayer;
			[aPlayer release];
		}
		self.avPlayer = [avPlayer initWithContentsOfURL:self.mAudioFileURL error:nil];
		self.avPlayer.delegate = self;
		
		[self.avPlayer play];
	}
	
	//返回给代理
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(audioPlayerDidStartPlaying:)])
	{
		[self.delegate audioPlayerDidStartPlaying:self];
	}

}
-(void)stop
{
	if(!self.avPlayer) return;
	if(self.avPlayer.playing)
	{
		[self.avPlayer stop];
	}

	self.avPlayer = nil;
	
	//返回给代理
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)])
	{
		[self.delegate audioPlayerDidFinishPlaying:self];
	}
}
-(void)pause
{
	if(!self.avPlayer) return;
	if(self.avPlayer.playing)
	{
		[self.avPlayer pause];
	}
	
	//返回给代理
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(audioPlayerDidPausePlaying:)])
	{
		[self.delegate audioPlayerDidPausePlaying:self];
	}
}



#pragma mark -
#pragma mark delegate functions
//AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	if(_bLoop)
	{
		[self.avPlayer play];
		
		//返回给代理
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(audioPlayerReplayStart:)])
		{
			[self.delegate audioPlayerReplayStart:self];
		}
	}
	else
	{
		[self shutPlayer];
		
		//返回给代理
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)])
		{
			[self.delegate audioPlayerDidFinishPlaying:self];
		}
	}

}




@end
