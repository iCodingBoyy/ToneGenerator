//
//  AQRecorder.h
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-11.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AQRecorderDelegate <NSObject>
@optional
- (void)AQRecorderOutPutData:(NSData*)data;
- (void)AQRecorderOutPutDataBytes:(const void*)bytes len:(UInt32)datalen;

@end

@interface AQRecorder : NSObject
@property (nonatomic, assign) id<AQRecorderDelegate> delegate;
- (void)startRecord;
- (void)stopRecord;
- (void)pauseRecord;
- (void)clearRecord;
@end
