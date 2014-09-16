//
//  Buffer.h
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BufferData : NSObject
@property (nonatomic, strong) NSMutableData *mData;
@property (nonatomic, assign) int mFilledSize;
@property (nonatomic, assign) int mMaxBufferSize;
- (void)setMMaxBufferSize:(int)mMaxBufferSize;
+ (BufferData*)getEmptyBuffer;
@end


@interface Buffer : NSObject
@property (nonatomic, assign) int mBufferCount;
@property (nonatomic, assign) int mBufferSize;
@property (nonatomic, strong) NSMutableArray *mProducerQueue;
@property (nonatomic, strong) NSMutableArray *mConsumeQueue;
+ (id)shared;
- (void)reset;
- (BOOL)putEmpty:(BufferData*)data;
- (BufferData*)getEmpty;
- (BOOL)putFull:(BufferData*)data;
- (BufferData*)getFull;
@end
