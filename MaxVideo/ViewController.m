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


@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *conbineVideos;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path1 = @"/Users/vs/Desktop/07F3E1F6-534A-4339-A945-4FA5939E5F55.mp4";
    NSString *path2 = @"/Users/vs/Desktop/F6220BFB-6550-4085-B8F1-BAA2F39907F4.mp4";
    self.conbineVideos = [NSMutableArray arrayWithObjects:path1,path2,nil];
    NSLog(@"%@",kCombineVideo);
    
    [[HandlerVideo sharedInstance] combinationVideosWithVideoPath:self.conbineVideos videoFullPath:kCombineVideo completedBlock:^(BOOL success, NSString *errorMsg) {
        if (success) {
            NSLog(@"---->  SUCCESS");
        }
    }];

}



@end
