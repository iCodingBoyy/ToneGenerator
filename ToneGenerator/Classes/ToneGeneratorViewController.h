//
//  ToneGeneratorViewController.h
//  ToneGenerator
//
//  Created by Matt Gallagher on 2010/10/20.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>

#define MAXBUFS 8

typedef struct
{
	AudioStreamBasicDescription asbd;
	UInt32 startingFrame;
	float *data;
	UInt32 numFrames;
    UInt32 phase;
	NSString *name;
} SndBuf;

struct SoundData
{
	int numbufs;
	SndBuf bufs[MAXBUFS];
	int select;
};

@interface ToneGeneratorViewController : UIViewController
{
	UILabel *frequencyLabel;
	UIButton *playButton;
	UISlider *frequencySlider;
	AudioComponentInstance toneUnit;
    AudioBuffer buffer;
@public
    struct SoundData dataStruct;
	double frequency;
	double sampleRate;
	float theta;
    float amplitude;
    float frame;
    float* sineData; 
}

@property (nonatomic, retain) IBOutlet UISlider *frequencySlider;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UILabel *frequencyLabel;
@property (retain, nonatomic) IBOutlet UISlider *amplitudeSilder;

@property (retain, nonatomic) IBOutlet UILabel *amplitudelabel;
- (IBAction)sliderChanged:(UISlider *)frequencySlider;
- (IBAction)togglePlay:(UIButton *)selectedButton;
- (void)stop;
- (IBAction)amplitudeValueChange:(UISlider *)sender;

@end

