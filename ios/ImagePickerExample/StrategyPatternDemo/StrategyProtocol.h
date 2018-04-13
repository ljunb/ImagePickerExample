//
//  StrategyProtocol.h
//  RNSyanImagePicker
//
//  Created by CookieJ on 2018/4/13.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <React/RCTUtils.h>

/**
 策略的抽象协议，每个策略将声明该协议，并实现具体的协议方法：具体的资源选择逻辑（选择图片、拍照或是选择视频，等等）
 */
@protocol StrategyProtocol <NSObject>

typedef void(^PickSuccessBlock)(NSArray *photos);
typedef void(^PickErrorBlock)(NSString *errorMessage, NSError *error);

- (void)pickAssetsWithOptions:(NSDictionary *)options
									 completion:(PickSuccessBlock)completion
											failure:(PickErrorBlock)failure;

@end
