//
//  WFCtemplateMessageSheet.m
//  Hawa
//
//  Created by 丁永刚 on 2021/3/2.
//  Copyright © 2021 丁永刚. All rights reserved.
//

#import "WFCtemplateMessageSheet.h"

#import "Hawa-Swift.h"

#define k_screenWidth  [UIScreen mainScreen].bounds.size.width
#define k_screenHeight  [UIScreen mainScreen].bounds.size.height

@interface WFCtemplateMessageSheet ()

@property(strong, nonatomic) UIView * container;

@end

@implementation WFCtemplateMessageSheet



- (instancetype)initWithMessages:(NSArray *)messages
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        __weak WFCtemplateMessageSheet* weakSelf = self;
        CGFloat height = 60;
        for (int i = 0; i < messages.count ; i++) {
            NSDictionary *m = messages[i];
            WFCTemplateMessage *message = [[WFCTemplateMessage alloc]initWithMessage:m];
            message.frame = CGRectMake(0, i*height, k_screenWidth, height);
            
            message.tapCallBack = ^(NSDictionary* message) {
                [weakSelf dismiss];
                [weakSelf.delegate messageSheet:weakSelf didSelectMessage:[message[@"id"] intValue] messageContent:message[@"content"]];
            };
            [self.container addSubview:message];
           
        }
        self.container.frame = CGRectMake(0, k_screenHeight, k_screenWidth, (messages.count+1)*height);
        [self addSubview:self.container];
    }
    return self;
}

- (void)showInView:(UIView *)view{

    [view addSubview:self];
    
    [UIView animateWithDuration:0.4 animations:^{
            
            self.container.frame = CGRectMake(0, k_screenHeight-self.container.frame.size.height, self.container.frame.size.width, self.container.frame.size.height);
            
        } completion:^(BOOL finished) {
                
        }];
}

- (void)dismiss{
    [UIView animateWithDuration:0.4 animations:^{
            
            self.container.frame = CGRectMake(0, k_screenHeight, self.container.frame.size.width, self.container.frame.size.height);
            
        } completion:^(BOOL finished) {
                
        }];
}


- (UIView *)container{
    if (_container == nil) {
        _container = [[UIView alloc]initWithFrame:CGRectMake(0, k_screenHeight, k_screenWidth, 0)];
        _container.backgroundColor = UIColor.whiteColor;
    }
    return  _container;
}

@end




@implementation WFCTemplateMessage

- (UILabel *)content{
    if (_content == nil) {
        _content = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, k_screenWidth-40, 40)];
        _content.layer.cornerRadius = 20;
        _content.textAlignment = NSTextAlignmentCenter;
        _content.layer.borderColor = RGBCOLOR(253, 53, 117).CGColor;
        _content.layer.borderWidth = 1;
    }
    return  _content;
}


- (instancetype)initWithMessage:(NSDictionary *)message
{
    self = [super init];
    if (self) {
        self.message = message;
        [self addSubview:self.content];
        self.content.text = message[@"content"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapA:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapA:(UIGestureRecognizer *)gesture{
    self.tapCallBack(_message);
}

@end

