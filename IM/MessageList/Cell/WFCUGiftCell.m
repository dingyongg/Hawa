//
//  WFCUGiftCell.m
//  Hawa
//
//  Created by 丁永刚 on 2021/1/22.
//  Copyright © 2021 丁永刚. All rights reserved.
//

#import "WFCUGiftCell.h"
#import <WFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>

@implementation WFCUGiftCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    return CGSizeMake(width*3/5, 80);
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCGiftMessageContent *giftContent = (WFCCGiftMessageContent *)model.message.content;
    
    NSData *exData = [giftContent.extra dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *exDic = [NSJSONSerialization JSONObjectWithData:exData options:NSJSONReadingMutableContainers error:nil];
    
    
    [self.giftIV sd_setImageWithURL:[NSURL URLWithString:exDic[@"imageUrl"]]];
    self.priceL.text = [[NSString alloc]initWithFormat:@"%d", [exDic[@"number"] intValue]];
    if (model.message.direction == MessageDirection_Receive) {
        _giftIV.frame = CGRectMake(self.bubbleView.frame.size.width-75 , 5, 70, 70);
        _priceL.frame = CGRectMake(38, 60, self.bubbleView.frame.size.width-35, 20);
        _priceL.textAlignment = NSTextAlignmentLeft;
        self.diamondIC.frame =  CGRectMake(13, 60, 20, 20);
    }else{
        _giftIV.frame = CGRectMake(3, 5, 70, 70);
        _priceL.textAlignment = NSTextAlignmentRight;
        _priceL.frame = CGRectMake(0, 60, self.bubbleView.frame.size.width-35, 20);
        self.diamondIC.frame =  CGRectMake(self.bubbleView.frame.size.width-30, 60, 20, 20);
    }

}


- (UIImageView *)giftIV{
    
    if (_giftIV == nil) {
        _giftIV = [[UIImageView alloc]initWithFrame:CGRectMake(3, 10, 70, 70)];
        _giftIV.contentMode = UIViewContentModeScaleAspectFit;
        [self.bubbleView addSubview: _giftIV];
    }
    
    return _giftIV;
}

- (UILabel *)priceL{
    if (_priceL == nil) {
        _priceL = [[UILabel alloc]init];
        _priceL.textColor = [UIColor blackColor];
        _priceL.font = [UIFont systemFontOfSize:16];
        _priceL.textAlignment = NSTextAlignmentRight;
        [self.bubbleView addSubview:_priceL];
    }
    return _priceL;
}

- (UIImageView *)diamondIC{
    
    if (_diamondIC == nil) {
        _diamondIC = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_task_diamond"]];
        _diamondIC.contentMode = UIViewContentModeScaleAspectFit;
        [self.bubbleView addSubview:_diamondIC];
    }
    
    return _diamondIC;
}



@end
