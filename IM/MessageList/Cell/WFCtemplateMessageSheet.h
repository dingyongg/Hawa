//
//  WFCtemplateMessageSheet.h
//  Hawa
//
//  Created by 丁永刚 on 2021/3/2.
//  Copyright © 2021 丁永刚. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WFCtemplateMessageSheet;
NS_ASSUME_NONNULL_BEGIN

@protocol WFCtemplateMessageSheetDelegate

- (void)messageSheet:(WFCtemplateMessageSheet *)sheet didSelectMessage:(int)messageID messageContent:(NSString *)content;

@end

@interface WFCtemplateMessageSheet : UIView

@property(weak, nonatomic) id<WFCtemplateMessageSheetDelegate> delegate;

- (instancetype)initWithMessages:(NSArray *)messages;
- (void)showInView:(UIView *)view;

@end


typedef void (^tapCallBackBlock)(NSDictionary* message);

@interface WFCTemplateMessage : UIView

- (instancetype)initWithMessage:(NSDictionary *)message;

@property(strong, nonatomic)UILabel *content;

@property(nonatomic, copy) tapCallBackBlock tapCallBack;

@property(strong, nonatomic) NSDictionary* message;

@end

NS_ASSUME_NONNULL_END



