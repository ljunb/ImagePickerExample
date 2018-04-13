//
//  TakePhotoPicker.h
//  RNSyanImagePicker
//
//  Created by CookieJ on 2018/4/13.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StrategyProtocol.h"

@interface TakePhotoPicker : NSObject <StrategyProtocol, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@end
