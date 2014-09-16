//
//  SinVoiceRecognition.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "SinVoiceRecognition.h"
#import "Buffer.h"
#import "Record.h"
#import "VoiceRecognition.h"

  static const int STATE_START = 1;
  static const int STATE_STOP = 2;
  static const int STATE_PENDING = 3;

@interface SinVoiceRecognition()
{
    Buffer *_mBuffer;
    Record *_mRecord;
    VoiceRecognition *_voiceRecog;
    int _mState;
    int _mMaxCodeIndex;
}
@end

@implementation SinVoiceRecognition
- (id)init
{
    self = [super init];
    if (self)
    {
        _mState = STATE_STOP;
        _mBuffer = [[Buffer alloc]init];
        _mRecord = [[Record alloc]init];
        _voiceRecog = [[VoiceRecognition alloc]init];
        _mMaxCodeIndex = 5;
    }
    return self;
}

- (void)start
{
    if (STATE_STOP == _mState)
    {
        _mState = STATE_PENDING;
        [_voiceRecog start];
        
        [_mRecord startRecord];
        
        _mState = STATE_START;
    }
}

- (void)stopRecognition
{
    [_voiceRecog stop];
    BufferData *bufferData = [[BufferData alloc]init];
    [[Buffer shared]putFull:bufferData];
    [[Buffer shared] reset];
}

- (void)stop
{
    if (STATE_START == _mState)
    {
        _mState = STATE_PENDING;
        [_mRecord stopRecord];
         _mState = STATE_STOP;
    }
}

- (void)onRecognition:(int)index
{
    
}
@end
