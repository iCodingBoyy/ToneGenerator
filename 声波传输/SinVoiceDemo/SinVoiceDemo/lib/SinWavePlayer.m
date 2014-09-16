//
//  SinWavePlayer.m
//  SinVoiceDemo
//
//  Created by 马远征 on 14-1-14.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "SinWavePlayer.h"
#import "OpenALPlayer.h"

#define KMCodeString @"01234"

static const int DEFAULT_GEN_DURATION = 100;
// index 0, 1, 2, 3, 4, 5, 6
// sampling point Count 31, 28, 25, 22, 19, 15, 10
static int CODE_FREQUENCY[] = { 1422, 1575, 1764, 2004, 2321, 2940, 4410};

static const int BITS_16 = 32768;
static const int BITS_8 = 128;
// 编码状态
typedef NS_ENUM(NSInteger, ENCODE_STATE_TYPE)
{
    ENCODE_STATE_STOP = 0,
    ENCODE_STATE_ENCODING,
};

// 声音播放状态
typedef NS_ENUM(NSInteger, SINVOICE_PLAYER_STATE)
{
    SINVOICE_PLAYER_STOP = 1,
    SINVOICE_PLAYER_START,
    SINVOICE_PLAYER_PENDING,
};


@interface SinWavePlayer()
{
    NSMutableArray *_codesArray;
    NSThread *_mEncodeThread;
    OpenALPlayer *_mOpenAlPlayer;
    SINVOICE_PLAYER_STATE _voiceState;
    ENCODE_STATE_TYPE _encodeState;
}
@end

@implementation SinWavePlayer

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    _codesArray = nil;
    _mOpenAlPlayer = nil;
    if (_mEncodeThread)
    {
        [_mEncodeThread cancel];
        _mEncodeThread = nil;
    }

}

#pragma mark -
#pragma mark init

- (id)init
{
    self = [super init];
    if (self)
    {
        _encodeState = ENCODE_STATE_STOP;
        _voiceState = SINVOICE_PLAYER_STOP;
        _codesArray = [[NSMutableArray alloc]init];
        _mOpenAlPlayer = [[OpenALPlayer alloc]init];
    }
    return self;
}

#pragma mark -
#pragma mark play/stop

// 转换文本code
- (BOOL)convertTextToCodes:(NSString*)text
{
    BOOL ret = YES;
    if (text.length > 0)
    {
        if (_codesArray.count > 0)
        {
            [_codesArray removeAllObjects];
        }
        [_codesArray addObject:[NSNumber numberWithInt:5]];
        
        NSUInteger len = text.length;
        for (int i = 0; i < len; ++i)
        {
            NSString *string = [text substringWithRange:NSMakeRange(i, 1)];
            NSRange range = [KMCodeString rangeOfString:string];
            NSUInteger index = range.location;
            
            if (range.location != NSNotFound && range.location <= -1)
            {
                [_codesArray addObject:[NSNumber numberWithUnsignedInteger:index]];
            }
            else
            {
                ret = NO;
                break;
            }
        }
        if (ret)
        {
            [_codesArray addObject:[NSNumber numberWithInt:6]];
        }
    }
    else
    {
        ret = NO;
    }
    return ret;
}

