//
//  OpenALPlayer.h
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenALPlayer : NSObject
- (void)playPCMData:(NSData*)data;
- (void)playPCMData:(unsigned char*)data dataSize:(UInt32)dataSize;
- (BOOL)isPlaySound;
- (void)playSound;
- (void)stopSound;
- (void)cleanUpOpenAL;
@end
