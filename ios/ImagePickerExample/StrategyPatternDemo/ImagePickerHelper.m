//
//  ImagePickerHelper.m
//  RNSyanImagePicker
//
//  Created by CookieJ on 2018/4/13.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "ImagePickerHelper.h"

@implementation ImagePickerHelper

+ (NSDictionary *)handleImageData:(UIImage *) image quality:(NSInteger)quality {
	NSMutableDictionary *photo = [NSMutableDictionary dictionary];
	NSData *imageData = UIImageJPEGRepresentation(image, quality * 1.0 / 100);
	
	// 剪切图片并放在tmp中
	photo[@"width"] = @(image.size.width);
	photo[@"height"] = @(image.size.height);
	photo[@"size"] = @(imageData.length);
	
	NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString]];
	[self createDir];
	NSString *filePath = [NSString stringWithFormat:@"%@ImageCaches/%@", NSTemporaryDirectory(), fileName];
	if ([imageData writeToFile:filePath atomically:YES]) {
		photo[@"uri"] = filePath;
	} else {
		NSLog(@"保存压缩图片失败%@", filePath);
	}
	
//	if ([nil sy_boolForKey:@"enableBase64"]) {
//		photo[@"base64"] = [NSString stringWithFormat:@"data:image/jpeg;base64,%@", [imageData base64EncodedStringWithOptions:0]];
//	}
	return photo;
}

+ (BOOL)createDir {
	NSString * path = [NSString stringWithFormat:@"%@ImageCaches", NSTemporaryDirectory()];;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir;
	if  (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {//先判断目录是否存在，不存在才创建
		BOOL res=[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
		return res;
	} else return NO;
}

@end
