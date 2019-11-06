//
//  HandlerVideo.m
//

#import "HandlerVideo.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

static HandlerVideo *instance = nil;

@interface HandlerVideo () {
    int32_t  _fps;
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

// 图片合成视频
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

// 视频合成
- (void)combinationVideosWithVideoPath:(NSArray<NSString *> *)subsectionPaths
                         videoFullPath:(NSString *)videoFullPath
                         isHavaAudio:(BOOL)isHaveAudio
                         progressBlock:(CompProgressBlcok)progressBlock
                        completedBlock:(CompFinalCompletedBlock)completedBlock {
    if (!subsectionPaths || subsectionPaths.count == 0) {
        NSLog(@"No such SubsectionNames");
        completedBlock(NO, @"合并失败");
        return;
    }
    NSDictionary *optDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    NSString *firstPath = subsectionPaths.firstObject;
    AVAsset *firstVideo = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:firstPath] options:optDict];
    NSArray *firstVideoTracks = [firstVideo tracksWithMediaType:AVMediaTypeVideo];

    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    // 视频轨道
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
   // 音频轨道
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    /**
     // 视频的方向, 根据视频的方向同步视频轨道方向, 可根据需求自行调整
     CGAffineTransform videoTransform = assetVideoTrack.preferredTransform;
     if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
     NSLog(@"垂直拍摄");
     videoTransform = CGAffineTransformMakeRotation(M_PI_2);
     }else if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
     NSLog(@"倒立拍摄");
     videoTransform = CGAffineTransformMakeRotation(-M_PI_2);
     }else if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
     NSLog(@"Home键右侧水平拍摄");
     videoTransform = CGAffineTransformMakeRotation(0);
     }else if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
     NSLog(@"Home键左侧水平拍摄");
     videoTransform = CGAffineTransformMakeRotation(M_PI);
     }
     // 根据视频的方向同步视频轨道方向
     videoTrack.preferredTransform = videoTransform;
     */
    
    // 解决拍的视频合成之后旋转90度的问题
    AVAssetTrack *assetVideoTrack = firstVideoTracks.lastObject;
    NSLog(@"======>> 默认尺寸%@", NSStringFromCGSize(assetVideoTrack.naturalSize));
    
    mixComposition.naturalSize = assetVideoTrack.naturalSize;
    [videoTrack setPreferredTransform:assetVideoTrack.preferredTransform];
    
   __block CMTime beginTime = kCMTimeZero;
   __block NSError *error = nil;
    [subsectionPaths enumerateObjectsUsingBlock:^(NSString *videoPath, NSUInteger idx, BOOL * _Nonnull stop) {
        AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:optDict];
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        if (tracks <= 0) {
            *stop = YES;
            completedBlock(NO, @"合成失败");
            return;
        }
      
      BOOL success = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:tracks.firstObject atTime:beginTime error:&error];
        if (!success) {
            *stop = YES;
            completedBlock(NO, error.localizedDescription);
            return;
        }
        
        if (isHaveAudio) {   // 根据视频是否有声音设置音轨
            NSArray *audioTracks = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
            if (audioTracks.count > 0) {
                [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:audioTracks.firstObject atTime:beginTime error:nil];
            }
        }
        beginTime = CMTimeAdd(beginTime, videoAsset.duration);
    }];
    
   // 注释内容根据自己需要自行进行处理(简单的视频拼接，可忽略)
    // 用来生成video的组合指令，包含多段instruction。可以决定最终视频的尺寸，裁剪需要在这里进行
//    AVMutableVideoComposition *composition = [AVMutableVideoComposition videoComposition];
//    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//
//    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
//
//    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
//    composition.instructions = [NSArray arrayWithObject: instruction];
//    composition.renderSize = assetVideoTrack.naturalSize;
//    composition.frameDuration = CMTimeMake(1, 30); // 30 fps
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFullPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:videoFullPath error:nil];
    }

    /**
     我们可以通过设置AVCaptureSession的一些属性来改变捕捉画面的质量
     但是要注意:size相关的属性的时候需要首先进行测试设备是否支持
     判断方法是  canSetSessionPreset
     
     AVAssetExportPresetLowQuality       低质量 可以通过移动网络分享(默认低质量)
     AVAssetExportPresetMediumQuality    中等质量 可以通过WIFI网络分享
     AVAssetExportPresetHighestQuality   高等质量
     AVAssetExportPreset640x480
     AVAssetExportPreset960x540
     AVAssetExportPreset1280x720    720pHD
     AVAssetExportPreset1920x1080   1080pHD
     AVAssetExportPreset3840x2160
     */
    AVAssetExportSession *exportor = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exportor.outputFileType = AVFileTypeMPEG4;
    exportor.outputURL = [NSURL fileURLWithPath:videoFullPath];
    exportor.shouldOptimizeForNetworkUse = YES;
