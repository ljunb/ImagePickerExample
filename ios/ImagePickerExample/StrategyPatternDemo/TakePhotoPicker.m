//
//  TakePhotoPicker.m
//  RNSyanImagePicker
//
//  Created by CookieJ on 2018/4/13.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "TakePhotoPicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZImageManager.h"
#import "TZImagePickerController.h"
#import "NSDictionary+SYSafeConvert.h"
#import "ImagePickerHelper.h"

@interface TakePhotoPicker()
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, copy) PickSuccessBlock successBlock;
@property (nonatomic, copy) PickErrorBlock errorBlock;
@property (nonatomic, strong) NSDictionary *cameraOptions;
@end

@implementation TakePhotoPicker

- (void)pickAssetsWithOptions:(NSDictionary *)options completion:(PickSuccessBlock)completion failure:(PickErrorBlock)failure {
	self.successBlock = completion;
	self.errorBlock = failure;
	self.cameraOptions = options;
	[self checkAuthorizationStatusIfNeed];
}

- (void)checkAuthorizationStatusIfNeed {
	AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
		// 无相机权限 做一个友好的提示
		[self showNoAuthorizationAlert];
	} else if (authStatus == AVAuthorizationStatusNotDetermined) {
		// fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
		if (iOS7Later) {
			[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
				if (granted) {
					dispatch_sync(dispatch_get_main_queue(), ^{
						[self checkAuthorizationStatusIfNeed];
					});
				}
			}];
		} else {
			[self checkAuthorizationStatusIfNeed];
		}
		// 拍照之前还需要检查相册权限
	} else if ([TZImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
		[self showNoAuthorizationAlert];
	} else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
		[[TZImageManager manager] requestAuthorizationWithCompletion:^{
			[self checkAuthorizationStatusIfNeed];
		}];
	} else {
		[self pushImagePickerController];
	}
}

- (void)showNoAuthorizationAlert {
	if (iOS8Later) {
		UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
		[alert show];
	} else {
		UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
		[alert show];
	}
}

// 调用相机
- (void)pushImagePickerController {
	UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
	if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
		self.imagePickerVc.sourceType = sourceType;
		if(iOS8Later) {
			self.imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
		}
		[RCTPresentedViewController() presentViewController:self.imagePickerVc animated:YES completion:nil];
	} else {
		NSLog(@"模拟器中无法打开照相机,请在真机中使用");
	}
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissViewControllerAnimated:YES completion:nil];
	NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
	if ([type isEqualToString:@"public.image"]) {
		
		TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
		tzImagePickerVc.sortAscendingByModificationDate = NO;
		[tzImagePickerVc showProgressHUD];
		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
		
		// save photo and get asset / 保存图片，获取到asset
		[[TZImageManager manager] savePhotoWithImage:image location:NULL completion:^(NSError *error){
			if (error) {
				[tzImagePickerVc hideProgressHUD];
				NSLog(@"图片保存失败 %@",error);
			} else {
				[[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES needFetchAssets:YES completion:^(TZAlbumModel *model) {
					[[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
						[tzImagePickerVc hideProgressHUD];
						
						TZAssetModel *assetModel = [models firstObject];
						BOOL isCrop          = [self.cameraOptions sy_boolForKey:@"isCrop"];
						BOOL showCropCircle  = [self.cameraOptions sy_boolForKey:@"showCropCircle"];
						NSInteger CropW      = [self.cameraOptions sy_integerForKey:@"CropW"];
						NSInteger CropH      = [self.cameraOptions sy_integerForKey:@"CropH"];
						NSInteger circleCropRadius = [self.cameraOptions sy_integerForKey:@"circleCropRadius"];
						NSInteger   quality = [self.cameraOptions sy_integerForKey:@"quality"];
						
						if (isCrop) {
							TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
								self.successBlock(@[[ImagePickerHelper handleImageData:cropImage quality:quality]]);
							}];
							imagePicker.allowCrop = isCrop;   // 裁剪
							if(showCropCircle) {
								imagePicker.needCircleCrop = showCropCircle; //圆形裁剪
								imagePicker.circleCropRadius = circleCropRadius; //圆形半径
							} else {
								CGFloat x = ([[UIScreen mainScreen] bounds].size.width - CropW) / 2;
								CGFloat y = ([[UIScreen mainScreen] bounds].size.height - CropH) / 2;
								imagePicker.cropRect = CGRectMake(x,y,CropW,CropH);
							}
							[RCTPresentedViewController() presentViewController:imagePicker animated:YES completion:nil];
						} else {
							self.successBlock(@[[ImagePickerHelper handleImageData:image quality:quality]]);
						}
					}];
				}];
			}
		}];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if (self.errorBlock) {
		self.errorBlock(nil, nil);
		self.errorBlock = nil;
	}
	
	if ([picker isKindOfClass:[UIImagePickerController class]]) {
		[picker dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
		if (iOS8Later) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
		}
	}
}

- (UIImagePickerController *)imagePickerVc {
	if (_imagePickerVc == nil) {
		_imagePickerVc = [[UIImagePickerController alloc] init];
		_imagePickerVc.delegate = self;
	}
	return _imagePickerVc;
}

@end
