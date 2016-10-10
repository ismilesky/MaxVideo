//
//  HandlerVideo.m
//

#import "HandlerVideo.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

static HandlerVideo *instance = nil;

@interface HandlerVideo () {
    int32_t _fps;
}
@end

@implementation HandlerVideo

+ (instancetype)sharedInstance {
    if (!instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [HandlerVideo new];
        });
    }
    return instance;
}

- (instancetype)copyWithZone:(struct _NSZone *)zone {
    return [HandlerVideo sharedInstance];
}

#pragma mark - Method
- (void)composesVideoFullPath:(NSString *)videoFullPath
               frameImgs:(NSArray<UIImage *> *)frameImgs
                          fps:(int32_t)fps
           progressImageBlock:(CompProgressBlcok)progressImageBlock
               completedBlock:(CompCompletedBlock)completedBlock {
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFullPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:videoFullPath error:nil];
    }

    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:videoFullPath]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error = %@", [error localizedDescription]);
    
    //获取原视频尺寸
    UIImage *img = frameImgs.firstObject;
    CGSize size = CGSizeMake(CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage));
    //    NSLog(@"Size: %@", NSStringFromCGSize(size));
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput]) {
        //        printf("can add\n");
    } else {
        //        printf("can't add\n");
    }
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue", DISPATCH_QUEUE_SERIAL);
    __block int frame = -1;
    NSInteger count = frameImgs.count;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while ([writerInput isReadyForMoreMediaData]) {
            if(++frame >= count) {
                [writerInput markAsFinished];
                [videoWriter finishWriting];
                printf("comp completed\n");
                if (completedBlock) {
                    completedBlock(YES);
                }
                break;
            }
            
            CVPixelBufferRef buffer = NULL;
            UIImage *currentFrameImg = frameImgs[frame];
            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[currentFrameImg CGImage] size:size];
            if (progressImageBlock) {
                CGFloat progress = frame * 1.0 / count;
                progressImageBlock(progress);
            }
            if (buffer) {
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, fps)]) {
                    NSLog(@"FAIL");
                    if (completedBlock) {
                        completedBlock(NO);
                    }
                } else {
                    CFRelease(buffer);
                }
            }
        }
    }];
}

- (void)composesVideoFullPath:(NSString *)videoFullPath
                    frameImgPathes:(NSArray<UIImage *> *)frameImgPathes
                          fps:(int32_t)fps
           progressImageBlock:(CompProgressBlcok)progressImageBlock
               completedBlock:(CompCompletedBlock)completedBlock {
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFullPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:videoFullPath error:nil];
    }
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:videoFullPath]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error = %@", [error localizedDescription]);
    
    //获取原视频尺寸
    UIImage *img = frameImgPathes.firstObject;
    CGSize size = CGSizeMake(CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage));
    //    NSLog(@"Size: %@", NSStringFromCGSize(size));
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput]) {
        //        printf("can add\n");
    } else {
        //        printf("can't add\n");
    }
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue", DISPATCH_QUEUE_SERIAL);
    __block int frame = -1;
    NSInteger count = frameImgPathes.count;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while ([writerInput isReadyForMoreMediaData]) {
            if(++frame >= count) {
                [writerInput markAsFinished];
                [videoWriter finishWriting];
                printf("comp completed\n");
                if (completedBlock) {
                    completedBlock(YES);
                }
                break;
            }
            
            CVPixelBufferRef buffer = NULL;
            UIImage *currentFrameImg = frameImgPathes[frame];
            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[currentFrameImg CGImage] size:size];
            currentFrameImg = nil;
            if (progressImageBlock) {
                CGFloat progress = frame * 1.0 / count;
                progressImageBlock(progress);
            }
            if (buffer) {
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, fps)]) {
                    NSLog(@"FAIL");
                    if (completedBlock) {
                        completedBlock(NO);
                    }
                } else {
                    CFRelease(buffer);
                    buffer = NULL;
                }
            }
        }
    }];
}

- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
                                          size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void)combinationVideosWithVideoPath:(NSArray<NSString *> *)subsectionPaths videoFullPath:(NSString *)videoFullPath completedBlock:(CompFinalCompletedBlock)completedBlock {
    if (!subsectionPaths || subsectionPaths.count == 0) {
        NSLog(@"No such SubsectionNames");
        completedBlock(NO, @"合并失败");
        return;
    }
    subsectionPaths = [[subsectionPaths reverseObjectEnumerator] allObjects];
    NSDictionary *optDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    NSString *firstPath = subsectionPaths.firstObject;
    AVAsset *firstVideo = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:firstPath] options:optDict];
    
    AVMutableComposition *videoComposition = [AVMutableComposition composition];
    __block AVMutableCompositionTrack *track = [videoComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *firstVideoTracks = [firstVideo tracksWithMediaType:AVMediaTypeVideo];
    if (firstVideoTracks.count <= 0) {
        completedBlock(NO, @"合成失败");
        return;
    }
    [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideo.duration) ofTrack:firstVideoTracks.firstObject atTime:kCMTimeZero error:nil];
    /**
     PS: 如果视频有声音,就需要将注释掉的打开
     */
//    __block AVMutableCompositionTrack *audioTrack = [videoComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    NSArray *firstVideoAudioTracks = [firstVideo tracksWithMediaType:AVMediaTypeAudio];
//    if (firstVideoAudioTracks.count > 0) {
//        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideo.duration) ofTrack:firstVideoAudioTracks.firstObject  atTime:kCMTimeZero error:nil];
//    }
    
    [subsectionPaths enumerateObjectsUsingBlock:^(NSString *videoPath, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            return;
        }
        AVURLAsset *currentVideo = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:optDict];
        NSArray *tracks = [currentVideo tracksWithMediaType:AVMediaTypeVideo];
        if (tracks <= 0) {
            *stop = YES;
            completedBlock(NO, @"合成失败");
            return;
        }
        [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, currentVideo.duration) ofTrack:tracks.firstObject atTime:kCMTimeZero error:nil];
//        NSArray *audioTracks = [currentVideo tracksWithMediaType:AVMediaTypeAudio];
//        if (audioTracks.count > 0) {
//            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, currentVideo.duration) ofTrack:audioTracks.firstObject atTime:kCMTimeZero error:nil];
//        }
    }];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFullPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:videoFullPath error:nil];
    }

    AVAssetExportSession *exportor = [[AVAssetExportSession alloc] initWithAsset:videoComposition presetName:AVAssetExportPresetLowQuality];
    exportor.outputFileType = AVFileTypeMPEG4;
    exportor.outputURL = [NSURL fileURLWithPath:videoFullPath];
    exportor.shouldOptimizeForNetworkUse = YES;
    [exportor exportAsynchronouslyWithCompletionHandler:^{
        BOOL isSuccess = NO;
        NSString *msg = @"合并完成";
        switch (exportor.status) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"HandlerVideo -> combinationVidesError: %@", exportor.error.localizedDescription);
                msg = @"合并失败";
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


- (void)splitVideo:(NSURL *)fileUrl fps:(float)fps splitCompleteBlock:(SplitCompleteBlock)splitCompleteBlock {
    if (!fileUrl) {
        return;
    }
    NSMutableArray *splitImages = [NSMutableArray array];
    NSDictionary *optDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *avasset = [[AVURLAsset alloc] initWithURL:fileUrl options:optDict];
    
    CMTime cmtime = avasset.duration; //视频时间信息结构体
    Float64 durationSeconds = CMTimeGetSeconds(cmtime); //视频总秒数
    
    NSMutableArray *times = [NSMutableArray array];
    Float64 totalFrames = durationSeconds * fps; //获得视频总帧数
    CMTime timeFrame;
    for (int i = 1; i <= totalFrames; i++) {
        timeFrame = CMTimeMake(i, fps); //第i帧  帧率
        NSValue *timeValue = [NSValue valueWithCMTime:timeFrame];
        [times addObject:timeValue];
    }
    
    AVAssetImageGenerator *imgGenerator = [[AVAssetImageGenerator alloc] initWithAsset:avasset];
    //防止时间出现偏差
    imgGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imgGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    NSInteger timesCount = [times count];
    [imgGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        printf("current-----: %lld\n", requestedTime.value);
        printf("timeScale----: %d\n",requestedTime.timescale);
        BOOL isSuccess = NO;
        switch (result) {
            case AVAssetImageGeneratorCancelled:
                NSLog(@"Cancelled");
                break;
            case AVAssetImageGeneratorFailed:
                NSLog(@"Failed");
                break;
            case AVAssetImageGeneratorSucceeded: {
                UIImage *frameImg = [UIImage imageWithCGImage:image];
                [splitImages addObject:frameImg];
                
                if (requestedTime.value == timesCount) {
                    isSuccess = YES;
                    NSLog(@"completed");
                }
            }
                break;
        }
        if (splitCompleteBlock) {
            splitCompleteBlock(isSuccess,splitImages);
        }
    }];
}

@end
