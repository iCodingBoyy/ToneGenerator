//
//  VoiceRecognition.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "VoiceRecognition.h"
#import "Buffer.h"
#import "Common.h"

static const int STATE_START = 1;
static const int STATE_STOP = 2;
static const int STATE_STEP1 = 1;
static const int STATE_STEP2 = 2;
static const int INDEX[] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 6, -1, -1, -1, -1, 5, -1, -1, -1, 4, -1, -1, 3, -1, -1, 2, -1, -1, 1, -1, -1,0 };
static const int MAX_CIRCLE = 15;
static const int MIN_CIRCLE = 10;


@interface VoiceRecognition()
{
    int mSamplingPointCount;
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
}
@end

@implementation VoiceRecognition
- (id)init
{
    self = [super init];
    if (self)
    {
        mCirclePointCount = 0;
        mSamplingSameTimes = 0;
        
        mState = STATE_STOP; 
        mSampleRate = 44100;
        mChannel = 1;
        mBits = 2;
        _state_Type = KSTATE_TYPE
    }
    return self;
}


- (void)start
{
    if (STATE_STOP == mState)
    {
        mState = STATE_START;
        mStep = STATE_STEP1;
        
        mCirclePointCount = 0;
        mIsStartCounting = NO;
        mIsBeginning = NO;
        mStartingDet = NO;
        mStartingDetCount = 0;
        mPreRegCircle = -1;
        
         while (STATE_START == mState)
         {
             BufferData *bufferData = [[Buffer shared]getFull];
             if (bufferData && bufferData.mData)
             {
                  [self process:bufferData];
                 if ( ![[Buffer shared]putEmpty:bufferData] )
                 {
                     NSLog(@"-----put empty buffer failed----");
                 }
             }
             else
             {
                 NSLog(@"-----end input buffer, so stop----");
                 break;
             }
        }
        NSLog(@"-----stop recognition----");
    }
}

- (void)stop
{
    if (STATE_START == mState)
    {
        mState = STATE_STOP;
    }
}


- (void) process:(BufferData*)data
{
    int size = data.mFilledSize - 1;
    short sh = 0;
    for (int i = 0; i < size; i++)
    {
        Byte *byte = (Byte*)[data.mData bytes];
        short sh1 = byte[i];
        sh1 &= 0xff;
        short sh2 = byte[++i];
        sh2 <<= 8;
        sh = (short) ((sh1) | (sh2));
        
        if (!mIsStartCounting)
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
                    mSamplingPointCount = 0;
                    mStep = STATE_STEP1;
                }
            }
        }
        else
        {
            ++ mSamplingPointCount;
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
                    int samplingPointCount = [self preReg:mSamplingPointCount];
                    [self reg:samplingPointCount];
                    
                    mSamplingPointCount = 0;
                    mStep = STATE_STEP1;
                }
            }
        }
    }
}

-(int)preReg:(int)samplingPointCount
{
    switch (samplingPointCount)
    {
        case 8:
        case 9:
        case 10:
        case 11:
        case 12:
            samplingPointCount = 10;
            break;
            
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:
            samplingPointCount = 15;
            break;
            
        case 18:
        case 19:
        case 20:
            samplingPointCount = 19;
            break;
            
        case 21:
        case 22:
        case 23:
            samplingPointCount = 22;
            break;
            
        case 24:
        case 25:
        case 26:
            samplingPointCount = 25;
            break;
            
        case 27:
        case 28:
        case 29:
            samplingPointCount = 28;
            break;
            
        case 30:
        case 31:
        case 32:
            samplingPointCount = 31;
            break;
            
        default:
            samplingPointCount = 0;
            break;
    }
    return samplingPointCount;
}

- (void)reg:(int)circleCount
{
    if (!mIsBeginning)
    {
        if (!mStartingDet)
        {
            if (15 == circleCount)
            {
                mStartingDet = YES;
                mStartingDetCount = 0;
            }
        }
        else
        {
            if (15 == circleCount)
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
                mStartingDet = YES;
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
            switch (mRegIndex)
            {
				case 0:
					mSamplingSameTimes = 10;
					break;
				case 1:
					mSamplingSameTimes = 15;
					break;
				case 2:
					mSamplingSameTimes = 15;
					break;
				case 3:
					mSamplingSameTimes = 15;
					break;
				case 4:
					mSamplingSameTimes = 15;
					break;
				case 5:
					mSamplingSameTimes = 15;
					break;
				case 6:
					mSamplingSameTimes = 29;
					break;
                    
				default:
					break;
            }
            if (circleCount == mRegValue)
            {
                ++ mRegCount;
                
                if (mRegCount >= (mSamplingSameTimes*10 - 2))
                {
                    // ok
                    if (mRegValue != mPreRegCircle || mRegCount > (mSamplingSameTimes*10 - 2))
                    {
                        [self onRecognition:mRegIndex];
                        mPreRegCircle = mRegValue;
                    }
                    
                    mIsRegStart = NO;
                }
            }
            else
            {
                mIsRegStart = NO;
            }
        }
    }
}
- (void)onRecognition:(int)index
{
    if (5 == index)
    {
        // 发送开始消息
//        mListener.onRecognitionStart();
    }
    else if (6 == index)
    {
        // 发送结束消息
//        mListener.onRecognitionEnd();
    }
    else if (index > 0 && index <= 5)
    {
        // 发送文本消息
//        mListener.onRecognition(mCodeBook.charAt(index - 1));
    }
}
@end
