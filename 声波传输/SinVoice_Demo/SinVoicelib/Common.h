//
//  Common.h
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KSTATE_TYPE)
{
    KSTATE_TYPE_START = 0,
    KSTATE_TYPE_STOP,
};

static NSInteger const START_TOKEN = 0;
static NSInteger const STOP_TOKEN = 6;
static NSInteger const DEFAULT_BUFFER_SIZE = 4096;
static NSInteger const DEFAULT_BUFFER_COUNT = 3;
static NSInteger const DEFAULT_SAMPLE_RATE = 44100;

static NSString *const DEFAULT_CODE_BOOK = @"12345";