//    exportor.videoComposition = composition;

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
                progressBlock(1);
                isSuccess = YES;
                break;
        }
        if (completedBlock) {
            completedBlock(isSuccess, msg);
        }
    }];
    // 监听导出进度
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self monitorExportProgress:exportor progressImageBlock:progressBlock completedBlock:completedBlock];
    });
}

- (void)monitorExportProgress:(AVAssetExportSession *)exportSession progressImageBlock:(CompProgressBlcok)progressImageBlock completedBlock:(CompFinalCompletedBlock)completedBlock{  // 取巧的办法: 由于是两个并行任务，
    double delayInSeconds = 0.1;
    int64_t delta = (int64_t)delayInSeconds * NSEC_PER_SEC;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delta);
    __weak typeof(self) WS = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        AVAssetExportSessionStatus status = exportSession.status;
        if (status == AVAssetExportSessionStatusExporting || status == AVAssetExportSessionStatusWaiting) {
//            NSLog(@"------>> %f",exportSession.progress);
            if (progressImageBlock) {
                progressImageBlock(exportSession.progress);
            }
            [WS monitorExportProgress:exportSession progressImageBlock:progressImageBlock completedBlock:completedBlock];
        }
    });
}

// 视频分解
- (void)splitVideo:(NSURL *)fileUrl fps:(float)fps progressImageBlock:(CompProgressBlcok)progressImageBlock  splitCompleteBlock:(SplitCompleteBlock)splitCompleteBlock {
    if (!fileUrl) {
        return;
    }
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
    //防止时间出现偏差(生成高精度的缩略图，耗费时间略长，如果只是想要缩略图无具体要求，可注释掉)
    imgGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imgGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    NSInteger timesCount = [times count];
    [imgGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        printf("current-----: %lld\n", requestedTime.value);
        printf("timeScale----: %d\n",requestedTime.timescale);
        
        if (progressImageBlock) {
            CGFloat progress = requestedTime.value * 1.0 / timesCount;
            progressImageBlock(progress);
        }
        
        BOOL isSuccess = NO;
        UIImage *frameImg = nil;
        switch (result) {
            case AVAssetImageGeneratorCancelled:
                NSLog(@"Cancelled");
                [imgGenerator cancelAllCGImageGeneration];
                break;
            case AVAssetImageGeneratorFailed:
                NSLog(@"Failed");
                [imgGenerator cancelAllCGImageGeneration];
                break;
            case AVAssetImageGeneratorSucceeded: {
                isSuccess = YES;
                frameImg = [UIImage imageWithCGImage:image];
            }
                break;
        }
        if (splitCompleteBlock) {
            splitCompleteBlock(isSuccess,frameImg);
        }
    }];
}

