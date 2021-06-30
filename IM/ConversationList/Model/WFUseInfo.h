//
//  WFUseInfo.h
//  Hawa
//
//  Created by 丁永刚 on 2021/1/19.
//  Copyright © 2021 丁永刚. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ userInfoCallbackBlock)(NSDictionary *info);

@interface WFUseInfo : NSObject

@property (copy, nonatomic) NSString * userId;

@property (copy, nonatomic) NSString *nickName;

@property (strong, nonatomic) NSDictionary * userInfo;

@property (nonatomic ,copy) userInfoCallbackBlock callBack;

@end

NS_ASSUME_NONNULL_END
