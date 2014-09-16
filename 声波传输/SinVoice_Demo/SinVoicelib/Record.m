//
//  Record.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "Record.h"
#import "AQRecorder.h"
#import "Buffer.h"

static const int STATE_START = 1;
static const int STATE_STOP = 2;

@interface Record() <AQRecorderDelegate>
{
    AQRecorder *_recoder;
    int mState;
    int mBufferSize;
}
@end

@implementation Record

- (void)dealloc
{
    _recoder = nil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _recoder = [[AQRecorder alloc]init];
        [_recoder setDelegate:self];
    }
    return self;
}


- (void)AQRecorderOutPutData:(NSData *)data
{
    // 接收数据并填充buffer数组
    BufferData *bufferData = [[Buffer shared]getEmpty];
    if (bufferData && bufferData.mData)
    {
        bufferData.mFilledSize = [data length];
        [bufferData setMMaxBufferSize:0];
        [bufferData.mData appendData:data];
        [[Buffer shared]putFull:bufferData];
    }
}

- (int)getState
{
    return mState;
}

- (void)startRecord
{
    if (mState != STATE_START)
    {
        [_recoder startRecord];
    }
}

- (void)stopRecord
{
    if (mState != STATE_STOP)
    {
        mState = STATE_STOP;
        [_recoder stopRecord];
    }
}
@end
