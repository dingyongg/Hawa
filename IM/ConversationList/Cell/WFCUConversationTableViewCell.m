//
//  ConversationTableViewCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUConversationTableViewCell.h"
#import "WFCUUtilities.h"
#import <WFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import "WFCUConfigManager.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"
@implementation WFCUConversationTableViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isBig) {
        _potraitView.frame = CGRectMake(16, 10, 40, 40);
        _targetView.frame = CGRectMake(16 + 40 + 20, 11, [UIScreen mainScreen].bounds.size.width - (16 + 40 + 20 + 100), 16);
        _targetView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:15];
        _digestView.frame = CGRectMake(16 + 40 + 20, 11 + 16 + 8, [UIScreen mainScreen].bounds.size.width - (16 + 40 + 20 + 20), 19);
    }

}
- (void)updateUserInfo:(WFCCUserInfo *)userInfo {
    
    
    [self.potraitView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.userInfo[@"headImg"]] placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
    self.targetView.text = self.userInfo.userInfo[@"nickname"];
    
//
//    NSArray * msgs = [[WFCCIMService sharedWFCIMService] getMessages:self.info.conversation contentTypes:@[@1,@2,@3,@6,@20,@21] from:-1 count:1 withUser:userInfo.userId];
//
//    if (msgs.count>0) {
//
//        WFCCMessage * msg = msgs.firstObject;
//        NSData *extroData = [msg.content.extra dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *extro = @{};
//        if (extroData != nil) {
//            extro = [NSJSONSerialization JSONObjectWithData:extroData options:0 error:nil];
//        }
//
//        [self.potraitView sd_setImageWithURL:[NSURL URLWithString:extro[@"avatar"]] placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
//        self.targetView.text = extro[@"nickname"];
//
//
//    }else{
//        [self.potraitView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage: [UIImage imageNamed:@"PersonalChat"]];
//    }
//
//    if (userInfo.friendAlias.length) {
//        self.targetView.text = userInfo.friendAlias;
//    } else if(userInfo.displayName.length > 0) {
//        self.targetView.text = userInfo.displayName;
//    } else {
//
//    }
}

- (void)setUserInfo:(WFUseInfo *)userInfo{
    _userInfo = userInfo;
    
    if (userInfo.userInfo) {
        [self.potraitView sd_setImageWithURL:[NSURL URLWithString:userInfo.userInfo[@"headImg"]] placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
        self.targetView.text = userInfo.userInfo[@"nickname"];
    }else{
        __weak WFCUConversationTableViewCell * weakSelf = self;
        _userInfo.callBack = ^(NSDictionary * _Nonnull info) {
            [weakSelf.potraitView sd_setImageWithURL:[NSURL URLWithString:info[@"headImg"]] placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
            weakSelf.targetView.text = info[@"nickname"];
            if ([info[@"nickname"] isEqualToString:@"tangfei"]) {
                NSLog(@"111");
            }
        };
    }
}

- (void)setSearchInfo:(WFCCConversationSearchInfo *)searchInfo {
    _searchInfo = searchInfo;
    self.bubbleView.hidden = YES;
    self.timeView.hidden = YES;
    [self update:searchInfo.conversation];
    if (searchInfo.marchedCount > 1) {
        self.digestView.text = [NSString stringWithFormat:@"NumberOfRecords", searchInfo.marchedCount];
    } else {
        NSString *strContent = searchInfo.marchedMessage.digest;
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:strContent];
        NSRange range = [strContent rangeOfString:searchInfo.keyword options:NSCaseInsensitiveSearch];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range];
        self.digestView.attributedText = attrStr;
    }
}

- (void)setInfo:(WFCCConversationInfo *)info {
    _info = info;
    if (info.unreadCount.unread == 0) {
        self.bubbleView.hidden = YES;
    } else {
        self.bubbleView.hidden = NO;
        if (info.isSilent) {
            self.bubbleView.isShowNotificationNumber = NO;
        } else {
            self.bubbleView.isShowNotificationNumber = YES;
        }
        [self.bubbleView setBubbleTipNumber:info.unreadCount.unread];
    }
    
    if (info.isSilent) {
        self.silentView.hidden = NO;
    } else {
        _silentView.hidden = YES;
    }
  
    [self update:info.conversation];
    self.timeView.hidden = NO;
    self.timeView.text = [WFCUUtilities formatTimeLabel:info.timestamp];
    
    BOOL darkMode = NO;
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            darkMode = YES;
        }
    }
    
    if (info.lastMessage && info.lastMessage.direction == MessageDirection_Send) {
        if (info.lastMessage.status == Message_Status_Sending) {
            self.statusView.image = [UIImage imageNamed:@"conversation_message_sending"];
            self.statusView.hidden = NO;
        } else if(info.lastMessage.status == Message_Status_Send_Failure) {
            self.statusView.image = [UIImage imageNamed:@"MessageSendError"];
            self.statusView.hidden = NO;
        } else {
            self.statusView.hidden = YES;
        }
    } else {
        self.statusView.hidden = YES;
    }
    [self updateDigestFrame:!self.statusView.hidden];
}

