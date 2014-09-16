//
//  SinVoicePlayer.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "SinVoicePlayer.h"
#import "PcmPlayer.h"
#import "Encoder.h"
#import "Buffer.h"
#import "Common.h"

static const int STATE_START = 1;
static const int STATE_STOP = 2;
static const int STATE_PENDING = 3;

static const int DEFAULT_GEN_DURATION = 100;

@interface SinVoicePlayer()
{
    Buffer *_mBuffer;
    Encoder *_mEncoder;
    PcmPlayer *_pcmPlayer;
    int _mState;
    NSMutableArray *_codesArray;
}
@end

@implementation SinVoicePlayer
- (id)init
{
    self = [super init];
    if (self)
    {
        _mState = STATE_STOP;
        _mBuffer = [[Buffer alloc]init];
        _mEncoder = [[Encoder alloc]init];
        _pcmPlayer = [[PcmPlayer alloc]init];
        _codesArray = [NSMutableArray array];
    }
    return self;
}

- (BOOL)convertTextToCodes:(NSString*)text
{
    
    BOOL ret = YES;
    if (text.length > 0)
    {
        int len = text.length;
        for (int i = 0; i < len; ++i)
        {
            [_codesArray addObject:[NSNumber numberWithInt:i]];
        }
        if (ret)
        {
            [_codesArray addObject:[NSNumber numberWithInt:STOP_TOKEN]]; ;
        }
    }
    else
    {
        ret = NO;
    }
    return ret;
}

- (void)play:(NSString*)text
{
    if (STATE_STOP == _mState && [self convertTextToCodes:text])
    {
         _mState = STATE_PENDING;
        [_pcmPlayer startPlayer];
        [_mEncoder encode:_codesArray duration:DEFAULT_GEN_DURATION];
        
        [_pcmPlayer stopPlayer];
        [_mEncoder stop];
        _mState = STATE_START;
    }
}

- (void)stopPlayer
{
    if ([_mEncoder isStoped])
    {
        [_pcmPlayer stopPlayer];
    }
    [_mBuffer putFull:[BufferData getEmptyBuffer]];
    [_mBuffer reset] ;
    _mState = STATE_STOP;
}

- (void)stop
{
    if (STATE_START == _mState)
    {
        _mState = STATE_PENDING;
        [_mEncoder stop];
    }
}
@end
