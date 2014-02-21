//
//  TFVoiceRecorder.m
//  TFVoiceKit
//
//  Created by Terry  on 14-2-20.
//  Copyright (c) 2014年 Terry. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "TFVoiceDefine.h"
#import "TFVoiceRecorder.h"

#define WAVE_UPDATE_FREQUENCY   0.05

@interface TFVoiceRecorder () <AVAudioRecorderDelegate> {    
    TFVoiceRecordStatus recordStatus;
}

@property (nonatomic, retain) AVAudioRecorder * recorder;

@property (nonatomic, retain) NSTimer *timer;

@property (copy, nonatomic) voiceCompletionBlock completionBlock;

@end

@implementation TFVoiceRecorder

- (void)startRecordWithPath:(NSString *)path
                 completion:(void (^)(BOOL success,NSString *errorMessage))completion {
    
    self.completionBlock = completion;
    
    recordStatus = TFVoiceRecordStatusStart;
    NSError * err = nil;
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        recordStatus = TFVoiceRecordStatusCanceled;
        return;
	}
    [audioSession setActive:YES error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        recordStatus = TFVoiceRecordStatusCanceled;
        return;
	}
    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionaryWithCapacity:0];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
	[recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
	[recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    self.recordPath = path;
    NSURL *URL = [NSURL fileURLWithPath:self.recordPath];
    err = nil;
    NSData *data = [NSData dataWithContentsOfFile:[URL path] options:0 error:&err];
    if (data) {
        NSFileManager *fm = [NSFileManager defaultManager];
		[fm removeItemAtPath:[URL path] error:&err];
        if(self.recorder) {
            [self.recorder stop];
            self.recorder = nil;
            recordStatus = TFVoiceRecordStatusCanceled;
        }
    }
    err = nil;
    
	BOOL audioHWAvailable = audioSession.inputAvailable;
	if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: @"Audio input hardware not available"
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [cantRecordAlert show];
        recordStatus = TFVoiceRecordStatusCanceled;
        return;
	}
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:URL settings:recordSetting error:&err];
	if(err){
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: [err localizedDescription]
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [alert show];
        recordStatus = TFVoiceRecordStatusCanceled;
        return;
	}
    [_recorder setDelegate:self];
	[_recorder prepareToRecord];
	_recorder.meteringEnabled = YES;
	[_recorder recordForDuration:(NSTimeInterval) 60];
    
    [self resetTimer];
    
    self.recordTime = 0.f ;
	self.timer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    recordStatus = TFVoiceRecordStatusRecording;
}


- (void)stopRecord {
    [self cancelRecording];
    recordStatus = TFVoiceRecordStatusStopped;
    [self resetTimer];
}

- (void)cancelRecord {
    [self cancelRecording];
    recordStatus = TFVoiceRecordStatusCanceled;
    [self resetTimer];
}

- (void)cancelRecording {
    if (self.recorder && self.recorder.isRecording) {
        [self.recorder stop];
        self.recorder = nil;
    }
}

- (void)updateMeters {
    self.recordTime += WAVE_UPDATE_FREQUENCY;
    if (_recorder)
        [_recorder updateMeters];
    float peakPower = [_recorder averagePowerForChannel:0];
    double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (ALPHA * peakPower));
    NSLog(@"%f",peakPowerForChannel);
    
    //TODO
}

- (void)resetTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark --AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (recordStatus == TFVoiceRecordStatusStopped) {
        if (self.recordTime < 1.f) {
            self.completionBlock(NO,@"录音的时间太短");
        }else {
            self.completionBlock(flag,nil);
        }
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {

}




@end
