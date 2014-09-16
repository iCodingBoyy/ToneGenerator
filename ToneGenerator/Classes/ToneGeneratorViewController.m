//
//  ToneGeneratorViewController.m
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

#import "ToneGeneratorViewController.h"
#import <AudioToolbox/AudioToolbox.h>

static const uint kSampleRate = 44100;
static const float kSineFrequency = 22000.0;

OSStatus RenderTone(
	void *inRefCon, 
	AudioUnitRenderActionFlags 	*ioActionFlags, 
	const AudioTimeStamp 		*inTimeStamp, 
	UInt32 						inBusNumber, 
	UInt32 						inNumberFrames, 
	AudioBufferList 			*ioData)

{
    ToneGeneratorViewController *viewController = (ToneGeneratorViewController *)inRefCon;
	float theta = viewController->theta;
	float theta_increment =  2*M_PI * 20000 /kSampleRate;

	const int channel = 0;
    const int channel1 = 1;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
    Float32 *buffer1 = (Float32 *)ioData->mBuffers[channel1].mData;
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
		buffer[frame] = sin(theta)*0.35;
        buffer1[frame] = sin(theta)*0.35;
		theta += theta_increment;
        if (theta >= (M_PI * 2))
        {
            theta -= (M_PI * 2);
        }
	}
	viewController->theta = theta;
    return noErr;
    
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	ToneGeneratorViewController *viewController =
		(ToneGeneratorViewController *)inClientData;
	
	[viewController stop];
}



@implementation ToneGeneratorViewController

@synthesize frequencySlider;
@synthesize playButton;
@synthesize frequencyLabel;

- (IBAction)sliderChanged:(UISlider *)slider
{
    frequency = 22050;
	frequencyLabel.text = [NSString stringWithFormat:@"%4.1f Hz", frequency];
}

- (void)createToneUnit
{
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	
    AURenderCallbackStruct input;
    memset(&input, 0, sizeof(AURenderCallbackStruct));
    input.inputProc = RenderTone;
    input.inputProcRefCon = self;
    err = AudioUnitSetProperty(toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
    
    AudioStreamBasicDescription audioDescription;
    memset(&audioDescription, 0, sizeof(audioDescription));
    audioDescription.mFormatID          = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
//    audioDescription.mFormatFlags = kAudioFormatFlagsCanonical | kAudioFormatFlagIsNonInterleaved;
    audioDescription.mChannelsPerFrame  = 2;
    audioDescription.mBytesPerPacket    = sizeof(float);
    audioDescription.mFramesPerPacket   = 1;
    audioDescription.mBytesPerFrame     = sizeof(float);
    audioDescription.mBitsPerChannel    = 8 * sizeof(float);
    audioDescription.mSampleRate        = 44100.0;
    
	err = AudioUnitSetProperty (toneUnit,
		kAudioUnitProperty_StreamFormat,
		kAudioUnitScope_Input,
		0,
		&audioDescription,
		sizeof(AudioStreamBasicDescription));
    
}

- (IBAction)togglePlay:(UIButton *)selectedButton
{
	if (toneUnit)
	{
		AudioOutputUnitStop(toneUnit);
		AudioUnitUninitialize(toneUnit);
		AudioComponentInstanceDispose(toneUnit);
		toneUnit = nil;
		
		[selectedButton setTitle:NSLocalizedString(@"Play", nil) forState:0];
	}
	else
	{
		[self createToneUnit];
		
		OSErr err = AudioUnitInitialize(toneUnit);
		NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
		
		// Start playback
		err = AudioOutputUnitStart(toneUnit);
		NSAssert1(err == noErr, @"Error starting unit: %ld", err);
		
		[selectedButton setTitle:NSLocalizedString(@"Stop", nil) forState:0];
	}
}

- (void)stop
{
	if (toneUnit)
	{
		[self togglePlay:playButton];
	}
}


- (IBAction)amplitudeValueChange:(UISlider *)sender
{
//    amplitude = sender.value;
    amplitude = 1;
    _amplitudelabel.text = [NSString stringWithFormat:@"amplitude:%.f",sender.value];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self sliderChanged:frequencySlider];
    [self amplitudeValueChange:_amplitudeSilder];
	sampleRate = 44100;
    
    NSLog(@"------flot----%lu",sizeof(SInt32));
	OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, self);
	if (result == kAudioSessionNoError)
	{
		UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
//        UInt32 audioRoute = kAudioSessionOverrideAudioRoute_Speaker;
//
//        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRoute), &audioRoute);
	}
	AudioSessionSetActive(true);
    
    
}


- (void)viewDidUnload
{
    [self setAmplitudeSilder:nil];
    [self setAmplitudelabel:nil];
	self.frequencyLabel = nil;
	self.playButton = nil;
	self.frequencySlider = nil;

	AudioSessionSetActive(false);
}

- (void)dealloc {
    [_amplitudelabel release];
    [_amplitudeSilder release];
    [super dealloc];
}
@end
