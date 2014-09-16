//
//  Encoder.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-11.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "Encoder.h"
#import "Buffer.h"

static int CODE_FREQUENCY[] = { 1422, 1575, 1764, 2004, 2321, 2940, 4410};

#define KMBits 128

typedef NS_ENUM(NSInteger, ENCODE_STATE_TYPE)
{
    ENCODE_STATE_STOP = 0,
    ENCODE_STATE_ENCODING,
};

@interface Encoder()
{
    int mGenRate;
    int mFilledSize;
    int mDuration;
    int mBits;
    int mBufferSize;
    int mSampleRate;
    ENCODE_STATE_TYPE _encode_state;
}
@end

@implementation Encoder
- (id)init
{
    self =  [super init];
    if (self)
    {
        mBufferSize = 1024;
        mSampleRate = 8000;
        mBits = 128;
        mDuration = 0;
        mFilledSize = 0;
        _encode_state = ENCODE_STATE_STOP;
    }
    return self;
}

- (int)getMaxCodeCount
{
    return 7;
}

- (BOOL)isStoped
{
    return (ENCODE_STATE_STOP == _encode_state);
}

- (void)stop
{
    if (ENCODE_STATE_ENCODING == _encode_state)
    {
        _encode_state = ENCODE_STATE_STOP;
    }
}

- (void)gen:(int)genRate duration:(int)duration
{
    if (_encode_state == ENCODE_STATE_STOP)
    {
        return;
    }
    
    mGenRate = genRate;
    mDuration = duration;
    
    int n = mBits / 2;
    int totalCount = (mDuration * mSampleRate) / 1000;
    double per = (mGenRate / (double) mSampleRate) * 2 * M_PI;
    double d = 0;
    
    mFilledSize = 0;
    BufferData *bufferData = [[Buffer shared]getEmpty];
    if (bufferData)
    {
        for (int i = 0; i < totalCount; ++i)
        {
            int outSize = (int) (sin(d) * n) + 128;
            if (mFilledSize >= mBufferSize - 1)
            {
                // free buffer
                bufferData.mFilledSize = mFilledSize;
                [[Buffer shared] putFull:bufferData];
                
                mFilledSize = 0;
                bufferData = [[Buffer shared]getEmpty];
                if (bufferData == nil)
                {
                    NSLog(@"--get null buffer--");
                    break;
                }
            }
            mFilledSize++;
            [bufferData.mData appendBytes:(Byte*)(outSize & 0xff) length:1];
            if ( 32768 == mBits)
            {
                Byte *byte = (Byte*)((outSize >> 8) & 0xff);
                mFilledSize++;
                [bufferData.mData appendBytes:byte length:1];
            }
            d += per;
            }
    }
    else
    {
        NSLog(@"--get null buffer--");
    }
    
    if (bufferData)
    {
        bufferData.mFilledSize = mFilledSize;
        [[Buffer shared] putFull:bufferData];
    }
    mFilledSize = 0;
    NSLog(@"--------end gen codes-------");
}


- (void)encode:(NSArray*)codesArray duration:(int)duration
{
    if ( ENCODE_STATE_STOP == _encode_state )
    {
        _encode_state = ENCODE_STATE_ENCODING;
        
        for ( NSNumber *number in codesArray )
        {
            if (ENCODE_STATE_ENCODING == _encode_state)
            {
                int index = [number intValue];
                DEBUG_STR(@"----encode---%d",index);
                if (index >= 0 && index < 7)
                {
                    [self gen:CODE_FREQUENCY[index] duration:duration];
                }
                else
                {
                    DEBUG_STR(@"-----code index error----");
                }
            }
            else
            {
                DEBUG_STR(@"-----encode force stop----");
                break;
            }
        }
        // for mute
        if (ENCODE_STATE_ENCODING == _encode_state)
        {
            [self gen:0 duration:0];
        }
        else
        {
            DEBUG_STR(@"-----encode force stop----");
        }
        [self stop];
    }
}
@end
