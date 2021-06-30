//
//  InformationCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUAVCallCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUUtilities.h"


#define TEXT_TOP_PADDING 6
#define TEXT_BUTTOM_PADDING 6
#define TEXT_LEFT_PADDING 8
#define TEXT_RIGHT_PADDING 8


#define TEXT_LABEL_TOP_PADDING TEXT_TOP_PADDING + 4
#define TEXT_LABEL_BUTTOM_PADDING TEXT_BUTTOM_PADDING + 4
#define TEXT_LABEL_LEFT_PADDING 30
#define TEXT_LABEL_RIGHT_PADDING 30

#if WFCU_SUPPORT_VOIP
#import <WFAVEngineKit/WFAVEngineKit.h>
#endif
@implementation WFCUAVCallCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    NSString *text = [WFCUAVCallCell getCallText:msgModel.message.content];
    CGSize textSize = [WFCUUtilities getTextDrawingSize:text font:[UIFont systemFontOfSize:18] constrainedSize:CGSizeMake(width, 8000)];
    return CGSizeMake(textSize.width + 25, 30);
}

+ (NSString *)getCallText:(WFCCVideoCallMessageContent *)content {
    NSString *text;
    
    NSData *data =  [content.extra dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *extroData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    int msgType = [extroData[@"msgType"] intValue];
    
    if (msgType < 60) {
        
        switch (msgType) {
            case 50:
                text = @"AudioCall";
                break;
            case 51:
                text = @"AudioAccepted";
                break;
            case 52:
                text = @"AudioHangUp";
                break;
            case 53:
                text = @"AudioCall";
                break;
            case 54:
                text = @"AudioRefused";
                break;
            case 55:
                text = @"AudioLineBussy";
                break;
            default:
                break;
        }
        
        
        
    } else {
        
        switch (msgType) {
            case 60:
                text = @"VideoCall";
                break;
            case 61:
                text = @"VideoAccepted";
                break;
            case 62:
                text = @"VideoHangUp";
                break;
            case 63:
                text = @"VideoCall";
                break;
            case 64:
                text = @"VideoRefused";
                break;
            case 65:
                text = @"VideoLineBussy";
                break;
            default:
                break;
        }
        
        
    }
    return text;
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    CGFloat width = self.contentArea.bounds.size.width;
    
    self.infoLabel.text = [WFCUAVCallCell getCallText:model.message.content];
    self.infoLabel.layoutMargins = UIEdgeInsetsMake(TEXT_TOP_PADDING, TEXT_LEFT_PADDING, TEXT_BUTTOM_PADDING, TEXT_RIGHT_PADDING);
    
    CGSize textSize = [WFCUUtilities getTextDrawingSize:self.infoLabel.text font:[UIFont systemFontOfSize:18] constrainedSize:CGSizeMake(width, 8000)];
    
    if (model.message.direction == MessageDirection_Send) {
        self.infoLabel.frame = CGRectMake(0, 0, width - 25, 30);
        self.modeImageView.frame = CGRectMake(width - 25, 3, 25, 25);
    } else {
        self.infoLabel.frame = CGRectMake(0, 0, width-25, 30);
        self.modeImageView.frame = CGRectMake(width-25, 3, 25, 25);
    }
    if ([self.model.message.content isKindOfClass:[WFCCVideoCallMessageContent class]]) {

        NSData *data =  [self.model.message.content.extra dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *extroData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        int msgType = [extroData[@"msgType"] intValue];
        
        if (msgType < 60) {
            self.modeImageView.image = [UIImage imageNamed:@"msg_audio_call"];
        } else {
            self.modeImageView.image = [UIImage imageNamed:@"msg_video_call"];
        }
    }
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.numberOfLines = 0;
        _infoLabel.font = [UIFont systemFontOfSize:14];
        
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.numberOfLines = 0;
        _infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = [UIFont systemFontOfSize:14.f];
        _infoLabel.layer.masksToBounds = YES;
        _infoLabel.layer.cornerRadius = 5.f;
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.textColor = [UIColor blackColor];
        _infoLabel.userInteractionEnabled = YES;
        
        [self.contentArea addSubview:_infoLabel];
    }
    return _infoLabel; 
}
- (UIImageView *)modeImageView {
    if (!_modeImageView) {
        _modeImageView = [[UIImageView alloc] init];
        [self.contentArea addSubview:_modeImageView];
    }
    return _modeImageView;
}
@end
