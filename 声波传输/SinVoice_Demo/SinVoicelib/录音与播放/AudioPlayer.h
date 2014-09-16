//
//  AudioPlayer.h
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface AudioPlayer : NSObject
- (void)playData:(NSData*)data;
- (void)playBuffer:(const void*)data lenght:(UInt32)length;

- (OSStatus)playSound;
- (OSStatus)stopSound;
- (void)cleanup;
@end
