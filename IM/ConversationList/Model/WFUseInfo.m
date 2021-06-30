//
//  WFUseInfo.m
//  Hawa
//
//  Created by 丁永刚 on 2021/1/19.
//  Copyright © 2021 丁永刚. All rights reserved.
//

#import "WFUseInfo.h"
#import "AFNetworking.h"
#import "Hawa-Swift.h"

@implementation WFUseInfo

- (void)setUserId:(NSString *)userId{
    _userId = userId;
    
    
    NSNumber *intId = [NSNumber numberWithInt:[ _userId intValue]];
    __weak WFUseInfo *weakSelf = self;
    [HWHomeModel.shared loadDetail:intId success:^(NSDictionary * _Nonnull respond) {
        weakSelf.userInfo = respond;
    } fail:^(HawaError * _Nonnull error) {
        
    }];
    
}

- (void)setUserInfo:(NSDictionary *)userInfo{
    _userInfo = userInfo;
    if (self.callBack) {
        self.callBack(self.userInfo);
    }
}

@end
