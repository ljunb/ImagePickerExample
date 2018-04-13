//
//  ImagePickerManager.m
//  RNSyanImagePicker
//
//  Created by CookieJ on 2018/4/13.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "ImagePickerManager.h"
#import "PhotoPicker.h"
#import "TakePhotoPicker.h"
#import "NSDictionary+SYSafeConvert.h"

@implementation ImagePickerManager

- (instancetype)init {
	if (self = [super init]) {
		_strategyList = @[
											[PhotoPicker new],
											[TakePhotoPicker new]
											];
	}
	return self;
}

- (void)pickAssetsWithStrategy:(ImagePickerStrategy)strategy
										completion:(ManagerPickCompletionBlock)completion
											 failure:(MnagerPickErrorBlock)failure {
	
	id<StrategyProtocol> picker = (id<StrategyProtocol>)self.strategyList[strategy];
	
	[picker pickAssetsWithOptions:self.cameraOptions completion:^(NSArray *photos) {
		completion(photos);
	} failure:^(NSString *errorMessage, NSError *error) {
		failure();
	}];
}


@end
