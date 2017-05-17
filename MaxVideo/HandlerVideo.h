//
//  HandlerVideo.h
//

#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

typedef void(^SplitCompleteBlock)(BOOL success, NSMutableArray *splitimgs);
typedef void(^CompCompletedBlock)(BOOL success);
typedef void(^CompFinalCompletedBlock)(BOOL success, NSString *errorMsg);
typedef void(^CompProgressBlcok)(CGFloat progress);

@interface HandlerVideo : NSObject
+ (instancetype)sharedInstance;

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
@end
