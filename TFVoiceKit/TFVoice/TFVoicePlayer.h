//
//  TFVoicePlayer.h
//  TFVoiceKit
//
//  Created by Terry  on 14-2-21.
//  Copyright (c) 2014年 Terry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFVoiceDefine.h"

@interface TFVoicePlayer : NSObject

- (void)startPlayWithPath:(NSString *)path
                 completion:(void(^)(BOOL success, NSString *errorMessage))completion;
@end
