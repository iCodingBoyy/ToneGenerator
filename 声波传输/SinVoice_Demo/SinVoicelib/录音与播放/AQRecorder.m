//
//  AQRecorder.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-11.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "AQRecorder.h"
#import <AudioToolbox/AudioToolbox.h>

#define NUM_BUFFERS 3

@interface AQRecorder()
{
    AudioQueueRef queue;
    AudioStreamBasicDescription mRecordFormat;
    AudioQueueBufferRef	mBuffers[NUM_BUFFERS];
    BOOL _mIsRunning;
    BOOL _mIsStop;
}
static void BufferCallack(void *inUserData,AudioQueueRef inAQ,
                          AudioQueueBufferRef buffer);
static void MyInputBufferHandler(void *							inUserData,
                                 AudioQueueRef						inAQ,
                                 AudioQueueBufferRef				inBuffer,
                                 const AudioTimeStamp *				inStartTime,
                                 UInt32								inNumPackets,
                                 const AudioStreamPacketDescription*	inPacketDesc);
@end

@implementation AQRecorder
@synthesize delegate = _delegate;



- (id)init
{
    self = [super init];
    if (self)
    {
        // 实例化音频
        [self SetupAudioFormat:kAudioFormatLinearPCM];
        _mIsRunning = NO;
        [self initNewOutput];
    }
    return self;
}

- (void)SetupAudioFormat:(UInt32)inFormatID
{
    memset(&mRecordFormat, 0, sizeof(mRecordFormat));
    mRecordFormat.mSampleRate = 44100.00;
    mRecordFormat.mFormatID = inFormatID;
    if (inFormatID == kAudioFormatLinearPCM)
	{
        mRecordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        mRecordFormat.mBitsPerChannel = 16;
        mRecordFormat.mFramesPerPacket = 1;
        mRecordFormat.mChannelsPerFrame = 1;
        mRecordFormat.mBytesPerFrame = (mRecordFormat.mBitsPerChannel / 8) * mRecordFormat.mChannelsPerFrame;
        mRecordFormat.mBytesPerPacket = mRecordFormat.mBytesPerFrame;
        
    }
}

- (void)initNewOutput
{
    OSStatus status =  AudioQueueNewInput(&mRecordFormat,
                                          MyInputBufferHandler,
                                          (__bridge void *)(self) ,
                                          NULL ,
                                          NULL,
                                          0 ,
                                          &queue);
    if (status)
    {
        NSLog(@"--AudioQueueNewInput failed---");
    }
    
    int bufferByteSize = [self ComputeRecordBufferSize:&mRecordFormat floatValue:.5];
    for (int i = 0; i < 3; ++i )
    {
        OSStatus status =  AudioQueueAllocateBuffer(queue, bufferByteSize, &mBuffers[i]);
        if (status)
        {
            NSLog(@"---AudioQueueAllocateBuffer failed----");
        }
        status =  AudioQueueEnqueueBuffer(queue, mBuffers[i], 0, NULL);
        if (status)
        {
            NSLog(@"---AudioQueueEnqueueBuffer failed----");
        }
    }
}

- (void)startRecord
{
    if (_mIsRunning)
    {
        return;
    }
    if (_mIsStop)
    {
        [self initNewOutput];
    }
    
    OSStatus status =  AudioQueueStart(queue, NULL);
    if (status)
    {
        NSLog(@"----AudioQueueStart--Error-");
    }
    else
    {
        _mIsRunning = YES;
        _mIsStop = NO;
    }
}

- (void)pauseRecord
{
    OSStatus status =  AudioQueuePause(queue);
    if (status)
    {
        NSLog(@"----AudioQueueStart--Error-");
    }
    else
    {
        _mIsRunning = NO;
    }
}

- (void)stopRecord
{
    OSStatus status = AudioQueueStop(queue, true);
    if (status)
    {
        NSLog(@"----AudioQueueStop--Error-");
    }
    else
    {
        _mIsRunning = NO;
        _mIsStop = YES;
    }
}

- (void)clearRecord
{
    AudioQueueDispose(queue, true);
    AudioQueueFlush(queue);
    AudioQueueStop(queue, true);
}

- (void)decodeWave:(UInt32)inNumPackets inputData:(const void*)intPutData
{
    if (_delegate && [_delegate respondsToSelector:@selector(AQRecorderOutPutDataBytes:len:)])
    {
        [_delegate AQRecorderOutPutDataBytes:intPutData len:inNumPackets];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(AQRecorderOutPutData:)])
    {
        NSData *data = [NSData dataWithBytes:intPutData length:inNumPackets];
        [_delegate AQRecorderOutPutData:data];
    }
}



static void MyInputBufferHandler(void *							inUserData,
                                 AudioQueueRef						inAQ,
                                 AudioQueueBufferRef				inBuffer,
                                 const AudioTimeStamp *				inStartTime,
                                 UInt32								inNumPackets,
                                 const AudioStreamPacketDescription*	inPacketDesc)
{
    AQRecorder *recoder=(__bridge AQRecorder*)inUserData;
    if (inNumPackets > 0)
    {
        // 输出声音buffer
        [recoder decodeWave:inBuffer->mAudioDataByteSize inputData:inBuffer->mAudioData];
        NSLog(@"-----inNumPackets---%u",(unsigned int)inNumPackets);
        NSLog(@"---data---%d",(unsigned int)inBuffer->mAudioDataByteSize);
    }
    
    if (recoder -> _mIsRunning)
    {
        OSStatus status =  AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
        if (status)
        {
            NSLog(@"AudioQueueEnqueueBuffer failed");
        }
    }
}

- (int)ComputeRecordBufferSize:(const AudioStreamBasicDescription*)format floatValue:(float) seconds
{
    int packets, frames, bytes = 0;
	@try
    {
		frames = (int)ceil(seconds * format->mSampleRate);
		
		if (format->mBytesPerFrame > 0)
        {
            bytes = frames * format->mBytesPerFrame;
        }
		else
        {
			UInt32 maxPacketSize;
			if (format->mBytesPerPacket > 0)
				maxPacketSize = format->mBytesPerPacket;	// constant packet size
			else
            {
				UInt32 propertySize = sizeof(maxPacketSize);
				OSStatus status = AudioQueueGetProperty(queue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize,&propertySize);
                if (status)
                {
                    NSLog(@"couldn't get queue's maximum output packet size");
                }
			}
			if (format->mFramesPerPacket > 0)
            {
                packets = frames / format->mFramesPerPacket;
            }
			else
            {
                packets = frames;
            }// worst-case scenario: 1 frame in a packet
			if (packets == 0)
            {
                packets = 1;
            }
			bytes = packets * maxPacketSize;
		}
	}
    @catch (NSException *exception)
    {
        NSLog(@"------name:%@ reason:%@",exception.name,exception.reason);
		return 0;
	}
	return bytes;
}

@end
