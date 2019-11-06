//
//  ViewController.m
//  MaxVideo
//
//  Created by VS on 16/9/30.
//  Copyright © 2016年 VS. All rights reserved.
//

#import "ViewController.h"

#import "HandlerVideo.h"
#import "AudioTool.h"

#define kCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

#define kCombineVideo [kCachePath stringByAppendingPathComponent:@"combine.mp4"]
#define kSplitImages  [kCachePath stringByAppendingPathComponent:@"images"]

@interface ViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@property (nonatomic, strong) NSMutableArray *conbineVideos;

@property (nonatomic, assign) VideoSpeedType speedType;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",kCombineVideo);
}

#pragma mark - Method
- (void)showSuccessAlert:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    });
}

#pragma mark - Action

// 视频合并
- (IBAction)combinationVideoBtnTap:(UIButton *)sender {
    // 合并视频 (注：将视频导出路径设置为桌面方便测试，实际开发存入沙盒即可)
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"video4" ofType:@"mp4"];
    NSString *path3 = [[NSBundle mainBundle] pathForResource:@"video3" ofType:@"mp4"];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    
    self.conbineVideos = [NSMutableArray arrayWithObjects:path1,path2,path3,nil];
    __weak typeof(self) WS = self;
    [[HandlerVideo sharedInstance] combinationVideosWithVideoPath:self.conbineVideos videoFullPath:@"/Users/VS/Desktop/video.mp4" isHavaAudio:YES progressBlock:^(CGFloat progress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            WS.progressView.progress = progress;
        });
    }  completedBlock:^(BOOL success, NSString *msg) {
        if (success) {
            NSLog(@"---->  SUCCESS");
            
            [WS showSuccessAlert:msg];
            
        } else {
            NSLog(@"---->> %@",msg);
        }
    }];
}

// 加静态水印
- (IBAction)addVideoWatermaskBtnTap:(UIButton *)sender {
    // 加静态图片水印
    __weak typeof(self) WS = self;
    UIImage *waterImg = [UIImage imageNamed:@"paint_watermark.png"];
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    [[HandlerVideo sharedInstance] addWatermaskVideoWithWatermaskImg:waterImg inputVideoPath:path1 outputVideoFullPath:@"/Users/VS/Desktop/video.mp4" completedBlock:^(BOOL success, NSString *msg) {
        if (success) {
            NSLog(@"---->  SUCCESS");
            [WS showSuccessAlert:msg];
        } else {
            NSLog(@"---->> %@",msg);
        }
    }];
}

// 视频分解
- (IBAction)splitVideoBtnTap:(UIButton *)sender {
    __weak typeof(self) WS = self;
    if (![[NSFileManager defaultManager] fileExistsAtPath:kSplitImages]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:kSplitImages withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 分解视频
    NSString *path = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    [[HandlerVideo sharedInstance] splitVideo:[NSURL fileURLWithPath:path] fps:10 progressImageBlock:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WS.progressView.progress = progress;
        });
    }  splitCompleteBlock:^(BOOL success, UIImage *splitimg) {
        if (success && splitimg) {
            NSLog(@"----->> split success");
        }
    }];
}

// 设置速率
- (IBAction)onSetSpeedBtnTap:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"正常", @"快速",@"慢速", nil];
  
    [actionSheet showInView:self.view];
}

// 音频合并
- (IBAction)combineAudioBtnTap:(UIButton *)sender {
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"mp3"];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"mp3"];
    __weak typeof(self) WS = self;
    [AudioTool combinationAudiosWithAudioPath:@[path1, path2] audioFullPath:@"/Users/VS/Desktop/audio.m4a" completedBlock:^(BOOL success, NSString *msg) {
        if (success) {
            NSLog(@"---->  SUCCESS");
            [WS showSuccessAlert:msg];
        } else {
            NSLog(@"---->> %@",msg);
        }
    }];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {  // 正常
        self.speedType = VideoSpeedTypeNormal;
    } else if (buttonIndex == 1) { // 快速
        self.speedType = VideoSpeedTypeFast;
    }else if (buttonIndex == 2) {  // 慢速
        self.speedType = VideoSpeedTypeSlow;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    __weak typeof(self) WS = self;
    [[HandlerVideo sharedInstance] setVideoSpeed:self.speedType inputVideoPath:path outputVideoFullPath:@"/Users/VS/Desktop/video.mp4" completedBlock:^(BOOL success, NSString *msg) {
        if (success) {
            NSLog(@"---->  SUCCESS");
            [WS showSuccessAlert:msg];
        } else {
            NSLog(@"---->> %@",msg);
        }
    }];
}

@end
