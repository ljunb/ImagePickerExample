
#import "RNSyanImagePicker.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "NSDictionary+SYSafeConvert.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <React/RCTUtils.h>
#import "ImagePickerManager.h"

@interface RNSyanImagePicker ()
@property (nonatomic, strong) ImagePickerManager *manager;
@end

@implementation RNSyanImagePicker

RCT_EXPORT_MODULE()

- (ImagePickerManager *)manager {
	if (!_manager) {
		_manager = [[ImagePickerManager alloc] init];
	}
	return _manager;
}

RCT_EXPORT_METHOD(showImagePicker:(NSDictionary *)options
                         callback:(RCTResponseSenderBlock)callback) {
	self.manager.cameraOptions = options;
	[self.manager pickAssetsWithStrategy:ImagePickerStrategyPhoto completion:^(NSArray *photos) {
		callback(@[[NSNull null], photos]);
	} failure:^{
		callback(@[@"取消"]);
	}];
}

RCT_REMAP_METHOD(asyncShowImagePicker,
                 options:(NSDictionary *)options
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
	self.manager.cameraOptions = options;
	[self.manager pickAssetsWithStrategy:ImagePickerStrategyPhoto completion:^(NSArray *photos) {
		resolve(photos);
	} failure:^{
		reject(@"", @"取消", nil);
	}];
}

RCT_EXPORT_METHOD(openCamera:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback) {
	self.manager.cameraOptions = options;
	[self.manager pickAssetsWithStrategy:ImagePickerStrategyTakePhoto completion:^(NSArray *photos) {
		callback(@[[NSNull null], photos]);
	} failure:^{
		callback(@[@"取消"]);
	}];
}

RCT_EXPORT_METHOD(deleteCache) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath: [NSString stringWithFormat:@"%@ImageCaches", NSTemporaryDirectory()] error:nil];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
