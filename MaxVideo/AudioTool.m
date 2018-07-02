//
//  AudioTool.m
//  MaxVideo
//
//  Created by VS on 2018/7/2.
//  Copyright © 2018年 VS. All rights reserved.
//

#import "AudioTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioTool

+ (void) combinationAudiosWithAudioPath:(NSArray<NSString *> *)subsectionPaths
                         audioFullPath:(NSString *)audioFullPath
                        completedBlock:(CompFinalCompletedBlock)completedBlock {
    if (!subsectionPaths || subsectionPaths.count == 0) {
        NSLog(@"No such SubsectionNames");
        completedBlock(NO, @"合并失败");
        return;
    }
     NSDictionary *optDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //  获取音轨
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    __block CMTime beginTime = kCMTimeZero;
    __block NSError *error = nil;
    [subsectionPaths enumerateObjectsUsingBlock:^(NSString *audioPath, NSUInteger idx, BOOL * _Nonnull stop) {
        AVAsset *audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:audioPath] options:optDict];
        NSArray *tracks = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
        if (tracks <= 0) {
            *stop = YES;
            completedBlock(NO, @"合并失败");
            return;
        }
        
        BOOL success = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:tracks.firstObject atTime:beginTime error:&error];
        if (!success) {
            *stop = YES;
            completedBlock(NO, error.localizedDescription);
            return;
        }
        
        beginTime = CMTimeAdd(beginTime, audioAsset.duration);
    }];
    
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];
    assetExport.outputURL = [NSURL fileURLWithPath:audioFullPath];
    assetExport.shouldOptimizeForNetworkUse = YES;
    assetExport.outputFileType = @"com.apple.m4a-audio";
    //  导入出
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        BOOL isSuccess = NO;
        NSString *msg = @"音频合并成功";
        switch (assetExport.status) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"AudioTool -> combinationError: %@", assetExport.error.localizedDescription);
                msg = @"音频合并失败";
                break;
            case AVAssetExportSessionStatusUnknown:
            case AVAssetExportSessionStatusCancelled:
                break;
            case AVAssetExportSessionStatusWaiting:
                break;
            case AVAssetExportSessionStatusExporting:
                break;
            case AVAssetExportSessionStatusCompleted:
                isSuccess = YES;
                break;
        }
        if (completedBlock) {
            completedBlock(isSuccess, msg);
        }
    }];
}
@end
