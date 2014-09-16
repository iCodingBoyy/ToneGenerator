//
//  SinWaveRecoder.m
//  SinVoiceDemo
//
//  Created by 马远征 on 14-1-14.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "SinWaveRecoder.h"
#import "AQRecorder.h"

static const int STATE_STEP1 = 1;
static const int STATE_STEP2 = 2;
static const int INDEX[] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 6, -1, -1, -1, -1, 5, -1, -1, -1, 4, -1, -1, 3, -1, -1, 2, -1, -1, 1, -1, -1,0 };

#define KMCodeString @"01234"

typedef NS_ENUM(NSInteger, START_RECORD_STATE)
{
    START_RECORD_STATE_START= 1,
    START_RECORD_STATE_STOP,
};

@interface SinWaveRecoder() <AQRecorderDelegate>
{
    int mState;
    int mSampleRate;
    int mChannel;
    int mBits;
    int mStep;
    int mStartingDetCount;
    int mRegValue;
    int mRegIndex;
    int mRegCount;
    int mPreRegCircle;
    
    BOOL mIsStartCounting;
    BOOL mIsBeginning;
    BOOL mStartingDet;
    BOOL mIsRegStart;
    
    int mCirclePointCount;
    int mSamplingSameTimes;
    AQRecorder *_mRecoder;
    NSThread *_mRecordThread;
    NSThread *_mDecodeThread;
    START_RECORD_STATE _recordState;
    
    NSCondition *_ticketCondition;
}
@property (nonatomic, strong) NSMutableString *receiveString;
@end

@implementation SinWaveRecoder
@synthesize receiveString = _receiveString;

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    if (_ticketCondition)
    {
        [_ticketCondition unlock];
        _ticketCondition = nil;
    }
    
    
    _receiveString = nil;
    if (_mRecoder)
    {
        [_mRecoder stopRecord];
        _mRecoder = nil;
    }
    if (_mRecordThread)
    {
        [_mRecordThread cancel];
        _mRecordThread = nil;
    }
    if (_mDecodeThread)
    {
        [_mDecodeThread cancel];
        _mDecodeThread = nil;
    }
}

#pragma mark -
#pragma mark init

- (id)init
{
    self = [super init];
    if (self)
    {
        mCirclePointCount = 0;
        mSamplingSameTimes = 0;
        mSampleRate = 44100;
        mChannel = 1;
        mBits = 2;
        mIsStartCounting = NO;
        mIsBeginning = NO;
        mStartingDet = NO;
        mIsRegStart = NO;
        
        _mRecoder = [[AQRecorder alloc]init];
        [_mRecoder setDelegate:self];
        _recordState = START_RECORD_STATE_STOP;
        _receiveString = [[NSMutableString alloc]init];
        _ticketCondition =  [[NSCondition alloc] init];
    }
    return self;
}



- (void)startRecord
{
    if (_recordState == START_RECORD_STATE_STOP)
    {
        [_receiveString setString:@""];
        _recordState = START_RECORD_STATE_START;
        DEBUG_STR(@"-----开始录制-----");
        mCirclePointCount = 0;
        mIsStartCounting = NO;
        mIsBeginning = NO;
        mStartingDet = NO;
        mStartingDetCount = 0;
        mPreRegCircle = -1;
        mStep = STATE_STEP1;
        
        _mRecordThread = [[NSThread alloc]initWithTarget:self selector:@selector(startRecordThread) object:nil];
        if (_mRecordThread)
        {
            [_mRecordThread start];
        }
    }
}

- (void)startRecordThread
{
    [_mRecoder startRecord];
}

- (void)stopRecord
{
    _recordState = START_RECORD_STATE_STOP;
    [_mRecoder stopRecord];
}

#pragma mark -
#pragma mark AQRecoderDelegate

- (void)AQRecorderOutPutData:(NSData *)data
{
    @autoreleasepool
    {
        [_ticketCondition lock];
        // 处理Buffer
        [self process:data];
        [_ticketCondition unlock];
    }
    
}