- (void)updateDigestFrame:(BOOL)isSending {
    if (isSending) {
        _digestView.frame = CGRectMake(16 + 48 + 12 + 18, 40, [UIScreen mainScreen].bounds.size.width - 76 - 16 - 16 - 18, 19);
    } else {
        _digestView.frame = CGRectMake(16 + 48 + 12, 40, [UIScreen mainScreen].bounds.size.width - 76 - 16 - 16, 19);
    }
}
- (void)update:(WFCCConversation *)conversation {
    self.targetView.textColor = [WFCUConfigManager globalManager].textColor;
    if(conversation.type == Single_Type) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:conversation.target refresh:NO];
        if(userInfo.userId.length == 0) {
            userInfo = [[WFCCUserInfo alloc] init];
            userInfo.userId = conversation.target;
        }
        [self updateUserInfo:userInfo];
    } else if (conversation.type == Group_Type) {
        
    } else if(conversation.type == Channel_Type) {
      
    } else {
        self.targetView.text = @"Chatroom";
    }
    
    self.potraitView.layer.cornerRadius = 24.f;
    self.digestView.attributedText = nil;
    if (_info.draft.length) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"[Draft]" attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
        
        NSError *__error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[_info.draft dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options:kNilOptions
                                                                     error:&__error];
        
        BOOL hasMentionInfo = NO;
        NSString *text = _info.draft;
        if (!__error) {
            if ([dictionary[@"mentions"] isKindOfClass:[NSArray class]] || [dictionary[@"quote"] isKindOfClass:[NSDictionary class]]) {
                hasMentionInfo = YES;
                text = dictionary[@"text"];
            }
        }
        
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:text]];

        if (_info.conversation.type == Group_Type && _info.unreadCount.unreadMentionAll + _info.unreadCount.unreadMention > 0) {
            NSMutableAttributedString *tmp = [[NSMutableAttributedString alloc] initWithString:@"[MentionYou]" attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
            [tmp appendAttributedString:attString];
            attString = tmp;
        }
        self.digestView.attributedText = attString;
    } else if (_info.lastMessage.direction == MessageDirection_Receive && (_info.conversation.type == Group_Type || _info.conversation.type == Channel_Type)) {
        NSString *groupId = nil;
        if (_info.conversation.type == Group_Type) {
            groupId = _info.conversation.target;
        }
        WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:_info.lastMessage.fromUser inGroup:groupId refresh:NO];
        if (sender.friendAlias.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.digestView.text = [NSString stringWithFormat:@"%@:%@", sender.friendAlias, _info.lastMessage.digest];
        } else if (sender.groupAlias.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.digestView.text = [NSString stringWithFormat:@"%@:%@", sender.groupAlias, _info.lastMessage.digest];
        } else if (sender.displayName.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.digestView.text = [NSString stringWithFormat:@"%@:%@", sender.displayName, _info.lastMessage.digest];
        } else {
            self.digestView.text = _info.lastMessage.digest;
        }
        
        if (_info.conversation.type == Group_Type && _info.unreadCount.unreadMentionAll + _info.unreadCount.unreadMention > 0) {
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"[MentionYou]" attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
            if (self.digestView.text.length) {
                [attString appendAttributedString:[[NSAttributedString alloc] initWithString:self.digestView.text]];
            }
            
            self.digestView.attributedText = attString;
        }
    } else {
        self.digestView.text = _info.lastMessage.digest;
    }
}

- (UIImageView *)potraitView {
    if (!_potraitView) {
        _potraitView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, 48, 48)];
        _potraitView.clipsToBounds = YES;
        _potraitView.layer.cornerRadius = 24.f;
        [self.contentView addSubview:_potraitView];
    }
    return _potraitView;
}

- (UIImageView *)statusView {
    if (!_statusView) {
        _statusView = [[UIImageView alloc] initWithFrame:CGRectMake(16 + 48 + 12, 42, 16, 16)];
        _statusView.image = [UIImage imageNamed:@"conversation_message_sending"];
        [self.contentView addSubview:_statusView];
    }
    return _statusView;
}

- (UILabel *)targetView {
    if (!_targetView) {
        _targetView = [[UILabel alloc] initWithFrame:CGRectMake(16 + 48 + 12, 16, [UIScreen mainScreen].bounds.size.width - 76  - 68, 20)];
        _targetView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:17];
        _targetView.textColor = [WFCUConfigManager globalManager].textColor;
        [self.contentView addSubview:_targetView];
    }
    return _targetView;
}

- (UILabel *)digestView {
    if (!_digestView) {
        _digestView = [[UILabel alloc] initWithFrame:CGRectMake(16 + 48 + 12, 42, [UIScreen mainScreen].bounds.size.width - 76  - 16 - 16, 19)];
        _digestView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        _digestView.lineBreakMode = NSLineBreakByTruncatingTail;
        _digestView.textColor = [UIColor colorWithHexString:@"b3b3b3"];
        [self.contentView addSubview:_digestView];
    }
    return _digestView;
}

- (UIImageView *)silentView {
    if (!_silentView) {
        _silentView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 12  - 20, 45, 12, 12)];
        _silentView.image = [UIImage imageNamed:@"conversation_mute"];
        [self.contentView addSubview:_silentView];
    }
    return _silentView;
}

- (UILabel *)timeView {
    if (!_timeView) {
        _timeView = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 52  - 16, 20, 52, 12)];
        _timeView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        _timeView.textAlignment = NSTextAlignmentRight;
        _timeView.textColor = [UIColor colorWithHexString:@"b3b3b3"];
        [self.contentView addSubview:_timeView];
    }

    return _timeView;
}

- (BubbleTipView *)bubbleView {
    if (!_bubbleView) {
        if(self.potraitView) {
            _bubbleView = [[BubbleTipView alloc] initWithSuperView:self.contentView];
            _bubbleView.hidden = YES;
        }
    }
    return _bubbleView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
