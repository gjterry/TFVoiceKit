//
//  TFVoicePlayer.m
//  TFVoiceKit
//
//  Created by Terry  on 14-2-21.
//  Copyright (c) 2014年 Terry. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "TFVoiceDefine.h"
#import "TFVoicePlayer.h"

@interface TFVoicePlayer () <AVAudioPlayerDelegate>

@property (nonatomic, retain) AVAudioPlayer * player;

@property (copy, nonatomic) voiceCompletionBlock completionBlock;

@end

@implementation TFVoicePlayer

- (void)startPlayWithPath:(NSString *)path
                 completion:(void (^)(BOOL success,NSString *errorMessage))completion {
    
    self.completionBlock = completion;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.player.delegate = self;
    self.player.numberOfLoops = 0;
    [self.player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.completionBlock(flag,nil);
}

@end