// 添加水印
- (void)addWatermaskVideoWithWatermaskImg:(UIImage *)watermaskImg inputVideoPath:(NSString *)inputVideoPath outputVideoFullPath:(NSString *)videoFullPath completedBlock:(CompFinalCompletedBlock)completedBlock {
    NSDictionary *optDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:inputVideoPath] options:optDict];
    
    AVMutableComposition *videoComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [videoComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *videoTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count > 0) {
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoTracks.firstObject atTime:kCMTimeZero error:nil];
    }
    AVAssetTrack *assetVideoTrack = videoTracks.firstObject;
    [videoTrack setPreferredTransform:assetVideoTrack.preferredTransform];
    
    AVMutableCompositionTrack *audioTrack = [videoComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *audioTracks = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count > 0) {
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:audioTracks.firstObject  atTime:kCMTimeZero error:nil];
    }
        
    // 添加水印
    CGSize sizeOfVideo = [assetVideoTrack naturalSize];
    AVMutableVideoComposition *composition = [AVMutableVideoComposition videoComposition];
    CALayer *watermaskLayer = [self buildLayerLayerSize:sizeOfVideo waterImg:watermaskImg];
    if (watermaskLayer) {
        CALayer *animationLayer = [CALayer layer];
        animationLayer.frame = CGRectMake(0, 0, sizeOfVideo.width, sizeOfVideo.height);
        
        CALayer *videoLayer = [CALayer layer];
        videoLayer.frame = CGRectMake(0, 0, sizeOfVideo.width, sizeOfVideo.height);
        
        [animationLayer addSublayer:videoLayer];
        [animationLayer addSublayer:watermaskLayer];
        animationLayer.geometryFlipped = YES;
        
        composition.frameDuration=CMTimeMake(1, 30);
        composition.renderSize = sizeOfVideo;
        AVVideoCompositionCoreAnimationTool *animationTool =
        [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                                                                                     inLayer:animationLayer];
        composition.animationTool = animationTool;
        
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoComposition duration]);
       
        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:assetVideoTrack];
        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
        composition.instructions = [NSArray arrayWithObject: instruction];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFullPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:videoFullPath error:nil];
    }
    
    AVAssetExportSession *exportor = [[AVAssetExportSession alloc] initWithAsset:videoComposition presetName:AVAssetExportPresetHighestQuality];
    exportor.outputFileType = AVFileTypeMPEG4;
    exportor.outputURL = [NSURL fileURLWithPath:videoFullPath];
    exportor.shouldOptimizeForNetworkUse = YES;
    if (watermaskLayer) {
        exportor.videoComposition = composition;
    }
    [exportor exportAsynchronouslyWithCompletionHandler:^{
        BOOL isSuccess = NO;
        NSString *msg = @"水印添加完成";
        switch (exportor.status) {

            case AVAssetExportSessionStatusFailed:
                NSLog(@"HandlerVideo -> addVidesMaskError: %@", exportor.error.localizedDescription);
                msg = @"水印添加失败";
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

- (CALayer *)buildLayerLayerSize:(CGSize)layerSize waterImg:(UIImage *)waterImg{
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, layerSize.width, layerSize.height);
    //    parentLayer.opacity = 0.0f;
    CALayer *imageLayer = [self makeImageLayerWithLayerSize:layerSize waterImg:waterImg];
    [parentLayer addSublayer:imageLayer];
    return parentLayer;
}

// 图片Layer
- (CALayer *)makeImageLayerWithLayerSize:(CGSize)layerSize waterImg:(UIImage *)waterImg{
    CGFloat scale = layerSize.width / 375;
    CGRect bounds = [self getWaterImgSizeWithImg:waterImg size:layerSize textWaterH:10 + 20 * scale];
    CALayer *layer = [CALayer layer];
    layer.contents = (id) waterImg.CGImage;
    layer.frame = bounds;
    layer.allowsEdgeAntialiasing = YES;
    return layer;
}

- (CGRect)getWaterImgSizeWithImg:(UIImage *)waterImg size:(CGSize)size textWaterH:(CGFloat)textWaterH {
    // 水印图片尺寸设置了比例，距离间距，为了方便测试用，实际看开发需要
    CGFloat scale = 0.3;
    scale = size.width / 375 * scale;
    CGFloat x = size.width -  waterImg.size.width * scale - 10;
    CGFloat imgY = size.height - waterImg.size.height * scale;
    CGFloat y = imgY - textWaterH;
    CGFloat w = waterImg.size.width * scale;
    CGFloat h = waterImg.size.height * scale;
    CGRect rect = CGRectMake(x, y, w, h);
    return rect;
}

// 设置视频速率
- (void)setVideoSpeed:(VideoSpeedType)speedType inputVideoPath:(NSString *)inputVideoPath outputVideoFullPath:(NSString *)videoFullPath completedBlock:(CompFinalCompletedBlock)completedBlock {
    NSDictionary *optDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:inputVideoPath] options:optDict];
    
    AVMutableComposition *videoComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [videoComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *videoTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count > 0) {
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoTracks.firstObject atTime:kCMTimeZero error:nil];
    }
    AVAssetTrack *assetVideoTrack = videoTracks.firstObject;
    [videoTrack setPreferredTransform:assetVideoTrack.preferredTransform];
    
    AVMutableCompositionTrack *audioTrack = [videoComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *audioTracks = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count > 0) {
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:audioTracks.firstObject  atTime:kCMTimeZero error:nil];
    }
    
    CGFloat scale = 1.0;
    switch (speedType) {
        case VideoSpeedTypeNormal:
            scale = 1.0;
            break;
        case VideoSpeedTypeFast:
             scale = 0.2f;  // 快速 x5
            break;
        case VideoSpeedTypeSlow:
            scale = 4.0f;  // 慢速 x4
            break;
        default:
            break;
    }
    
    // 根据速度比率调节音频和视频
    [videoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(videoAsset.duration.value, videoAsset.duration.timescale)) toDuration:CMTimeMake(videoAsset.duration.value * scale , videoAsset.duration.timescale)];
    [audioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(videoAsset.duration.value, videoAsset.duration.timescale)) toDuration:CMTimeMake(videoAsset.duration.value * scale, videoAsset.duration.timescale)];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFullPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:videoFullPath error:nil];
    }
    
    AVAssetExportSession *exportor = [[AVAssetExportSession alloc] initWithAsset:videoComposition presetName:AVAssetExportPresetHighestQuality];
    exportor.outputFileType = AVFileTypeMPEG4;
    exportor.outputURL = [NSURL fileURLWithPath:videoFullPath];
    exportor.shouldOptimizeForNetworkUse = YES;
   
    [exportor exportAsynchronouslyWithCompletionHandler:^{
        BOOL isSuccess = NO;
        NSString *msg = @"设置速率成功";
        switch (exportor.status) {
                
            case AVAssetExportSessionStatusFailed:
                NSLog(@"HandlerVideo -> setSpeedError: %@", exportor.error.localizedDescription);
                msg = @"设置速率成功失败";
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
