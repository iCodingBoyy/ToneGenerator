//
//  MacroDefine.h
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#ifndef SinVoice_Demo_MacroDefine_h
#define SinVoice_Demo_MacroDefine_h

#ifdef DEBUG
#   define DEBUG_STR(...) NSLog(__VA_ARGS__);
#   define DEBUG_METHOD(format, ...) NSLog(format, ##__VA_ARGS__);
#else
#   define DEBUG_STR(...) NSLog(__VA_ARGS__);
#   define DEBUG_METHOD(format, ...) NSLog(format, ##__VA_ARGS__);
#endif


#endif
