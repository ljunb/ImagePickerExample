//
//  ImagePickerManager.h
//  RNSyanImagePicker
//
//  Created by CookieJ on 2018/4/13.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TZImagePickerController.h"

/// 所有策略将定义在此
typedef NS_ENUM(NSInteger, ImagePickerStrategy)
{
	ImagePickerStrategyPhoto = 0, // 选择图片
	ImagePickerStrategyTakePhoto = 1, // 拍照
	ImagePickerStrategyVideo = 2, // 选择视频
};

/// 选择图片成功的回调
typedef void(^ManagerPickCompletionBlock)(NSArray * photos);
/// 取消选择的回调
typedef void(^MnagerPickErrorBlock)();

@interface ImagePickerManager : NSObject <TZImagePickerControllerDelegate>

/**
 策略列表
 */
@property (nonatomic, strong) NSArray *strategyList;

/**
 拍照选项
 */
@property (nonatomic, strong) NSDictionary *cameraOptions;


/**
 基于策略模式来实现图片选择，管理类只暴露选择成功或是失败接口，具体的选择逻辑由具体的策略实现

 @param strategy 具体的策略名称
 @param completion 选择成功回调
 @param failure 选择失败回调
 */
- (void)pickAssetsWithStrategy:(ImagePickerStrategy)strategy
										completion:(ManagerPickCompletionBlock)completion
											 failure:(MnagerPickErrorBlock)failure;

@end
