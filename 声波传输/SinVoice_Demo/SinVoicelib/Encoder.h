//
//  Encoder.h
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-11.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encoder : NSObject
- (BOOL)isStoped;
- (void)stop;
- (void)encode:(NSArray*)codesArray duration:(int)duration;
- (int)getMaxCodeCount;
@end