// ascii十进制字符串转换成二进制
- (NSString *)toBinarySystemWithDecimalSystem:(unichar)decimal
{
    int num = decimal;
    int remainder = 0;      //余数
    int divisor = 0;        //除数
    
    NSString * prepare = @"";
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%d",remainder];
        if (divisor == 0)
        {
            break;
        }
    }
    NSString * result = @"";
    int length = (int)prepare.length;
    for (int i = length - 1; i >= 0; i --)
    {
        result = [result stringByAppendingFormat:@"%@",[prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    return result;
}


- (void)playSoundText:(NSString*)soundText
{
    if ([_mOpenAlPlayer isPlaySound])
    {
        DEBUG_STR(@"------正在播放文本------");
        return;
    }
    if (SINVOICE_PLAYER_STOP == _voiceState || soundText.length > 0)
    {
        _voiceState = SINVOICE_PLAYER_PENDING;
        
        NSMutableString *string = [NSMutableString string];
        for (int i = 0; i < soundText.length; i++)
        {
            unichar asciiCode = [soundText characterAtIndex:i];
            NSString *tmpString = [self toBinarySystemWithDecimalSystem:asciiCode];
            [string appendFormat:@"%@",tmpString];
        }
        
        if (string.length > 0)
        {
            NSLog(@"---string-----%@",string);
            [self play:string];
        }
        else
        {
            _voiceState = SINVOICE_PLAYER_STOP;
            DEBUG_STR(@"------空字符串数据，播放异常----");
        }
    }
}

- (void)play:(NSString*)text
{
    if ([self convertTextToCodes:text])
    {
        _mEncodeThread = [[NSThread alloc]initWithTarget:self selector:@selector(encodeThreadRun)  object:nil];
        if (_mEncodeThread)
        {
            [_mEncodeThread start];
        }
        _voiceState = SINVOICE_PLAYER_START;
    }
    else
    {
        DEBUG_STR(@"-----转换文本到Code失败----");
        _voiceState = SINVOICE_PLAYER_STOP;
    }
}

- (void)stop
{
    _voiceState = SINVOICE_PLAYER_STOP;
    _encodeState = ENCODE_STATE_STOP;
    [_mOpenAlPlayer stopSound];
    if (_mEncodeThread == nil)
    {
        return;
    }
    // 等待直到子线程停止
    while (1)
    {
        if ([_mEncodeThread isFinished] || [_mEncodeThread isCancelled])
        {
            _mEncodeThread = nil;
            break;
        }
    }
}

- (void)stopPlayer
{
     _voiceState = SINVOICE_PLAYER_STOP;
    if (![_mOpenAlPlayer isPlaySound])
    {
        [_mOpenAlPlayer stopSound];
    }
}

- (void)encodeThreadRun
{
    [self encode:_codesArray duration:60];
    [self stopPlayer];
    _encodeState = ENCODE_STATE_STOP;
}

#pragma mark -
#pragma mark EnCode

- (void)playEncodeBuffer:(int)genRate duration:(int)duration withData:(NSMutableData*)playData
{
    int n = BITS_16/2;
    int totalCount = (duration * 44100) / 1000;
    double per = (genRate / (double) 44100) * 2 * M_PI;
    double d = 0;
    
//    NSMutableData *playData = [NSMutableData data];
    for (int i = 0; i < totalCount; ++i)
    {
        if (_encodeState == ENCODE_STATE_ENCODING)
        {
            int outSize = (int) (sin(d) * n) + 128;
            Byte byte = (Byte)(outSize & 0xff);
            [playData appendBytes:&byte length:1];
            
            Byte markByte = (Byte)((outSize >> 8) & 0xff);
            [playData appendBytes:&markByte length:1];
            
            d += per;
        }
        else
        {
            DEBUG_STR(@"-----强制停止编码--1--");
            break;
        }
    }
}


- (void)encode:(NSArray*)codesArray duration:(int)duration
{
    if (_encodeState == ENCODE_STATE_STOP)
    {
        _encodeState = ENCODE_STATE_ENCODING;
        DEBUG_STR(@"----开始编码---");
        NSMutableData *playData = [NSMutableData data];
        for ( NSNumber *number in codesArray )
        {
            if (_encodeState == ENCODE_STATE_ENCODING)
            {
                NSUInteger index = [number integerValue];
                if (index < 7)
                {
                    [self playEncodeBuffer:CODE_FREQUENCY[index] duration:duration withData:playData];
                }
                else
                {
                    DEBUG_STR(@"-----编码索引错误----");
                }
            }
            else
            {
                DEBUG_STR(@"-----强制停止编码----");
                break;
            }
        }
        [_mOpenAlPlayer playPCMData:playData];
        DEBUG_STR(@"--停止编码----");
        _encodeState = ENCODE_STATE_STOP;
    }
}

@end
