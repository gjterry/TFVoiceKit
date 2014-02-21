//
//  TFVoiceRecorder.h
//  TFVoiceKit
//
//  Created by Terry  on 14-2-20.
//  Copyright (c) 2014年 Terry. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    TFVoiceRecordStatusStart = 1,
    TFVoiceRecordStatusRecording,
    TFVoiceRecordStatusStopped,
    TFVoiceRecordStatusCanceled
};
typedef NSInteger TFVoiceRecordStatus;

@interface TFVoiceRecorder : NSObject

@property (nonatomic, retain) NSString *recordPath;

@property (nonatomic, assign) double recordTime;

- (void)startRecordWithPath:(NSString *)path
                 completion:(void(^)(BOOL success, NSString *errorMessage))completion;

- (void)stopRecord;

- (void)cancelRecord;
@end
