//
//  PcmPlayer.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "PcmPlayer.h"
#import "OpenALPlayer.h"
#import "Buffer.h"
#import "Common.h"



@interface PcmPlayer()
{
    KSTATE_TYPE _mState;
    long mPlayedLen;
    OpenALPlayer *_alPlayer;
}
@end

@implementation PcmPlayer
- (id)init
{
    self = [super init];
    if (self)
    {
        mPlayedLen = 0;
        _mState = KSTATE_TYPE_STOP;
        _alPlayer = [[OpenALPlayer alloc]init];
    }
    return self;
}

- (void)startPlayer
{
    if (KSTATE_TYPE_STOP == _mState  && _alPlayer)
    {
        _mState = KSTATE_TYPE_START;
        mPlayedLen = 0;
        while (KSTATE_TYPE_START == _mState)
        {
            BufferData *bufferData = [[Buffer shared]getFull];
            if (bufferData && bufferData.mData)
            {
                [_alPlayer playPCMData:bufferData.mData];
                [[Buffer shared]putEmpty:bufferData];
            }
        }
    }
}

- (void)stopPlayer
{
    if (KSTATE_TYPE_START == _mState && _alPlayer)
    {
        _mState = KSTATE_TYPE_START;
        [_alPlayer stopSound];
    }
}
@end
