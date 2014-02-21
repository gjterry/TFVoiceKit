//
//  TFViewController.m
//  TFVoiceKit
//
//  Created by Terry  on 14-2-20.
//  Copyright (c) 2014年 Terry. All rights reserved.
//
#import "TFVoicePlayer.h"
#import "TFVoiceRecorder.h"
#import "TFViewController.h"

@interface TFViewController ()

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, retain) TFVoiceRecorder *recorder;
@property (nonatomic, retain) TFVoicePlayer *player;

@property (nonatomic, assign) double recordTime;

@property (weak, nonatomic) IBOutlet UILabel *recorderTime;

@end

@implementation TFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTFVoice];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)setupTFVoice {
    self.recorder = [[TFVoiceRecorder alloc]init];
    self.player = [[TFVoicePlayer alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRecordTime:(double)recordTime {
    _recordTime = recordTime;
    [self onRecordTimeChange];
}

- (void)onRecordTimeChange {
    self.recorderTime.text = [NSString stringWithFormat:@"%.f",self.recordTime];
    self.playButton.hidden = NO;
}

- (void)startRecord {
    [self.recorder startRecordWithPath:[NSString stringWithFormat:@"%@/Documents/MySound.caf", NSHomeDirectory()] completion:^(BOOL success, NSString *errorMessage) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"录音文件已经存储"];
            self.recordTime = self.recorder.recordTime;
        }else {
            [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    }];
}

- (void)stopRecord {
    [self.recorder stopRecord];
}

- (void)cancelRecord {
    [self.recorder cancelRecord];
}

- (void)prepareForRecord {
    self.recorderTime.text = nil;
    self.playButton.hidden = YES;
}

- (IBAction)onRecordButtonDown:(id)sender {
    [self.recordButton setTitle:@"正在录音" forState:UIControlStateNormal];
    [self prepareForRecord];
    [self startRecord];
}

- (IBAction)onRecordButtonTouchUpInside:(id)sender {
    [self.recordButton setTitle:@"按下开始录音" forState:UIControlStateNormal];
    [self stopRecord];
}

- (IBAction)onRecordButtonTouchUpOutside:(id)sender {
    [self.recordButton setTitle:@"按下开始录音" forState:UIControlStateNormal];
    [self cancelRecord];
}

- (IBAction)onRecordButtonDragOutside:(id)sender {
    [self.recordButton setTitle:@"松开取消录音" forState:UIControlStateNormal];
}

- (IBAction)onRecordButtonDragUpInside:(id)sender {
    [self.recordButton setTitle:@"正在录音" forState:UIControlStateNormal];
}

- (IBAction)onPlayButtonTapped:(id)sender {
    if (![self.playButton.titleLabel.text isEqualToString:@"正在播放"]) {
        [self.playButton setTitle:@"正在播放" forState:UIControlStateNormal];
        [self.player startPlayWithPath:[NSString stringWithFormat:@"%@/Documents/MySound.caf", NSHomeDirectory()] completion:^(BOOL success, NSString *errorMessage) {
            [self.playButton setTitle:@"播放录音" forState:UIControlStateNormal];
        }];
    }
}

@end
