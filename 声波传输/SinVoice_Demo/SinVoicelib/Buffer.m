//
//  Buffer.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "Buffer.h"
#import "Common.h"

@implementation BufferData
@synthesize mFilledSize = _mFilledSize;
@synthesize mMaxBufferSize = _mMaxBufferSize;
@synthesize mData = _mData;

- (void)dealloc
{
    _mData = nil;
}

- (void)setMMaxBufferSize:(int)mMaxBufferSize
{
    if (_mMaxBufferSize != mMaxBufferSize)
    {
        _mMaxBufferSize = mMaxBufferSize;
        [self reset];
        if (mMaxBufferSize > 0)
        {
            _mMaxBufferSize = mMaxBufferSize;
            _mData = [NSMutableData dataWithLength:mMaxBufferSize];
        }
        else
        {
            _mData = [NSMutableData dataWithLength:0];
        }
    }
}

+ (BufferData*)getEmptyBuffer
{
    BufferData *bufferData = [[BufferData alloc]init];
    [bufferData setMMaxBufferSize:0];
    return bufferData;
}

- (void)reset
{
    _mFilledSize = 0;
}
@end

@implementation Buffer
@synthesize mBufferCount = _mBufferCount;
@synthesize mBufferSize = _mBufferSize;
@synthesize mProducerQueue = _mProducerQueue;
@synthesize mConsumeQueue = _mConsumeQueue;

- (void)dealloc
{
    _mProducerQueue = nil;
    _mConsumeQueue = nil;
}

+ (id)shared
{
    static dispatch_once_t pred;
    static Buffer *sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
       _mBufferSize = DEFAULT_BUFFER_COUNT;
       _mBufferCount = DEFAULT_BUFFER_SIZE;
        
        _mProducerQueue = [NSMutableArray arrayWithCapacity:_mBufferCount];
        _mConsumeQueue = [NSMutableArray arrayWithCapacity:_mBufferCount+1];
        
        for (int i = 0; i < _mBufferCount; ++i)
        {
            BufferData *data = [[BufferData alloc]init];
            data.mMaxBufferSize = _mBufferSize;
            [_mProducerQueue addObject:data];
            data = nil;
        }
    }
    return self;
}


- (BOOL)putEmpty:(BufferData*)data
{
    if (_mProducerQueue && data)
    {
        [_mProducerQueue addObject:data];
        return YES;
    }
    return NO;
}

- (BufferData*)getEmpty
{
    if (_mProducerQueue && _mProducerQueue.count > 0)
    {
        BufferData *data = [_mProducerQueue objectAtIndex:0];
        [_mProducerQueue removeObjectAtIndex:0];
        return data;
    }
    return nil;
}

- (BOOL)putFull:(BufferData*)data
{
    if (_mConsumeQueue && data)
    {
        [_mConsumeQueue addObject:data];
        return YES;
    }
    return NO;
}

- (BufferData*)getFull
{
    if (_mConsumeQueue && _mConsumeQueue.count > 0)
    {
        BufferData *data = [_mConsumeQueue objectAtIndex:0];
        [_mConsumeQueue removeObjectAtIndex:0];
        return data;
    }
    return nil;
}

- (void)reset
{
    // 移除_mProducerQueue中的空对象和空mData对象
    int size = _mProducerQueue.count;
    NSMutableArray *tmpProArray = [NSMutableArray array];
    for (int i = 0; i < size; i++)
    {
        id object = [_mProducerQueue objectAtIndex:i];
        if (object == [NSNull null] || (object &&  [object isKindOfClass:[BufferData class]] && ((BufferData*)object).mData == nil) )
        {
            [tmpProArray addObject:object];
        }
    }
    if ([tmpProArray count] > 0)
    {
        [_mProducerQueue removeObjectsInArray:tmpProArray];
        [tmpProArray removeAllObjects];
    }
    
    size = _mConsumeQueue.count;
    for (int i = 0; i < size; i++)
    {
        id object = [_mConsumeQueue objectAtIndex:i];
        if (object && [object isKindOfClass:[BufferData class]] && ((BufferData*)object).mData )
        {
            [_mProducerQueue addObject:object];
        }
    }
    
    NSLog(@"----reset (ProducerQueue Size:%d----ConsumeQueue Size:%d)----",_mProducerQueue.count,_mConsumeQueue.count);
}
@end
