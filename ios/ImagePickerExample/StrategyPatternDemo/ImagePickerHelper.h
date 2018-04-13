//
//  ImagePickerHelper.h
//  RNSyanImagePicker
//
//  Created by CookieJ on 2018/4/13.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImagePickerHelper : NSObject

+ (NSDictionary *)handleImageData:(UIImage *) image quality:(NSInteger)quality;

@end
