//
//  HandlerVideo.h
//

#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

typedef void(^SplitCompleteBlock)(BOOL success, UIImage *splitimg);
typedef void(^CompCompletedBlock)(BOOL success);
typedef void(^CompFinalCompletedBlock)(BOOL success, NSString *errorMsg);
typedef void(^CompProgressBlcok)(CGFloat progress);

typedef enum {
    VideoSpeedTypeNormal,
    VideoSpeedTypeFast,
    VideoSpeedTypeSlow
} VideoSpeedType;

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
 *@param isHaveAudio 视频是有声音，YES:创建音频轨道 NO:不创建音频轨道
 *@param completedBlock 完成回调
 */
- (void)combinationVideosWithVideoPath:(NSArray<NSString *> *)subsectionPaths
                          videoFullPath:(NSString *)videoFullPath
                           isHavaAudio:(BOOL)isHaveAudio
                           progressBlock:(CompProgressBlcok)progressBlock
                           completedBlock:(CompFinalCompletedBlock)completedBlock;

/**
 * 将视频分解成图片
 *@param fileUrl 视频路径
 *@param fps 帧率
 *@param progressImageBlock 进度回调
 *@param splitCompleteBlock 分解完成回调
 */
- (void)splitVideo:(NSURL *)fileUrl
               fps:(float)fps
              progressImageBlock:(CompProgressBlcok)progressImageBlock
              splitCompleteBlock:(SplitCompleteBlock) splitCompleteBlock;


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

@end
