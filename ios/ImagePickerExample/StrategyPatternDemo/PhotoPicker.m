//
//  PhotoPicker.m
//  RNSyanImagePicker
//
//  Created by CookieJ on 2018/4/13.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "PhotoPicker.h"
#import "NSDictionary+SYSafeConvert.h"
#import "TZImagePickerController.h"
#import "ImagePickerHelper.h"

@implementation PhotoPicker

- (void)pickAssetsWithOptions:(NSDictionary *)options completion:(PickSuccessBlock)completion failure:(PickErrorBlock)failure {
	
		// 照片最大可选张数
		NSInteger imageCount = [options sy_integerForKey:@"imageCount"];
		// 显示内部拍照按钮
		BOOL isCamera        = [options sy_boolForKey:@"isCamera"];
		BOOL isCrop          = [options sy_boolForKey:@"isCrop"];
		BOOL isGif           = [options sy_boolForKey:@"isGif"];
		BOOL showCropCircle  = [options sy_boolForKey:@"showCropCircle"];
		NSInteger CropW      = [options sy_integerForKey:@"CropW"];
		NSInteger CropH      = [options sy_integerForKey:@"CropH"];
		NSInteger circleCropRadius = [options sy_integerForKey:@"circleCropRadius"];
		NSInteger   quality  = [options sy_integerForKey:@"quality"];
		
		TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:imageCount delegate:nil];
		
		imagePickerVc.maxImagesCount = imageCount;
		imagePickerVc.allowPickingGif = isGif; // 允许GIF
		imagePickerVc.allowTakePicture = isCamera; // 允许用户在内部拍照
		imagePickerVc.allowPickingVideo = NO; // 不允许视频
		imagePickerVc.allowPickingOriginalPhoto = NO; // 允许原图
		imagePickerVc.allowCrop = isCrop;   // 裁剪
		imagePickerVc.allowPickingVideo = YES;
		
		if (imageCount == 1) {
			// 单选模式
			imagePickerVc.showSelectBtn = NO;
			imagePickerVc.allowPreview = NO;
			
			if(isCrop){
				if(showCropCircle) {
					imagePickerVc.needCircleCrop = showCropCircle; //圆形裁剪
					imagePickerVc.circleCropRadius = circleCropRadius; //圆形半径
				} else {
					CGFloat x = ([[UIScreen mainScreen] bounds].size.width - CropW) / 2;
					CGFloat y = ([[UIScreen mainScreen] bounds].size.height - CropH) / 2;
					imagePickerVc.cropRect = imagePickerVc.cropRect = CGRectMake(x,y,CropW,CropH);
				}
			}
		}
		
		__block TZImagePickerController *weakPicker = imagePickerVc;
		[imagePickerVc setDidFinishPickingPhotosWithInfosHandle:^(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos) {
			NSMutableArray *selectedPhotos = [NSMutableArray array];
			[weakPicker showProgressHUD];
			if (imageCount == 1 && isCrop) {
				[selectedPhotos addObject:[ImagePickerHelper handleImageData:photos[0] quality:quality]];
			} else {
				[infos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
					[selectedPhotos addObject:[ImagePickerHelper handleImageData:photos[idx] quality:quality]];
				}];
			}
			completion(selectedPhotos);
			[weakPicker hideProgressHUD];
		}];
		
		[imagePickerVc setImagePickerControllerDidCancelHandle:^{
			failure(nil, nil);
		}];
		
		[RCTPresentedViewController() presentViewController:imagePickerVc animated:YES completion:nil];
}

@end
