//
//  AudioPlayer.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "AudioPlayer.h"


#define kOutputBus 0
#define kInputBus 1

@interface AudioPlayer()
{
    AudioComponentInstance audioUnit;
    AudioStreamBasicDescription audioFormat;
    AudioBuffer buffer;
}
@end

@implementation AudioPlayer

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    free(buffer.mData);
}

#pragma mark -
#pragma mark init

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (OSStatus)playSound
{
    OSStatus status = AudioOutputUnitStart(audioUnit);
    if (status)
    {
        printf("---start_Error----");
    }
    return status;
}


- (OSStatus)stopSound
{
    OSStatus status = AudioOutputUnitStop(audioUnit);
    if (status)
    {
        printf("---stop_Error----");
    }
    return  status;
}

- (void)cleanup
{
    AudioUnitUninitialize(audioUnit);
}

static OSStatus playbackCallback(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData)
{
    AudioPlayer *player = (__bridge AudioPlayer *)inRefCon;
    for (int i = 0; i < ioData->mNumberBuffers; i++)
    {
        UInt32 *frameBuffer = ioData->mBuffers[i].mData;
        
        UInt32 newDataSize =  player->buffer.mDataByteSize;
        if (ioData->mBuffers[i].mDataByteSize != newDataSize)
        {
            ioData->mBuffers[i].mDataByteSize = newDataSize;
        }
        
        UInt32 *inputBuffer = player->buffer.mData;
        for (int index = 0; index < inNumberFrames; index++)
        {
            frameBuffer[index] = inputBuffer[index];
            return noErr;
        }
    }
    return noErr;
}

- (void)playBuffer:(const void*)data lenght:(UInt32)length
{
    if (buffer.mDataByteSize < length)
    {
        free(buffer.mData);
        buffer.mData = (void*)malloc(length);
    }
    memset(buffer.mData, 0, length);
    memcpy(buffer.mData, data, length);
}

- (void)playData:(NSData*)data
{
    if (buffer.mDataByteSize < [data length])
    {
        free(buffer.mData);
        buffer.mData = (void*)malloc( [data length]);
    }
    memset(buffer.mData, 0,  [data length]);
    memcpy(buffer.mData, (void*)[data bytes],  [data length]);
}

- (void)initialize
{
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    OSStatus status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus ,
                                  &flag,
                                  sizeof(flag));
    
    audioFormat.mSampleRate = 44100.00;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerPacket = 2;
    audioFormat.mBytesPerFrame = 2;
    
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                kAudioUnitProperty_SetRenderCallback,
                                kAudioUnitScope_Global,
                                kOutputBus,
                                &callbackStruct,
                                sizeof(callbackStruct));
    status = AudioUnitInitialize(audioUnit);
    if (status)
    {
        NSLog(@"----AudioUnitInitialize---Error-");
    }
    buffer.mData = (void*)malloc(buffer.mDataByteSize);
}
@end
