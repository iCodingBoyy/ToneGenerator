//
//  VoiceRecognition.h
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceRecognition : NSObject
- (void)start;
- (void)stop;
- (void) process:(BufferData*)data;
@end
