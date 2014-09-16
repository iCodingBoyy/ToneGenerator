//
//  RootViewController.m
//  SinVoice_Demo
//
//  Created by 马远征 on 14-1-13.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "RootViewController.h"
#import "AudioManager.h"
#import "AQRecorder.h"

@interface RootViewController ()
{
    AQRecorder *recorder;
}
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[AudioManager shared]initialize];
        recorder = [[AQRecorder alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(120, 200, 60, 34)];
    [button setTitle:@"开始" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickToRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setFrame:CGRectMake(120, 260, 60, 34)];
    [button1 setTitle:@"暂停" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(clickToStop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
}

- (void)clickToStop
{
    [recorder stopRecord];
}

- (void)clickToRecord
{
    [recorder startRecord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
