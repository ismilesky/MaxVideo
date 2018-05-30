//
//  ViewController.m
//  MaxVideo
//
//  Created by VS on 16/9/30.
//  Copyright © 2016年 VS. All rights reserved.
//

#import "ViewController.h"

#import "HandlerVideo.h"

#define kCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

#define kCombineVideo [kCachePath stringByAppendingPathComponent:@"combine.mp4"]
#define kSplitImages  [kCachePath stringByAppendingPathComponent:@"images"]

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *conbineVideos;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 合并视频 (注：将视频导出路径设置为桌面方便测试，实际开发存入沙盒即可)
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"video2" ofType:@"mp4"];
    
    self.conbineVideos = [NSMutableArray arrayWithObjects:path1,path2,nil];
    NSLog(@"%@",kCombineVideo);
    
    [[HandlerVideo sharedInstance] combinationVideosWithVideoPath:self.conbineVideos videoFullPath:@"/Users/VS/Desktop/video.mp4" completedBlock:^(BOOL success, NSString *errorMsg) {
        if (success) {
            NSLog(@"---->  SUCCESS");
        } else {
            NSLog(@"---->> %@",errorMsg);
        }
    }];

    
/************************************************************************/
    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:kSplitImages]) {
//        [[NSFileManager defaultManager]createDirectoryAtPath:kSplitImages withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    
//   // 分解视频
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
//    [[HandlerVideo sharedInstance] splitVideo:[NSURL fileURLWithPath:path] fps:10 splitCompleteBlock:^(BOOL success, NSMutableArray *splitimgs) {
//        if (success && splitimgs.count != 0) {
//            NSLog(@"----->> success");
//            NSLog(@"---> splitimgs个数:%lu",(unsigned long)splitimgs.count);
//        }
//    }];
}



@end
