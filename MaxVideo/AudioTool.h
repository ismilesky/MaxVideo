//
//  AudioTool.h
//  MaxVideo
//
//  Created by VS on 2018/7/2.
//  Copyright © 2018年 VS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompFinalCompletedBlock)(BOOL success, NSString *errorMsg);

@interface AudioTool : NSObject

/**
 音频合并

 @param subsectionPaths 合并路径数组
 @param audioFullPath 导出路径（.m4a格式）
 @param completedBlock 完成回调
 */
+ (void)combinationAudiosWithAudioPath:(NSArray<NSString *> *)subsectionPaths
                         audioFullPath:(NSString *)audioFullPath
                        completedBlock:(CompFinalCompletedBlock)completedBlock;
@end
