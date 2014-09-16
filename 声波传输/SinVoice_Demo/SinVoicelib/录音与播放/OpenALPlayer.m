//
//  OpenALPlayer.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "OpenALPlayer.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface OpenALPlayer()
{
    ALCcontext *_mContext;
    ALCdevice *_mDevice;
    ALuint _sourceID;
    NSCondition *_ticketCondition;
}
@end

@implementation OpenALPlayer

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    [self cleanUpOpenAL];
}

#pragma mark -
#pragma mark init

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initOpenAL];
    }
    return self;
}

- (void)initOpenAL
{
    _mDevice = alcOpenDevice(NULL);
    if (_mDevice)
    {
        _mContext = alcCreateContext(_mDevice,NULL);
        alcMakeContextCurrent(_mContext);
    }
    
    alGenSources(1, &_sourceID);
    alSpeedOfSound(1.0);
    alDopplerVelocity(1.0);
    alDopplerFactor(1.0);
    
    if(alGetError() != AL_NO_ERROR)
    {
        NSLog(@"Error generating sources! \n");
    }
    alSourcef(_sourceID, AL_PITCH, 1.0f);
    alSourcef(_sourceID, AL_GAIN, 1.0f);   //设置音量
    
    //设置不循环,
    alSourcei(_sourceID, AL_LOOPING, AL_FALSE);
    alSourcef(_sourceID, AL_SOURCE_TYPE, AL_STREAMING);
    
    _ticketCondition =  [[NSCondition alloc] init];
}

- (void)playPCMData:(NSData*)data
{
    @autoreleasepool {
        
        [_ticketCondition lock];
        
        ALenum  error = AL_NO_ERROR;
        if ((error =alGetError())!= AL_NO_ERROR)
        {
            [_ticketCondition unlock];
            return ;
        }
        
        if (data == nil)
        {
            return;
        }
        
        if ((error =alGetError())!= AL_NO_ERROR)
        {
            [_ticketCondition unlock];
            return ;
        }
        
        ALuint bufferID = 0;
        alGenBuffers(1, &bufferID);
        
        if ((error = alGetError()) != AL_NO_ERROR)
        {
            NSLog(@"Create buffer failed");
            [_ticketCondition unlock];
            return;
        }
        
        alBufferData(bufferID, AL_FORMAT_MONO16, (char*)[data bytes], (ALsizei)[data length], 44100.00);
        alSourceQueueBuffers(_sourceID, 1, &bufferID);
        [self updataQueueBuffer];
        
        ALint stateVaue;
        alGetSourcei(_sourceID, AL_SOURCE_STATE, &stateVaue);
        
        [_ticketCondition unlock];
    }
}


- (void)playPCMData:(unsigned char*)data dataSize:(UInt32)dataSize
{
    @autoreleasepool {
        
        [_ticketCondition lock];
        
        ALuint bufferID = 0;
        alGenBuffers(1, &bufferID);
        
        ALenum  error = AL_NO_ERROR;
        if ((error =alGetError())!= AL_NO_ERROR)
        {
            [_ticketCondition unlock];
            return ;
        }
        
        NSData * tmpData = [NSData dataWithBytes:data length:dataSize];
        alBufferData(bufferID, AL_FORMAT_MONO16, (char*)[tmpData bytes], (ALsizei)[tmpData length], 44100);
        alSourceQueueBuffers(_sourceID, 1, &bufferID);
        
        if ((error = alGetError())!= AL_NO_ERROR)
        {
            [_ticketCondition unlock];
            return ;
        }
        
        [self updataQueueBuffer];
        
        ALint stateVaue;
        alGetSourcei(_sourceID, AL_SOURCE_STATE, &stateVaue);
        
        if ((error = alGetError()) != AL_NO_ERROR)
        {
            [_ticketCondition unlock];
            return ;
        }
        
        [_ticketCondition unlock];
    }
}

- (BOOL)updataQueueBuffer
{
    ALint stateVaue;
    int processed, queued;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &stateVaue);
    
//    if (stateVaue == AL_STOPPED ||stateVaue == AL_PAUSED ||stateVaue == AL_INITIAL)
//    {
//        [self playSound];
//        return NO;
//    }
    if (stateVaue != AL_PLAYING)
    {
        [self playSound];
    }
    
    alGetSourcei(_sourceID, AL_BUFFERS_PROCESSED, &processed);
    alGetSourcei(_sourceID, AL_BUFFERS_QUEUED, &queued);
    
//    NSLog(@"Processed = %d\n", processed);
//    NSLog(@"Queued = %d\n", queued);
    
    while( processed -- )
    {
        ALuint buff;
        alSourceUnqueueBuffers(_sourceID, 1, &buff);
        alDeleteBuffers(1, &buff);
    }
    return YES;
}

- (void)playSound
{
    ALint  state;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &state);
    if (state != AL_PLAYING)
    {
        alSourcePlay(_sourceID);
    }
}

- (void)stopSound
{
    ALint  state;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &state);
    if (state != AL_STOPPED)
    {
        
        alSourceStop(_sourceID);
    }
}

- (void)cleanUpOpenAL
{
    alDeleteSources(1, &_sourceID);
    if (_mContext != nil)
    {
        alcDestroyContext(_mContext);
        _mContext = nil;
    }
    if (_mDevice !=nil)
    {
        alcCloseDevice(_mDevice);
        _mDevice = nil;
    }
    if (_ticketCondition)
    {
        [_ticketCondition unlock];
        _ticketCondition = nil;
    }
}

@end
