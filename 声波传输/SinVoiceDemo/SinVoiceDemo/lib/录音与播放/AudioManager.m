//
//  AudioManager.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "AudioManager.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation AudioManager
+ (id)shared
{
    static dispatch_once_t pred;
    static AudioManager *sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

static void BufferCallback(void *inUserData,
                           AudioQueueRef inAQ,
                           AudioQueueBufferRef buffer)
{
    AudioManager *recoder=(__bridge AudioManager*)inUserData;
    
    
}

static void propListener(void *inClientData,
                         AudioSessionPropertyID	inID,
                         UInt32                  inDataSize,
                         const void *            inData)
{
    
}

static void interruptionListener(void *inClientData,
                                 UInt32 inInterruptionState)
{
    
}

- (void)initialize
{
    OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, (__bridge void *)(self));
	if (error)
    {
        printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
        return;
    }
    UInt32 category = kAudioSessionCategory_PlayAndRecord;
    error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    if (error)
    {
        printf("couldn't set audio category!");
    }
    error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, (__bridge void *)(self));
    if (error)
    {
        printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
    }
    UInt32 inputAvailable = 0;
    UInt32 size = sizeof(inputAvailable);
    
    // 检测输入是否可利用
    error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
    if (error)
    {
        printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)error);
        return;
    }
    // 监听输入源是否更改
    error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, (__bridge void *)(self));
    if (error)
    {
        printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
    }
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    error = AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof                     (audioRouteOverride),&audioRouteOverride);
    if (error)
    {
        printf("set AudioRoute_Speaker failed");
    }
    
    error = AudioSessionSetActive(true);
    if (error)
    {
        printf("AudioSessionSetActive (true) failed");
    }
}

@end
