//
//  SinWavePlayer.h
//  SinVoiceDemo
//
//  Created by 马远征 on 14-1-14.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SinWavePlayer : NSObject
- (void)playSoundText:(NSString*)soundText;
- (void)stopPlayer;
- (void)stop;
@end