#pragma mark -
#pragma mark 处理回收的数据

- (void) process:(NSData*)data
{
    int size = data.length;
    short sh = 0;
    for (int i = 0; i < size; i++)
    {
        Byte *byte = (Byte*)[data bytes];
        short sh1 = byte[i];
        sh1 &= 0xff;
        short sh2 = byte[++i];
        sh2 <<= 8;
        sh = (short) ((sh1) | (sh2));
        
        if ( !mIsStartCounting )
        {
            if (STATE_STEP1 == mStep)
            {
                if (sh < 0)
                {
                    mStep = STATE_STEP2;
                }
            }
            else if (STATE_STEP2 == mStep)
            {
                if (sh > 0)
                {
                    mIsStartCounting = YES;
                    mCirclePointCount = 0;
                    mStep = STATE_STEP1;
                }
            }
        }
        else
        {
            ++ mCirclePointCount;
            if (STATE_STEP1 == mStep)
            {
                if (sh < 0)
                {
                    mStep = STATE_STEP2;
                }
            }
            else if (STATE_STEP2 == mStep)
            {
                if (sh > 0)
                {
                    int circleCount = [self preReg:mCirclePointCount];
                    [self reg:circleCount];
                    
                    mCirclePointCount = 0;
                    mStep = STATE_STEP1;
                }
            }
        }
    }
}

-(int)preReg:(int)circleCount
{
    switch (circleCount)
    {
        case 8:
        case 9:
        case 10:
        case 11:
        case 12:
            circleCount = 10;
            break;
            
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:
            circleCount = 15;
            break;
            
        case 18:
        case 19:
        case 20:
            circleCount = 19;
            break;
            
        case 21:
        case 22:
        case 23:
            circleCount = 22;
            break;
            
        case 24:
        case 25:
        case 26:
            circleCount = 25;
            break;
            
        case 27:
        case 28:
        case 29:
            circleCount = 28;
            break;
            
        case 30:
        case 31:
        case 32:
            circleCount = 31;
            break;
            
        default:
            circleCount = 0;
            break;
    }
    return circleCount;
}

- (void)reg:(int)circleCount
{
    if (!mIsBeginning)
    {
        if (!mStartingDet)
        {
            if (31 == circleCount)
            {
                mStartingDet = YES;
                mStartingDetCount = 0;
            }
        }
        else
        {
            if (31 == circleCount)
            {
                ++ mStartingDetCount;
                
                if (mStartingDetCount >= 10)
                {
                    mIsBeginning = YES;
                    mIsRegStart = NO;
                    mRegCount = 0;
                }
            }
            else
            {
                mStartingDet = NO;
            }
        }
    }
    else
    {
        if (!mIsRegStart)
        {
            if (circleCount > 0)
            {
                mRegValue = circleCount;
                mRegIndex = INDEX[circleCount];
                mIsRegStart = YES;
                mRegCount = 1;
            }
        }
        else
        {
            if (circleCount == mRegValue)
            {
                ++ mRegCount;
                if (mRegCount >= 10)
                {
                    if (mRegValue != mPreRegCircle)
                    {
                        [self onRecognition:mRegIndex];
                        mPreRegCircle = mRegValue;
                    }
                    mIsRegStart = false;
                }
            }
            else
            {
                mIsRegStart = NO;
            }
        }
    }
}

- (void)clearData
{
    
}

- (void)onRecognition:(int)index
{
    
    if (5 == index)
    {
        // 开始接收
        [_receiveString setString:@""];
        NSLog(@"--------start---------");
    }
    else if (6 == index)
    {
       // 停止接受
        NSLog(@"-----receiveString----%@",_receiveString);
//        [self stopRecord];
    }
    else if (index >= 0 && index <= 5)
    {
        NSString *string = [KMCodeString substringWithRange:NSMakeRange(index, 1)];
        [_receiveString appendString:string];
    }
}

@end
