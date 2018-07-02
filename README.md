## MaxVideo
多张图片合成视频；多个小视频合成大视频；添加静态图片水印；设置视频导出速率；多段音频合成

## Usage

导入 `HandlerVideo.h` 

```
/**
  *  图片合成视频
  *@param videoFullPath 合成路径
  *@param frameImgs 图片数组
  *@param fps 帧率
  *@param progressImageBlock 进度回调
  *@param completedBlock 完成回调
 */
- (void)composesVideoFullPath:(NSString *)videoFullPath
                    frameImgs:(NSArray<UIImage *> *)frameImgs
                          fps:(int32_t)fps
           progressImageBlock:(CompProgressBlcok)progressImageBlock
               completedBlock:(CompCompletedBlock)completedBlock;

/**
 *  多个小视频合成大视频
 *@param subsectionPaths 视频地址数组
 *@param videoFullPath 合成视频路径
 *@param completedBlock 完成回调
 */
- (void)combinationVideosWithVideoPath:(NSArray<NSString *> *)subsectionPaths videoFullPath:(NSString *)videoFullPath completedBlock:(CompFinalCompletedBlock)completedBlock;

/**
 * 将视频分解成图片
 *@param fileUrl 视频路径
 *@param fps 帧率
 *@param splitCompleteBlock 分解完成回调
 */
- (void)splitVideo:(NSURL *)fileUrl fps:(float)fps splitCompleteBlock:(SplitCompleteBlock) splitCompleteBlock;


/**
  视频添加静态图片水印

 @param watermaskImg 水印图片
 @param videoFullPath 合成视频路径
 @param completedBlock 完成回调
 */
- (void)addWatermaskVideoWithWatermaskImg:(UIImage *)watermaskImg inputVideoPath:(NSString *)inputVideoPath outputVideoFullPath:(NSString *)videoFullPath completedBlock:(CompFinalCompletedBlock)completedBlock;


/**
 设置视频导出速率

 @param speedType 速率类型
 @param inputVideoPath 视频源路径
 @param videoFullPath 导出路径
 @param completedBlock 完成回调
 */
- (void)setVideoSpeed:(VideoSpeedType)speedType inputVideoPath:(NSString *)inputVideoPath outputVideoFullPath:(NSString *)videoFullPath completedBlock:(CompFinalCompletedBlock)completedBlock;

```
导入`AudioTool.h` 头文件

```
/**
 音频合并

 @param subsectionPaths 合并路径数组
 @param audioFullPath 导出路径（.m4a格式）
 @param completedBlock 完成回调
 */
+ (void)combinationAudiosWithAudioPath:(NSArray<NSString *> *)subsectionPaths
                         audioFullPath:(NSString *)audioFullPath
                        completedBlock:(CompFinalCompletedBlock)completedBlock;
```


Example

- 将视频分解成图片
```
 if (![[NSFileManager defaultManager] fileExistsAtPath:kSplitImages]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:kSplitImages withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
   // 分解视频
    NSString *path = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    [[HandlerVideo sharedInstance] splitVideo:[NSURL fileURLWithPath:path] fps:10 splitCompleteBlock:^(BOOL success, NSMutableArray *splitimgs) {
        if (success && splitimgs.count != 0) {
            NSLog(@"----->> success");
            NSLog(@"---> splitimgs个数:%lu",(unsigned long)splitimgs.count);
        }
    }];

```

- 视频合并

```
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"video2" ofType:@"mp4"];
    self.conbineVideos = [NSMutableArray arrayWithObjects:path1,path2,nil];
    
    [[HandlerVideo sharedInstance] combinationVideosWithVideoPath:self.conbineVideos videoFullPath:kCombineVideo completedBlock:^(BOOL success, NSString *errorMsg) {
        if (success) {
            NSLog(@"---->  SUCCESS");
        }
    }];

```

- 设置视频速率

```
  // 正常
  self.speedType = VideoSpeedTypeNormal;
  // 快速
  self.speedType = VideoSpeedTypeFast;
  // 慢速
  self.speedType = VideoSpeedTypeSlow;
   
  NSString *path = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
  __weak typeof(self) WS = self;
  [[HandlerVideo sharedInstance] setVideoSpeed:self.speedType inputVideoPath:path outputVideoFullPath:@"/Users/VS/Desktop/video.mp4" completedBlock:^(BOOL success, NSString *msg) {
        if (success) {
            NSLog(@"---->  SUCCESS");
        } else {
            NSLog(@"---->> %@",msg);
        }
  }];
```

- 添加静态图片水印

```
    __weak typeof(self) WS = self;
    UIImage *waterImg = [UIImage imageNamed:@"paint_watermark.png"];
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    [[HandlerVideo sharedInstance] addWatermaskVideoWithWatermaskImg:waterImg inputVideoPath:path1 outputVideoFullPath:@"/Users/VS/Desktop/video.mp4" completedBlock:^(BOOL success, NSString *msg) {
        if (success) {
            NSLog(@"---->  SUCCESS");
        } else {
            NSLog(@"---->> %@",msg);
        }
    }];
```

- 音频合并

```
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"mp3"];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"mp3"];
    __weak typeof(self) WS = self;
    [AudioTool combinationAudiosWithAudioPath:@[path1, path2] audioFullPath:@"/Users/VS/Desktop/audio.m4a" completedBlock:^(BOOL success, NSString *msg) {
        if (success) {
            NSLog(@"---->  SUCCESS");
        } else {
            NSLog(@"---->> %@",msg);
        }
    }];
```
