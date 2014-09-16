//
//  MainViewController.m
//  SinVoiceDemo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "MainViewController.h"
#import "SinWavePlayer.h"
#import "SinWaveRecoder.h"

@interface MainViewController ()
{
    SinWavePlayer *_sinVoicePlayer;
    SinWaveRecoder *_sinWaveRecoder;
}
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}
- (void)loadView
{
    [super loadView];
    CGRect frame = [[UIScreen mainScreen]applicationFrame];
    UIView *contentView = [[UIView alloc]initWithFrame:frame];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *sendVoice = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendVoice setFrame:CGRectMake(100, 200, 80, 34)];
    [sendVoice setTitle:@"开始播放" forState:UIControlStateNormal];
    [sendVoice addTarget:self action:@selector(clickToSendVoice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendVoice];
    
    UIButton *stopVoice = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [stopVoice setFrame:CGRectMake(210, 200, 80, 34)];
    [stopVoice setTitle:@"停止播放" forState:UIControlStateNormal];
    [stopVoice addTarget:self action:@selector(clickToStopVoice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopVoice];
    
    UIButton *startRecord = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startRecord setFrame:CGRectMake(100, 260, 80, 34)];
    [startRecord setTitle:@"开始记录" forState:UIControlStateNormal];
    [startRecord addTarget:self action:@selector(clickToRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startRecord];
    
    UIButton *stopRecord = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [stopRecord setFrame:CGRectMake(210, 260, 80, 34)];
    [stopRecord setTitle:@"停止记录" forState:UIControlStateNormal];
    [stopRecord addTarget:self action:@selector(clickToStopRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopRecord];
    
    _sinVoicePlayer = [[SinWavePlayer alloc]init];
    _sinWaveRecoder = [[SinWaveRecoder alloc]init];
}

- (void)clickToSendVoice
{
//    NSString *string = @"123403020240003103000120304020010302020102020203400420043042003040042030024024";
    [_sinVoicePlayer playSoundText:@"abc12357afdhsgfkutsfa"];
    
}

- (void)clickToStopVoice
{
    [_sinVoicePlayer stop];
}

- (void)clickToRecord
{
    [_sinWaveRecoder startRecord];
}

- (void)clickToStopRecord
{
    [_sinWaveRecoder stopRecord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
