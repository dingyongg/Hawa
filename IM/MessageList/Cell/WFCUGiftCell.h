//
//  WFCUGiftCell.h
//  Hawa
//
//  Created by 丁永刚 on 2021/1/22.
//  Copyright © 2021 丁永刚. All rights reserved.
//

#import "WFCUMessageCell.h"


NS_ASSUME_NONNULL_BEGIN

@interface WFCUGiftCell : WFCUMessageCell

@property (nonatomic, strong) UIImageView *giftIV;

@property (nonatomic, assign) int price;

@property (nonatomic, strong) UIImageView *diamondIC;

@property (nonatomic, strong) UILabel *priceL;

@end

NS_ASSUME_NONNULL_END
