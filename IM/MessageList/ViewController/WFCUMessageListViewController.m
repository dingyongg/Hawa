//
//  MessageListViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/31.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUMessageListViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WFCUImagePreviewViewController.h"

#import "WFCUImageCell.h"
#import "WFCUTextCell.h"
#import "WFCUVoiceCell.h"
#import "WFCULocationCell.h"
#import "WFCUFileCell.h"
#import "WFCUInformationCell.h"
#import "WFCUCallSummaryCell.h"
#import "WFCUStickerCell.h"
#import "WFCUVideoCell.h"
#import "WFCURecallCell.h"
#import "WFCUConferenceInviteCell.h"
#import "WFCUCardCell.h"
#import "WFCUCompositeCell.h"
#import "WFCULinkCell.h"
#import "WFCUGiftCell.h"
#import "WFCUAVCallCell.h"
#import "WFCUBrowserViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUChatInputBar.h"

#import "UIView+Toast.h"

#import "SDPhotoBrowser.h"
#import "WFCULocationViewController.h"
#import "WFCULocationPoint.h"

#import "WFCUBrowserViewController.h"

#import "MBProgressHUD.h"
#import "WFCUMediaMessageDownloader.h"

#import "VideoPlayerKit.h"

#import <WFChatClient/WFCChatClient.h>
#if WFCU_SUPPORT_VOIP
#import <WFAVEngineKit/WFAVEngineKit.h>
#endif

#import "WFCUConfigManager.h"

#import "WFCUReceiptViewController.h"

#import "UIColor+YH.h"
#import "WFCUConversationTableViewController.h"

#import "WFCUMediaMessageGridViewController.h"

#import "WFCUQuoteViewController.h"
#import "WFCUCompositeMessageViewController.h"
#import "Hawa-Swift.h"
#import "WFCUFavoriteItem.h"
#import "WFCtemplateMessageSheet.h"

@interface WFCUMessageListViewController () <UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, WFCUMessageCellDelegate, AVAudioPlayerDelegate, WFCUChatInputBarDelegate, SDPhotoBrowserDelegate, UIGestureRecognizerDelegate,WFCtemplateMessageSheetDelegate >

@property (nonatomic, strong)NSMutableArray<WFCUMessageModel *> *modelList;

@property (nonatomic, strong)NSMutableArray<WFCCMessage *> *mentionedMsgs;

@property (nonatomic, strong)NSMutableDictionary<NSNumber *, Class> *cellContentDict;

@property(nonatomic) AVAudioPlayer *player;
@property(nonatomic) NSTimer *playTimer;

@property(nonatomic, assign)long playingMessageId;
@property(nonatomic, assign)BOOL loadingMore;
@property(nonatomic, assign)BOOL hasMoreOld;

@property(nonatomic, strong)WFCCUserInfo *targetUser;
@property(nonatomic, strong)WFCCGroupInfo *targetGroup;
@property(nonatomic, strong)WFCCChannelInfo *targetChannel;
@property(nonatomic, strong)WFCCChatroomInfo *targetChatroom;

@property(nonatomic, strong)WFCUChatInputBar *chatInputBar;
@property(nonatomic, strong)VideoPlayerKit *videoPlayerViewController;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic)NSArray<WFCCMessage *> *imageMsgs;

@property (strong, nonatomic)NSString *orignalDraft;

@property (nonatomic, strong)id<UIGestureRecognizerDelegate> scrollBackDelegate;

@property (nonatomic, strong)UIView *backgroundView;

@property (nonatomic, assign)BOOL showAlias;

@property (nonatomic, strong)WFCUMessageCellBase *cell4Menu;
@property (nonatomic, assign)BOOL firstAppear;

@property (nonatomic, assign)BOOL hasNewMessage;
@property (nonatomic, assign)BOOL loadingNew;

@property (nonatomic, strong)UICollectionReusableView *headerView;
@property (nonatomic, strong)UICollectionReusableView *footerView;
@property (nonatomic, strong)UIActivityIndicatorView *headerActivityView;
@property (nonatomic, strong)UIActivityIndicatorView *footerActivityView;

@property (nonatomic, strong)NSTimer *showTypingTimer;

@property (nonatomic, assign)BOOL isShowingKeyboard;

@property (nonatomic, strong)NSMutableDictionary<NSString *, NSNumber *> *deliveryDict;
@property (nonatomic, strong)NSMutableDictionary<NSString *, NSNumber *> *readDict;
@property (nonatomic, strong)NSMutableSet<NSNumber *> *nMsgSet;

@property (nonatomic, strong)UIView *multiSelectPanel;

@property (nonatomic, assign)long firstUnreadMessageId;
@property (nonatomic, assign)int unreadMessageCount;

@property (nonatomic, strong)UIButton *unreadButton;
@property (nonatomic, strong)UIButton *mentionedButton;
@property (nonatomic, strong)UIButton *newMsgTipButton;
@property (nonatomic, assign) int canSendMsg; //0 剩余钻石不足 1成功

@end

@implementation WFCUMessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    [UserCenter.shared messageTemplateWithSeeId:self.conversation.target.intValue success:^(NSArray * _Nonnull respond) {
        if (respond.count) {
            [self showTemplateMessage:respond];
        }
    } fail:^(HawaError * _Nonnull error) {
        
    }];

    
    
    [self removeControllerStackIfNeed];
    
    self.cellContentDict = [[NSMutableDictionary alloc] init];
    
    [self initializedSubViews];
    self.firstAppear = YES;
    self.hasMoreOld = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onResetKeyboard:)];
    [self.collectionView addGestureRecognizer:tap];
    
    [self reloadMessageList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessages:) name:kReceiveMessages object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecallMessages:) name:kRecallMessages object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeleteMessages:) name:kDeleteMessages object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageDelivered:) name:kMessageDelivered object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageReaded:) name:kMessageReaded object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendingMessage:) name:kSendingMessageStatusUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageListChanged:) name:kMessageListChanged object:self.conversation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMenuHidden:) name:UIMenuControllerDidHideMenuNotification object:nil];

#if WFCU_SUPPORT_VOIP
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallStateChanged:) name:kCallStateUpdated object:nil];
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSettingUpdated:) name:kSettingUpdated object:nil];
    
    __weak typeof(self) ws = self;
    if(self.conversation.type == Single_Type) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kUserInfoUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([ws.conversation.target isEqualToString:note.object]) {
                ws.targetUser = note.userInfo[@"userInfo"];
            }
        }];
    } else if(self.conversation.type == Group_Type) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kGroupInfoUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([ws.conversation.target isEqualToString:note.object]) {
                ws.targetGroup = note.userInfo[@"groupInfo"];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kGroupMemberUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([ws.conversation.target isEqualToString:note.object]) {
                ws.targetGroup = ws.targetGroup;
            }
            
        }];
    } else if(self.conversation.type == Channel_Type) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kChannelInfoUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([ws.conversation.target isEqualToString:note.object]) {
                ws.targetChannel = note.userInfo[@"channelInfo"];
            }
        }];
    }
    
    [self setupNavigationItem];
    
    self.chatInputBar = [[WFCUChatInputBar alloc] initWithSuperView:self.backgroundView conversation:self.conversation delegate:self];
    
    self.orignalDraft = [[WFCCIMService sharedWFCIMService] getConversationInfo:self.conversation].draft;
    
    if (self.conversation.type == Chatroom_Type) {
        __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
        hud.label.text = WFCString(@"JoinChatroom");
        [hud showAnimated:YES];
        
        [[WFCCIMService sharedWFCIMService] joinChatroom:ws.conversation.target success:^{
            NSLog(@"join chatroom successs");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws sendChatroomWelcomeMessage];
            });
            [hud hideAnimated:YES];
        } error:^(int error_code) {
            NSLog(@"join chatroom error");
            hud.mode = MBProgressHUDModeText;
            hud.label.text = WFCString(@"JoinChatroomFailure");
            //            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
            hud.completionBlock = ^{
                [ws.navigationController popViewControllerAnimated:YES];
            };
        }];
    }
    
    WFCCConversationInfo *info = [[WFCCIMService sharedWFCIMService] getConversationInfo:self.conversation];
    self.chatInputBar.draft = info.draft;
    
    if (self.conversation.type == Group_Type) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray<WFCCGroupMember *> *groupMembers = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.conversation.target forceUpdate:NO];
            NSMutableArray *memberIds = [[NSMutableArray alloc] init];
            for (WFCCGroupMember *member in groupMembers) {
                [memberIds addObject:member.memberId];
            }
            [[WFCCIMService sharedWFCIMService] getUserInfos:memberIds inGroup:self.conversation.target];
        });
    }
    
    if (self.multiSelecting) {
        self.multiSelectPanel.hidden = NO;
    }
    
    self.nMsgSet = [[NSMutableSet alloc] init];
}


//The VC maybe pushed from search VC, so no need go back to search VC, need remove all the VC between current VC to WFCUConversationTableViewController
- (void)removeControllerStackIfNeed {
    //highlightMessageId will be positive if the VC pushed from search VC
    if (self.highlightMessageId > 0) {
        if (self.navigationController.viewControllers.count < 3) {
            return;
        }
        NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
        BOOL foundParent = NO;
        NSMutableArray *tobeDeleteVCs = [[NSMutableArray alloc] init];
        for (int i = (int)controllers.count - 2; i >=0; i--) {
            UIViewController *controller = controllers[i];
            if ([controller isKindOfClass:[WFCUConversationTableViewController class]]) {
                foundParent = YES;
                break;
            } else {
                [tobeDeleteVCs addObject:controller];
            }
        }
        
        if (foundParent) {
            [controllers removeObjectsInArray:tobeDeleteVCs];
            self.navigationController.viewControllers = [controllers copy];
        }
    }
}

- (void)setupNavigationItem {
    if (self.multiSelecting) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStyleDone target:self action:@selector(onSearchBarBtn:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(onMultiSelectCancel:)];
    } else {
        if(self.conversation.type == Single_Type) {
            UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.frame = CGRectZero;
            [backBtn setImage:[UIImage imageNamed:@"ic_black_arrow_left"] forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(onLeftBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *backBarItem  = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
            NSLayoutConstraint * currWidth = [backBarItem.customView.widthAnchor constraintEqualToConstant:20];
            currWidth.active = YES;
            NSLayoutConstraint * currHeight =  [backBarItem.customView.heightAnchor constraintEqualToConstant:20];
            currHeight.active = true;
            self.navigationItem.leftBarButtonItem = backBarItem;
            [self.navigationController.navigationBar setTintColor: UIColor.blackColor];
        }
    }
}

- (void)onMultiSelectCancel:(id)sender {
    self.multiSelecting = !self.multiSelecting;
}

- (void)setLoadingMore:(BOOL)loadingMore {
    _loadingMore = loadingMore;
    if (_loadingMore) {
        [self.headerActivityView startAnimating];
    } else {
        [self.headerActivityView stopAnimating];
    }
}

- (UIActivityIndicatorView *)headerActivityView {
    if (!_headerActivityView) {
        _headerActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _headerActivityView;
}

- (UIActivityIndicatorView *)footerActivityView {
    if (!_footerActivityView) {
        _footerActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _footerActivityView;
}

- (void)setLoadingNew:(BOOL)loadingNew {
    _loadingNew = loadingNew;
    if (loadingNew) {
        [self.footerActivityView startAnimating];
    } else {
        [self.footerActivityView stopAnimating];
    }
}

- (void)setHasNewMessage:(BOOL)hasNewMessage {
    _hasNewMessage = hasNewMessage;
    UICollectionViewFlowLayout *_customFlowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    if (hasNewMessage) {
        _customFlowLayout.footerReferenceSize = CGSizeMake(320.0f, 20.0f);
    } else {
        _customFlowLayout.footerReferenceSize = CGSizeZero;
    }
}

- (void)loadMoreMessage:(BOOL)isHistory completion:(void (^ __nullable)(BOOL more))completion {
    __weak typeof(self) weakSelf = self;
    if (isHistory) {
        if (self.loadingMore) {
            return;
        }
        self.loadingMore = YES;
        long lastIndex = 0;
        if (weakSelf.modelList.count) {
            lastIndex = [weakSelf.modelList firstObject].message.messageId;
        }
        
        dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
            NSArray *messageList = [[WFCCIMService sharedWFCIMService] getMessages:weakSelf.conversation contentTypes:nil from:lastIndex count:10 withUser:self.privateChatUser];
            if (!messageList.count) {
                long long lastUid = self.modelList.lastObject.message.messageUid;
                for (WFCUMessageModel *model in self.modelList) {
                    if (model.message.messageUid > 0 && model.message.messageUid < lastUid) {
                        lastUid = model.message.messageUid;
                    }
                }
                [[WFCCIMService sharedWFCIMService] getRemoteMessages:weakSelf.conversation before:lastUid count:10 success:^(NSArray<WFCCMessage *> *messages) {
                    NSMutableArray *reversedMsgs = [[NSMutableArray alloc] init];
                    for (WFCCMessage *msg in messages) {
                        [reversedMsgs insertObject:msg atIndex:0];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!reversedMsgs.count) {
                            weakSelf.hasMoreOld = NO;
                        } else {
                            [weakSelf appendMessages:reversedMsgs newMessage:NO highlightId:0 forceButtom:NO];
                        }
                        weakSelf.loadingMore = NO;
                        if (completion) {
                            completion(messages.count > 0);
                        }
                    });
                } error:^(int error_code) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.hasMoreOld = NO;
                        weakSelf.loadingMore = NO;
                    });
                }];
            } else {
                [NSThread sleepForTimeInterval:0.5];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf appendMessages:messageList newMessage:NO highlightId:0 forceButtom:NO];
                    weakSelf.loadingMore = NO;
                    if (completion) {
                        completion(messageList.count > 0);
                    }
                });
            }
        });
    } else {
        if (weakSelf.loadingNew || !weakSelf.hasNewMessage) {
            return;
        }
        weakSelf.loadingNew = YES;
        
        long lastIndex = 0;
        if (self.modelList.count) {
            lastIndex = [self.modelList lastObject].message.messageId;
        }
        
        dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
            NSArray *messageList = [[WFCCIMService sharedWFCIMService] getMessages:self.conversation contentTypes:nil from:lastIndex count:-10 withUser:self.privateChatUser];
            if (!messageList.count || messageList.count < 10) {
                self.hasNewMessage = NO;
            }
            NSMutableArray *mutableMessages = [messageList mutableCopy];
            for (int i = 0; i < mutableMessages.count/2; i++) {
                int j = (int)mutableMessages.count - 1 - i;
                WFCCMessage *msg = [mutableMessages objectAtIndex:i];
                [mutableMessages insertObject:[mutableMessages objectAtIndex:j] atIndex:i];
                [mutableMessages removeObjectAtIndex:i+1];
                [mutableMessages insertObject:msg atIndex:j];
                [mutableMessages removeObjectAtIndex:j+1];
            }
            [NSThread sleepForTimeInterval:0.5];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf appendMessages:mutableMessages newMessage:YES highlightId:0 forceButtom:NO];
                weakSelf.loadingNew = NO;
                if (completion) {
                    completion(messageList.count > 0);
                }
            });
        });
    }
}
- (void)sendChatroomWelcomeMessage {
    WFCCTipNotificationContent *tip = [[WFCCTipNotificationContent alloc] init];
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:NO];
    tip.tip = [NSString stringWithFormat:WFCString(@"WelcomeJoinChatroomHint"), userInfo.displayName];
    [self sendMessage:tip];
}

- (void)sendChatroomLeaveMessage {
    __block WFCCConversation *strongConv = self.conversation;
    dispatch_async(dispatch_get_main_queue(), ^{
        WFCCTipNotificationContent *tip = [[WFCCTipNotificationContent alloc] init];
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:NO];
        tip.tip = [NSString stringWithFormat:WFCString(@"LeaveChatroomHint"), userInfo.displayName];
        
        [[WFCCIMService sharedWFCIMService] send:strongConv content:tip success:^(long long messageUid, long long timestamp) {
            [[WFCCIMService sharedWFCIMService] quitChatroom:strongConv.target success:nil error:nil];
        } error:^(int error_code) {
            
        }];
    });
}

- (void)onLeftBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    [super didMoveToParentViewController:parent];
    if(!parent){
        [self leftMessageVC];
    }
}

- (void)leftMessageVC {
    if (self.conversation.type == Chatroom_Type) {
        [self sendChatroomLeaveMessage];
    }
}


- (void)onSearchBarBtn:(id)sender {
    if (self.multiSelecting) {
        for (WFCUMessageModel *model in self.modelList) {
            if (model.selected && ![self.selectedMessageIds containsObject:@(model.message.messageId)]) {
                [self.selectedMessageIds addObject:@(model.message.messageId)];
            }
        }
    }
}

- (void)setTargetUser:(WFCCUserInfo *)targetUser {
    _targetUser = targetUser;
}



- (void)setShowAlias:(BOOL)showAlias {
    _showAlias = showAlias;
    if (self.modelList) {
        for (WFCUMessageModel *model in self.modelList) {
            if (showAlias && model.message.direction == MessageDirection_Receive) {
                model.showNameLabel = YES;
            } else {
                model.showNameLabel = NO;
            }
        }
    }
}

- (void)setMultiSelecting:(BOOL)multiSelecting {
    _multiSelecting = multiSelecting;
    if (multiSelecting) {
        for (WFCUMessageModel *model in self.modelList) {
            model.selecting = YES;
            model.selected = NO;
        }
        
        if (!self.selectedMessageIds) {
            self.selectedMessageIds = [[NSMutableArray alloc] init];
        }
        
        self.multiSelectPanel.hidden = NO;
    } else {
        for (WFCUMessageModel *model in self.modelList) {
            model.selecting = NO;
            model.selected = NO;
        }
        self.selectedMessageIds = nil;
        self.multiSelectPanel.hidden = YES;
    }
    
    [self setupNavigationItem];
    [self.collectionView reloadData];
}


- (void)onDeleteMultiSelectedMessage:(id)sender {
    NSMutableArray *deletedModels = [[NSMutableArray alloc] init];
    for (WFCUMessageModel *model in self.modelList) {
        if (model.selected) {
            [[WFCCIMService sharedWFCIMService] deleteMessage:model.message.messageId];
            [deletedModels addObject:model];
            [self.selectedMessageIds removeObject:@(model.message.messageId)];
        }
    }
    [self.modelList removeObjectsInArray:deletedModels];
    
    //有可能是经过多次搜索，选中了当前model列表中没有包含的
    for (NSNumber *IDS in self.selectedMessageIds) {
        [[WFCCIMService sharedWFCIMService] deleteMessage:[IDS longValue]];
    }
    
    self.multiSelecting = NO;
}

- (void)onForwardMultiSelectedMessage:(id)sender {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (WFCUMessageModel *model in self.modelList) {
        if (model.selected) {
            [messages addObject:model.message];
        }
    }
    
    [self.selectedMessageIds removeAllObjects];
    self.multiSelecting = NO;
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:WFCString(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)scrollToBottom:(BOOL)animated {
    
    NSUInteger rowCount = [self.collectionView numberOfItemsInSection:0];
    if (rowCount == 0) {
        return;
    }
    NSUInteger finalRow = rowCount - 1;
    
    for (int i = 0; i < self.modelList.count; i++) {
        if ([self.modelList objectAtIndex:i].highlighted) {
            finalRow = i;
            break;
        }
    }
    
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.collectionView scrollToItemAtIndexPath:finalIndexPath
                                atScrollPosition:UICollectionViewScrollPositionBottom
                                        animated:animated];
    
    [self dismissNewMsgTip];
}

- (void)initializedSubViews {
    UICollectionViewFlowLayout *_customFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _customFlowLayout.minimumLineSpacing = 0.0f;
    _customFlowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    _customFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _customFlowLayout.headerReferenceSize = CGSizeMake(320.0f, 20.0f);
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        insets = self.view.safeAreaInsets;
    }
    CGRect frame = self.view.bounds;
    frame.origin.y += kStatusBarAndNavigationBarHeight;
    frame.size.height -= (kTabbarSafeBottomMargin + kStatusBarAndNavigationBarHeight);
    self.backgroundView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:self.backgroundView];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.backgroundView.bounds.size.width, self.backgroundView.bounds.size.height - CHAT_INPUT_BAR_HEIGHT) collectionViewLayout:_customFlowLayout];
    
    [self.backgroundView addSubview:self.collectionView];
    
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.alwaysBounceVertical = YES;
    
    
    self.view.backgroundColor = self.collectionView.backgroundColor;
    
    [self registerCell:[WFCUTextCell class] forContent:[WFCCTextMessageContent class]];
    [self registerCell:[WFCUTextCell class] forContent:[WFCCPTextMessageContent class]];
    [self registerCell:[WFCUImageCell class] forContent:[WFCCImageMessageContent class]];
    [self registerCell:[WFCUVoiceCell class] forContent:[WFCCSoundMessageContent class]];
    [self registerCell:[WFCUVideoCell class] forContent:[WFCCVideoMessageContent class]];
    [self registerCell:[WFCULocationCell class] forContent:[WFCCLocationMessageContent class]];
    [self registerCell:[WFCUFileCell class] forContent:[WFCCFileMessageContent class]];
    [self registerCell:[WFCUStickerCell class] forContent:[WFCCStickerMessageContent class]];
    
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCCreateGroupNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCAddGroupeMemberNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCKickoffGroupMemberNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCQuitGroupNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCDismissGroupNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCTransferGroupOwnerNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCModifyGroupAliasNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCChangeGroupNameNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCChangeGroupPortraitNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCFriendAddedMessageContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCFriendGreetingMessageContent class]];
    
    [self registerCell:[WFCUCallSummaryCell class] forContent:[WFCCCallStartMessageContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCTipNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCUnknownMessageContent class]];
    [self registerCell:[WFCURecallCell class] forContent:[WFCCRecallMessageContent class]];
    [self registerCell:[WFCUConferenceInviteCell class] forContent:[WFCCConferenceInviteMessageContent class]];
    [self registerCell:[WFCUCardCell class] forContent:[WFCCCardMessageContent class]];
    [self registerCell:[WFCUCompositeCell class] forContent:[WFCCCompositeMessageContent class]];
    [self registerCell:[WFCULinkCell class] forContent:[WFCCLinkMessageContent class]];
    [self registerCell:[WFCUGiftCell class] forContent:[WFCCGiftMessageContent class]];
    [self registerCell:[WFCUAVCallCell class] forContent:[WFCCVideoCallMessageContent class]];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (void)registerCell:(Class)cellCls forContent:(Class)msgContentCls {
    [self.collectionView registerClass:cellCls
            forCellWithReuseIdentifier:[NSString stringWithFormat:@"%d", [msgContentCls getContentType]]];
    [self.cellContentDict setObject:cellCls forKey:@([msgContentCls getContentType])];
}

- (void)showTyping:(WFCCTypingType)typingType {
    if (self.showTypingTimer) {
        [self.showTypingTimer invalidate];
    }
    
    self.showTypingTimer = [NSTimer timerWithTimeInterval:TYPING_INTERVAL/2 target:self selector:@selector(stopShowTyping) userInfo:nil repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:self.showTypingTimer forMode:NSDefaultRunLoopMode];
    if (typingType == Typing_TEXT) {
        self.title = WFCString(@"TypingHint");
    } else if(typingType == Typing_VOICE) {
        self.title = WFCString(@"RecordingHint");
    } else if(typingType == Typing_CAMERA) {
        self.title = WFCString(@"PhotographingHint");
    } else if(typingType == Typing_LOCATION) {
        self.title = WFCString(@"GetLocationHint");
    } else if(typingType == Typing_FILE) {
        self.title = WFCString(@"SelectingFileHint");
    }
    
}

- (void)stopShowTyping {
    if(self.showTypingTimer != nil) {
        [self.showTypingTimer invalidate];
        self.showTypingTimer = nil;
        if (self.conversation.type == Single_Type) {
            self.targetUser = self.targetUser;
        } else if(self.conversation.type == Group_Type) {
            self.targetGroup = self.targetGroup;
        } else if(self.conversation.type == Channel_Type) {
            self.targetChannel = self.targetChannel;
        } else if(self.conversation.type == Group_Type) {
            self.targetGroup = self.targetGroup;
        }
    }
}

- (void)onResetKeyboard:(id)sender {
    [self.chatInputBar resetInputBarStatue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (!self.firstAppear) {
        [self.chatInputBar willAppear];
    }
    

    self.title = self.targetUserInfo.userInfo[@"nickname"];
    
    if(self.conversation.type == Single_Type) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.conversation.target refresh:YES];
        self.targetUser = userInfo;
    }
    
    self.tabBarController.tabBar.hidden = YES;
    [self.collectionView reloadData];
    
    if (self.navigationController.viewControllers.count > 1) {          // 记录系统返回手势的代理
        _scrollBackDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;          // 设置系统返回手势的代理为当前控制器
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    if (self.conversation.type == Group_Type) {
        self.showAlias = ![[WFCCIMService sharedWFCIMService] isHiddenGroupMemberName:self.targetGroup.target];
    }
    
    if (self.firstAppear) {
        self.firstAppear = NO;
        [self scrollToBottom:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSString *newDraft = self.chatInputBar.draft;
    if (![self.orignalDraft isEqualToString:newDraft]) {
        self.orignalDraft = newDraft;
        [[WFCCIMService sharedWFCIMService] setConversation:self.conversation draft:newDraft];
    }
    // 设置系统返回手势的代理为我们刚进入控制器的时候记录的系统的返回手势代理
    self.navigationController.interactivePopGestureRecognizer.delegate = _scrollBackDelegate;
    
    [self.chatInputBar resetInputBarStatue];
}


- (void)sendMessage:(WFCCMessageContent *)content {
    //发送消息时，client会发出"kSendingMessageStatusUpdated“的通知，消息界面收到通知后加入到列表中。
    __weak typeof(self) ws = self;
    NSMutableArray *tousers = nil;
    if (self.privateChatUser) {
        tousers = [[NSMutableArray alloc] init];
        [tousers addObject:self.privateChatUser];
    }
    
    //{"avatar":"http://main-image.51nvwu.com/syytemmessage.png","marketPrice":8999,"nickname":"System message","orderNumber":"dia_14509_30_20201217120124","sex":1,"vipType":1}
    UserModel * currentUser = UserCenter.shared.theUser;
    NSDictionary *extr = @{
        @"avatar":currentUser.objHeadImg,
        @"nickname":currentUser.objNickname,
        @"sex":currentUser.objGender,
        @"age":currentUser.objAge,
    };
    
    NSData * extrData = [NSJSONSerialization dataWithJSONObject:extr options:NSJSONWritingFragmentsAllowed error:nil];
    
    content.extra = [[NSString alloc]initWithData:extrData encoding:NSUTF8StringEncoding];
    
    
    [[WFCCIMService sharedWFCIMService] send:self.conversation content:content toUsers:tousers expireDuration:0 success:^(long long messageUid, long long timestamp) {
        NSLog(@"send message success");
        if ([content isKindOfClass:[WFCCStickerMessageContent class]]) {
            [ws saveStickerRemoteUrl:(WFCCStickerMessageContent *)content];
        }
    } error:^(int error_code) {
        NSLog(@"send message fail(%d)", error_code);
    }];
}

- (void)onReceiveMessages:(NSNotification *)notification {
    NSArray<WFCCMessage *> *messages = notification.object;
    [self appendMessages:messages newMessage:YES highlightId:0 forceButtom:NO];
    [[WFCCIMService sharedWFCIMService] clearUnreadStatus:self.conversation];
}

- (void)onRecallMessages:(NSNotification *)notification {
    long long messageUid = [notification.object longLongValue];
    WFCCMessage *msg = [[WFCCIMService sharedWFCIMService] getMessageByUid:messageUid];
    if (msg != nil) {
        for (int i = 0; i < self.modelList.count; i++) {
            WFCUMessageModel *model = [self.modelList objectAtIndex:i];
            if (model.message.messageUid == messageUid) {
                model.message = msg;
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                break;
            }
        }
    }
}

- (void)onDeleteMessages:(NSNotification *)notification {
    long long messageUid = [notification.object longLongValue];
    for (int i = 0; i < self.modelList.count; i++) {
        WFCUMessageModel *model = [self.modelList objectAtIndex:i];
        if (model.message.messageUid == messageUid) {
            [self.modelList removeObject:model];
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            break;
        }
    }
}

- (void)onMessageDelivered:(NSNotification *)notification {
    if (self.conversation.type != Single_Type && self.conversation.type != Group_Type) {
        return;
    }
    
    NSArray<WFCCGroupMember *> *members = nil;
    if (self.conversation.type == Group_Type) {
        members = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.conversation.target forceUpdate:NO];
    }
    
    NSArray<WFCCDeliveryReport *> *delivereds = notification.object;
    __block BOOL refresh = NO;
    [delivereds enumerateObjectsUsingBlock:^(WFCCDeliveryReport * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.conversation.type == Single_Type) {
            if ([self.conversation.target isEqualToString:obj.userId]) {
                *stop = YES;
                refresh = YES;
            }
        }
        if (self.conversation.type == Group_Type) {
            for (WFCCGroupMember *member in members) {
                if ([member.memberId isEqualToString:obj.userId]) {
                    *stop = YES;
                    refresh = YES;
                }
            }
        }
    }];
    
    if (refresh) {
        self.deliveryDict = [[WFCCIMService sharedWFCIMService] getMessageDelivery:self.conversation];
        WFCCGroupInfo *groupInfo = nil;

        for (int i = 0; i < self.modelList.count; i++) {
            WFCUMessageModel *model  = self.modelList[i];
            model.deliveryDict = self.deliveryDict;
            if (model.message.direction == MessageDirection_Receive || model.deliveryRate == 1.f) {
                continue;
            }
            
            if (self.conversation.type == Single_Type) {
                if (model.message.serverTime <= [[model.deliveryDict objectForKey:model.message.conversation.target] longLongValue]) {
                    float rate = 1.f;
                    if (rate != model.deliveryRate) {
                        model.deliveryRate = rate;
                        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                    }
                }
            } else { //group
                long long messageTS = model.message.serverTime;
                __block int delieveriedCount = 0;
                [model.deliveryDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj longLongValue] >= messageTS) {
                        delieveriedCount++;
                    }
                }];
                
                if (!groupInfo) {
                    groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:model.message.conversation.target refresh:NO];
                }
                
                float rate = (float)delieveriedCount/(groupInfo.memberCount - 1);
                if (rate != model.deliveryRate) {
                    model.deliveryRate = rate;
                    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                }
            }
        }
    }
}

- (void)onMessageReaded:(NSNotification *)notification {
    if (self.conversation.type != Single_Type && self.conversation.type != Group_Type) {
        return;
    }
    
    NSArray<WFCCReadReport *> *readeds = notification.object;
    __block BOOL refresh = NO;
    [readeds enumerateObjectsUsingBlock:^(WFCCReadReport * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.conversation isEqual:self.conversation]) {
            *stop = YES;
            refresh = YES;
        }
    }];
    
    if (refresh) {
        self.readDict = [[WFCCIMService sharedWFCIMService] getConversationRead:self.conversation];
        WFCCGroupInfo *groupInfo = nil;

        for (int i = 0; i < self.modelList.count; i++) {
            WFCUMessageModel *model  = self.modelList[i];
            model.readDict = self.readDict;
            if (model.message.direction == MessageDirection_Receive || model.readRate == 1.f) {
                continue;
            }
            
            if (self.conversation.type == Single_Type) {
                if (model.message.serverTime <= [[model.readDict objectForKey:model.message.conversation.target] longLongValue]) {
                    float rate = 1.f;
                    if (rate != model.readRate) {
                        model.readRate = rate;
                        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                    }
                }
            } else { //group
                long long messageTS = model.message.serverTime;
                __block int delieveriedCount = 0;
                [model.readDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj longLongValue] >= messageTS) {
                        delieveriedCount++;
                    }
                }];
                
                if (!groupInfo) {
                    groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:model.message.conversation.target refresh:NO];
                }
                
                float rate = (float)delieveriedCount/(groupInfo.memberCount - 1);
                if (rate != model.readRate) {
                    model.readRate = rate;
                    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                }
            }
        }
    }
}

#if WFCU_SUPPORT_VOIP
- (void)onCallStateChanged:(NSNotification *)notification {
    long long messageUid = [[notification.userInfo objectForKey:@"messageUid"] longLongValue];
    WFCCMessage *msg = [[WFCCIMService sharedWFCIMService] getMessageByUid:messageUid];
    
    for (int i = 0; i < self.modelList.count; i++) {
        WFCUMessageModel *model = [self.modelList objectAtIndex:i];
        if (model.message.messageUid == messageUid) {
            model.message.content = msg.content;
            [self.collectionView reloadData];
            break;
        }
    }
    if ([[notification.userInfo objectForKey:@"state"] intValue] == kWFAVEngineStateIncomming) {
        if ([[[UIDevice currentDevice] systemVersion] rangeOfString:@"10."].location == 0) {
            [self.chatInputBar resetInputBarStatue];
        }
    }
}
#endif

- (void)onSendingMessage:(NSNotification *)notification {
    WFCCMessage *message = [notification.userInfo objectForKey:@"message"];
    WFCCMessageStatus status = [[notification.userInfo objectForKey:@"status"] integerValue];
    if (status == Message_Status_Sending) {
        if ([message.conversation isEqual:self.conversation]) {
            [self appendMessages:@[message] newMessage:YES highlightId:0 forceButtom:YES];
        }
    }
    
}

- (void)onMessageListChanged:(NSNotification *)notification {
    [self reloadMessageList];
}

- (void)onSettingUpdated:(NSNotification *)notification {
    [self reloadMessageList];
}

- (void)reloadMessageList {
    self.deliveryDict = [[WFCCIMService sharedWFCIMService] getMessageDelivery:self.conversation];
    self.readDict = [[WFCCIMService sharedWFCIMService] getConversationRead:self.conversation];
    
    NSArray *messageList;
    if (self.highlightMessageId > 0) {
        NSArray *messageListOld = [[WFCCIMService sharedWFCIMService] getMessages:self.conversation contentTypes:nil from:self.highlightMessageId+1 count:15 withUser:self.privateChatUser];
        NSArray *messageListNew = [[WFCCIMService sharedWFCIMService] getMessages:self.conversation contentTypes:nil from:self.highlightMessageId count:-15 withUser:self.privateChatUser];
        NSMutableArray *list = [[NSMutableArray alloc] init];
        [list addObjectsFromArray:messageListNew];
        [list addObjectsFromArray:messageListOld];
        messageList = [list copy];
        [[WFCCIMService sharedWFCIMService] clearUnreadStatus:self.conversation];
        if (messageListNew.count == 15) {
            self.hasNewMessage = YES;
        }
    } else {
        BOOL firstIn = NO;
        int count = (int)self.modelList.count;
        if (count > 50) {
            count = 50;
        } else if(count == 0) {
            count = 15;
            firstIn = YES;
        }
        messageList = [[WFCCIMService sharedWFCIMService] getMessages:self.conversation contentTypes:nil from:0 count:count withUser:self.privateChatUser];
        
        self.mentionedMsgs = [[[WFCCIMService sharedWFCIMService] getMessages:self.conversation messageStatus:@[@(Message_Status_Mentioned), @(Message_Status_AllMentioned)] from:0 count:100 withUser:self.privateChatUser] mutableCopy];
        
        if (self.mentionedMsgs.count) {
            [self showMentionedLabel];
        }
        
        if (firstIn) {
            WFCCConversationInfo *info = [[WFCCIMService sharedWFCIMService] getConversationInfo:self.conversation];
            if (info.unreadCount.unread >= 10 && info.unreadCount.unread < 300) { //如果消息太多了就没有必要显示新消息了
                self.unreadMessageCount = info.unreadCount.unread;
                self.firstUnreadMessageId = [[WFCCIMService sharedWFCIMService] getFirstUnreadMessageId:self.conversation];
                [self showUnreadLabel];
            }
        }
        
        [[WFCCIMService sharedWFCIMService] clearUnreadStatus:self.conversation];
    }
    
    self.modelList = [[NSMutableArray alloc] init];
    
    [self appendMessages:messageList newMessage:NO highlightId:self.highlightMessageId forceButtom:NO];
    self.highlightMessageId = 0;
}

- (void)showMentionedLabel {
    if (!self.mentionedButton) {
        CGRect bount = self.view.bounds;
        self.mentionedButton = [[UIButton alloc] initWithFrame:CGRectMake(bount.size.width+15, 240, 0, 30)];
        self.mentionedButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.mentionedButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.mentionedButton.backgroundColor = [UIColor whiteColor];
        self.mentionedButton.layer.cornerRadius = 15;
        self.mentionedButton.layer.borderColor = [UIColor blackColor].CGColor;
        [self.mentionedButton addTarget:self action:@selector(onMentionedBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.mentionedButton];
        [UIView animateWithDuration:0.8 animations:^{
            self.mentionedButton.frame = CGRectMake(bount.size.width - 85, 240, 100, 30);
        }];
    }
    [self.mentionedButton setTitle:[NSString stringWithFormat:@"%d 条@消息", self.mentionedMsgs.count] forState:UIControlStateNormal];
}

- (void)dismissMentionedLabel {
    CGRect bount = self.view.bounds;
    [UIView animateWithDuration:0.5 animations:^{
        self.mentionedButton.frame = CGRectMake(bount.size.width+15, 240, 0, 30);
        } completion:^(BOOL finished) {
            [self.mentionedButton removeFromSuperview];
            self.mentionedButton = nil;
        }];
}

- (void)onMentionedBtn:(id)sender {
    if (![self checkLastMentionedMsgLoaded]) {
        [self loadMoreToLastMention];
    } else {
        [self scrollToLastMentionedMessage];
    }
}

- (void)loadMoreToLastMention {
    __weak typeof(self)ws = self;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    [self loadMoreMessage:YES completion:^(BOOL more){
        if (more && ![ws checkLastMentionedMsgLoaded]) {
            [ws loadMoreToLastMention];
        } else {
            [ws scrollToLastMentionedMessage];
        }
    }];
}

- (void)scrollToLastMentionedMessage {
    for (int i = 0; i < self.modelList.count; i++) {
        if (self.modelList[i].message.messageId == self.mentionedMsgs.firstObject.messageId) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }
    }
}

- (BOOL)checkLastMentionedMsgLoaded {
    for (WFCUMessageModel *model in self.modelList) {
        if (model.message.messageId == self.mentionedMsgs.firstObject.messageId) {
            return YES;
        }
    }
    return NO;
}

- (void)showUnreadLabel {
    CGRect bount = self.view.bounds;
    self.unreadButton = [[UIButton alloc] initWithFrame:CGRectMake(bount.size.width+15, 200, 0, 30)];
    [self.unreadButton setTitle:[NSString stringWithFormat:@"%d 条新消息", self.unreadMessageCount] forState:UIControlStateNormal];
    self.unreadButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.unreadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.unreadButton.backgroundColor = [UIColor whiteColor];
    self.unreadButton.layer.cornerRadius = 15;
    self.unreadButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.unreadButton addTarget:self action:@selector(onUnreadBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.unreadButton];
    [UIView animateWithDuration:0.6 animations:^{
        self.unreadButton.frame = CGRectMake(bount.size.width - 85, 200, 100, 30);
    }];
}

- (void)dismissUnreadLabel {
    CGRect bount = self.view.bounds;
    [UIView animateWithDuration:0.5 animations:^{
        self.unreadButton.frame = CGRectMake(bount.size.width+15, 200, 0, 30);
        } completion:^(BOOL finished) {
            [self.unreadButton removeFromSuperview];
            self.unreadButton = nil;
        }];
}

- (void)onUnreadBtn:(id)sender {
    [self dismissUnreadLabel];
    if (![self checkFirstUnreadMsgLoaded]) {
        [self loadMoreToFirstUnread];
    } else {
        [self scrollToFirstUnreadMessage];
    }
}
- (BOOL)checkFirstUnreadMsgLoaded {
    for (WFCUMessageModel *model in self.modelList) {
        if (model.message.messageId <= self.firstUnreadMessageId) {
            return YES;
        }
    }
    return NO;
}
- (void)loadMoreToFirstUnread {
    __weak typeof(self)ws = self;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    [self loadMoreMessage:YES completion:^(BOOL more){
        if (more && ![ws checkFirstUnreadMsgLoaded]) {
            [ws loadMoreToFirstUnread];
        } else {
            [ws scrollToFirstUnreadMessage];
        }
    }];
}
- (void)scrollToFirstUnreadMessage {
    for (int i = 0; i < self.modelList.count; i++) {
        if (self.modelList[i].message.messageId == self.firstUnreadMessageId) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
    }
}

- (void)appendMessages:(NSArray<WFCCMessage *> *)messages newMessage:(BOOL)newMessage highlightId:(long)highlightId forceButtom:(BOOL)forceButtom {
    if (messages.count == 0) {
        return;
    }
    
    int count = 0;
    NSMutableArray *modifiedAliasUsers = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < messages.count; i++) {
        WFCCMessage *message = [messages objectAtIndex:i];
        
        if (![message.conversation isEqual:self.conversation]) {
            continue;
        }
        
        if ([message.content isKindOfClass:[WFCCTypingMessageContent class]] && message.direction == MessageDirection_Receive) {
            double now = [[NSDate date] timeIntervalSince1970];
            if (now - message.serverTime + [WFCCNetworkService sharedInstance].serverDeltaTime < TYPING_INTERVAL) {
                WFCCTypingMessageContent *content = (WFCCTypingMessageContent *)message.content;
                [self showTyping:content.type];
            }
            continue;
        }
        
        if (!([message.content.class getContentFlags] & 0x1)) {
            continue;
        }
        BOOL duplcated = NO;
        for (WFCUMessageModel *model in self.modelList) {
            if (model.message.messageUid !=0 && model.message.messageUid == message.messageUid) {
                duplcated = YES;
                break;
            }
        }
        if (duplcated) {
            continue;
        }
        
        count++;
        
        if (newMessage) {
            BOOL showTime = YES;
            if (self.modelList.count > 0 && (message.serverTime -  (self.modelList[self.modelList.count - 1]).message.serverTime < 60 * 1000)) {
                showTime = NO;
            }
            WFCUMessageModel *model = [WFCUMessageModel modelOf:message showName:message.direction == MessageDirection_Receive && self.showAlias showTime:showTime];
            model.selecting = self.multiSelecting;
            model.selected = [self.selectedMessageIds containsObject:@(message.messageId)];
            model.deliveryDict = self.deliveryDict;
            model.readDict = self.readDict;
            [self.modelList addObject:model];
            if (messages.count == 1) {
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.modelList.count - 1 inSection:0]]];
            }
            
            if (self.conversation.type == Group_Type && [message.content isKindOfClass:[WFCCModifyGroupAliasNotificationContent class]]) {
                [modifiedAliasUsers addObject:message.fromUser];
            }
            
            [self.nMsgSet addObject:@(message.messageId)];
        } else {
            if (self.modelList.count > 0 && (self.modelList[0].message.serverTime - message.serverTime < 60 * 1000) && i != 0) {
                self.modelList[0].showTimeLabel = NO;
            }
            WFCUMessageModel *model = [WFCUMessageModel modelOf:message showName:message.direction == MessageDirection_Receive&&self.showAlias showTime:YES];
            if (self.firstUnreadMessageId && message.messageId == self.firstUnreadMessageId) {
                model.lastReadMessage = YES;
            }
            model.selecting = self.multiSelecting;
            model.selected = [self.selectedMessageIds containsObject:@(message.messageId)];
            model.deliveryDict = self.deliveryDict;
            model.readDict = self.readDict;
            [self.modelList insertObject:model atIndex:0];
        }
    }
    
    if (count > 0) {
        [self stopShowTyping];
    }
    
    BOOL isAtButtom = NO;
    if (newMessage && !self.hasNewMessage) {
        if (@available(iOS 12.0, *)) {
            CGPoint offset = self.collectionView.contentOffset;
            CGSize size = self.collectionView.contentSize;
            CGSize visiableSize = CGSizeZero;
            visiableSize = self.collectionView.visibleSize;
            isAtButtom = (offset.y + visiableSize.height - size.height) > -100;
        } else {
            isAtButtom = YES;
        }
    }
    if (newMessage && messages.count == 1) {
        NSLog(@"alread reload the message");
    } else {
        [self.collectionView reloadData];
    }
    if (newMessage || self.modelList.count == messages.count) {
        if(isAtButtom) {
            forceButtom = true;
        }
    } else {
        CGFloat offset = 0;
        for (int i = 0; i < count; i++) {
            CGSize size = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            offset += size.height;
        }
        self.collectionView.contentOffset = CGPointMake(0, offset);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.collectionView.contentOffset = CGPointMake(0, offset - 20);
        }];
    }
    
    if (highlightId > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            int row = 0;
            for (int i = 0; i < self.modelList.count; i++) {
                WFCUMessageModel *model = self.modelList[i];
                if (model.message.messageId == highlightId) {
                    row = i;
                    model.highlighted = YES;
                    break;
                }
            }
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        });
    } else if (forceButtom) {
        [self scrollToBottom:YES];
    }
    
    if (modifiedAliasUsers.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSArray<NSIndexPath *> *visibleItems = self.collectionView.indexPathsForVisibleItems;
            NSMutableArray *needUpdateItems = [[NSMutableArray alloc] init];
            for (NSIndexPath *item in visibleItems) {
                WFCUMessageModel *model = [self.modelList objectAtIndex:item.row];
                if ([modifiedAliasUsers containsObject:model.message.fromUser]) {
                    [needUpdateItems addObject:item];
                }
            }
            if (needUpdateItems.count) {
                [self.collectionView reloadItemsAtIndexPaths:needUpdateItems];
            }
        });
        
    }
    
    if (newMessage && !isAtButtom && self.nMsgSet.count > 0) {
        [self showNewMsgTip];
    } else {
        [self dismissNewMsgTip];
    }
}

- (void)showNewMsgTip {
    [self.newMsgTipButton setTitle:[NSString stringWithFormat:@"%ld", self.nMsgSet.count] forState:UIControlStateNormal];
    self.newMsgTipButton.hidden = NO;
}

- (void)dismissNewMsgTip {
    [self.nMsgSet removeAllObjects];
    _newMsgTipButton.hidden = YES;
}

- (UIButton *)newMsgTipButton {
    if (!_newMsgTipButton) {
        _newMsgTipButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 36, self.chatInputBar.frame.origin.y - 40, 24, 24)];
        _newMsgTipButton.layer.cornerRadius = 12;
        _newMsgTipButton.titleLabel.font = [UIFont systemFontOfSize:8];
        _newMsgTipButton.layer.borderColor = [UIColor blackColor].CGColor;
        _newMsgTipButton.backgroundColor = [UIColor blueColor];
        [_newMsgTipButton addTarget:self action:@selector(onNewMsgTipBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_newMsgTipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.backgroundView addSubview:_newMsgTipButton];
    }
    return _newMsgTipButton;;
}
- (void)onNewMsgTipBtn:(id)sender {
    [self scrollToBottom:YES];
}
- (WFCUMessageModel *)modelOfMessage:(long)messageId {
    if (messageId <= 0) {
        return nil;
    }
    for (WFCUMessageModel *model in self.modelList) {
        if (model.message.messageId == messageId) {
            return model;
        }
    }
    return nil;
}

- (void)stopPlayer {
    if (self.player && [self.player isPlaying]) {
        [self.player stop];
        if ([self.playTimer isValid]) {
            [self.playTimer invalidate];
            self.playTimer = nil;
        }
    }
    [self modelOfMessage:self.playingMessageId].voicePlaying = NO;
    self.playingMessageId = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:kVoiceMessagePlayStoped object:nil];
}

-(void)prepardToPlay:(WFCUMessageModel *)model {
    
    if (self.playingMessageId == model.message.messageId) {
        [self stopPlayer];
    } else {
        [self stopPlayer];
        
        self.playingMessageId = model.message.messageId;
        
        WFCCSoundMessageContent *soundContent = (WFCCSoundMessageContent *)model.message.content;
        if (soundContent.localPath.length == 0) {
            __weak typeof(self) weakSelf = self;
            
            BOOL isDownloading = [[WFCUMediaMessageDownloader sharedDownloader] tryDownload:model.message success:^(long long messageUid, NSString *localPath) {
                model.mediaDownloading = NO;
                [weakSelf startPlay:model];
            } error:^(long long messageUid, int error_code) {
                model.mediaDownloading = NO;
            }];
            
            if (isDownloading) {
                model.mediaDownloading = YES;
            }
            
        } else {
            [self startPlay:model];
        }
        
    }
}

-(void)startPlay:(WFCUMessageModel *)model {
    
    if ([model.message.content isKindOfClass:[WFCCSoundMessageContent class]]) {
        // Setup audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                   error:nil];
        
    
        
        WFCCSoundMessageContent *snc = (WFCCSoundMessageContent *)model.message.content;
        NSError *error = nil;
        self.player = [[AVAudioPlayer alloc] initWithData:[snc getWavData] error:&error];
        [self.player setDelegate:self];
        [self.player prepareToPlay];
        [self.player play];
        model.voicePlaying = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kVoiceMessageStartPlaying object:@(self.playingMessageId)];
    } else if([model.message.content isKindOfClass:[WFCCVideoMessageContent class]]) {
        WFCCVideoMessageContent *videoMsg = (WFCCVideoMessageContent *)model.message.content;
        NSURL *url = [NSURL fileURLWithPath:[videoMsg.localPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        
        if (!url) {
            [self.view makeToast:@"无法播放"];
            return;
        }
        
        if (!self.videoPlayerViewController) {
            self.videoPlayerViewController = [VideoPlayerKit videoPlayerWithContainingView:self.view optionalTopView:nil hideTopViewWithControls:YES];
            self.videoPlayerViewController.allowPortraitFullscreen = YES;
        } else {
            [self.videoPlayerViewController.view removeFromSuperview];
        }
        
        [self.view addSubview:self.videoPlayerViewController.view];
        
        [self.videoPlayerViewController playVideoWithTitle:@" " URL:url videoID:nil shareURL:nil isStreaming:NO playInFullScreen:YES];
    }
    
}

- (void)showTemplateMessage:(NSArray *)messages{
    
    WFCtemplateMessageSheet* sheet = [[WFCtemplateMessageSheet alloc]initWithMessages:messages];
    [sheet showInView:self.view];
    sheet.delegate = self;
}

#pragma mark - WFCtemplateMessageSheetDelegate
- (void)messageSheet:(WFCtemplateMessageSheet *)sheet didSelectMessage:(int)messageID messageContent:(nonnull NSString *)content{
    WFCCTextMessageContent *txtContent = [[WFCCTextMessageContent alloc] init];
    txtContent.text = content;
    [self sendMessage:txtContent];
    
    [UserCenter.shared messageTemplateCallbackWithReciveID:self.conversation.target.integerValue templateID:messageID success:^() {
        
    } fail:^(HawaError * _Nonnull error) {
        
    }];
    
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.modelList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WFCUMessageModel *model = self.modelList[indexPath.row];
    NSString *objName = [NSString stringWithFormat:@"%d", [model.message.content.class getContentType]];
    
    WFCUMessageCellBase *cell = nil;
    if(![self.cellContentDict objectForKey:@([model.message.content.class getContentType])]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"%d", [WFCCUnknownMessageContent getContentType]] forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:objName forIndexPath:indexPath];
    }
    
    cell.delegate = self;
    
    [[NSNotificationCenter defaultCenter] removeObserver:cell];
    cell.model = model;
    
    return cell;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if(!self.headerView) {
            self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
            self.headerActivityView.center = CGPointMake(self.headerView.bounds.size.width/2, self.headerView.bounds.size.height/2);
            [self.headerView addSubview:self.headerActivityView];
        }
        return self.headerView;
    } else {
        if(!self.footerView) {
            self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
            self.footerActivityView.center = CGPointMake(self.footerView.bounds.size.width/2, self.footerView.bounds.size.height/2);
            [self.footerView addSubview:self.footerActivityView];
        }
        return self.footerView;
    }
    return nil;
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    WFCUMessageModel *model = self.modelList[indexPath.row];
    
    if (self.mentionedMsgs.count) {
        for (WFCCMessage *msg in self.mentionedMsgs) {
            if (msg.messageId == model.message.messageId) {
                [self.mentionedMsgs removeObject:msg];
                if (!self.mentionedMsgs.count) {
                    [self dismissMentionedLabel];
                } else {
                    [self showMentionedLabel];
                }
                break;
            }
        }
    }
    
    if (self.unreadMessageCount) {
        if (self.firstUnreadMessageId >= model.message.messageId) {
            self.unreadMessageCount = 0;
            self.firstUnreadMessageId = 0;
            [self dismissUnreadLabel];
        }
    }
    
    if (self.nMsgSet.count) {
        if ([self.nMsgSet containsObject:@(model.message.messageId)]) {
            [self.nMsgSet removeObject:@(model.message.messageId)];
            if (self.nMsgSet.count) {
                [self showNewMsgTip];
            } else {
                [self dismissNewMsgTip];
            }
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WFCUMessageModel *model = self.modelList[indexPath.row];
    Class cellCls = self.cellContentDict[@([[model.message.content class] getContentType])];
    if (!cellCls) {
        cellCls = self.cellContentDict[@([[WFCCUnknownMessageContent class] getContentType])];
    }
    return [cellCls sizeForCell:model withViewWidth:self.collectionView.frame.size.width];
}

#pragma mark - MessageCellDelegate
- (void)didTapMessageCell:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    if ([model.message.content isKindOfClass:[WFCCImageMessageContent class]]) {
        if (self.conversation.type == Chatroom_Type) {
            NSMutableArray *imageMsgs = [[NSMutableArray alloc] init];
            for (WFCUMessageModel *msgModle in self.modelList) {
                if ([msgModle.message.content isKindOfClass:[WFCCImageMessageContent class]]) {
                    [imageMsgs addObject:msgModle.message];
                }
            }
            self.imageMsgs = imageMsgs;
        } else {
            self.imageMsgs = [[WFCCIMService sharedWFCIMService] getMessages:self.conversation contentTypes:@[@(MESSAGE_CONTENT_TYPE_IMAGE)] from:0 count:100 withUser:self.privateChatUser];
        }
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        browser.sourceImagesContainerView = self.backgroundView;
        browser.showAll = YES;
        browser.imageCount = self.imageMsgs.count;
        int i;
        for (i = 0; i < self.imageMsgs.count; i++) {
            if ([self.imageMsgs objectAtIndex:i].messageId == model.message.messageId) {
                break;
            }
        }
        if (i == self.imageMsgs.count) {
            i = 0;
        }
        [self onResetKeyboard:nil];
        browser.currentImageIndex = i;
        browser.delegate = self;
        [browser show]; // 展示图片浏览器
    } else if([model.message.content isKindOfClass:[WFCCSoundMessageContent class]]) {
        if (model.message.direction == MessageDirection_Receive && model.message.status != Message_Status_Played) {
            [[WFCCIMService sharedWFCIMService] setMediaMessagePlayed:model.message.messageId];
            model.message.status = Message_Status_Played;
            [self.collectionView reloadItemsAtIndexPaths:@[[self.collectionView indexPathForCell:cell]]];
        }
        
        [self prepardToPlay:model];
    } else if([model.message.content isKindOfClass:[WFCCLocationMessageContent class]]) {
        WFCCLocationMessageContent *locContent = (WFCCLocationMessageContent *)model.message.content;
        WFCULocationViewController *vc = [[WFCULocationViewController alloc] initWithLocationPoint:[[WFCULocationPoint alloc] initWithCoordinate:locContent.coordinate andTitle:locContent.title]];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([model.message.content isKindOfClass:[WFCCFileMessageContent class]]) {
        WFCCFileMessageContent *fileContent = (WFCCFileMessageContent *)model.message.content;
        
        __weak typeof(self)ws = self;
        [[WFCCIMService sharedWFCIMService] getAuthorizedMediaUrl:model.message.messageUid mediaType:Media_Type_FILE mediaPath:fileContent.remoteUrl success:^(NSString *authorizedUrl) {
            WFCUBrowserViewController *bvc = [[WFCUBrowserViewController alloc] init];
            bvc.url = authorizedUrl;
            [ws.navigationController pushViewController:bvc animated:YES];
        } error:^(int error_code) {
            WFCUBrowserViewController *bvc = [[WFCUBrowserViewController alloc] init];
            bvc.url = fileContent.remoteUrl;
            [ws.navigationController pushViewController:bvc animated:YES];
        }];
        
        
    } else if ([model.message.content isKindOfClass:[WFCCCallStartMessageContent class]]) {
        WFCCCallStartMessageContent *callStartMsg = (WFCCCallStartMessageContent *)model.message.content;
#if WFCU_SUPPORT_VOIP
        [self didTouchVideoBtn:callStartMsg.isAudioOnly];
#endif
    } else if([model.message.content isKindOfClass:[WFCCVideoMessageContent class]]) {
        WFCCVideoMessageContent *videoMsg = (WFCCVideoMessageContent *)model.message.content;
        if (model.message.direction == MessageDirection_Receive && model.message.status != Message_Status_Played) {
            [[WFCCIMService sharedWFCIMService] setMediaMessagePlayed:model.message.messageId];
            model.message.status = Message_Status_Played;
            [self.collectionView reloadItemsAtIndexPaths:@[[self.collectionView indexPathForCell:cell]]];
        }
        
        if (videoMsg.localPath.length == 0) {
            model.mediaDownloading = YES;
            __weak typeof(self) weakSelf = self;
            
            [[WFCUMediaMessageDownloader sharedDownloader] tryDownload:model.message success:^(long long messageUid, NSString *localPath) {
                model.mediaDownloading = NO;
                [weakSelf startPlay:model];
            } error:^(long long messageUid, int error_code) {
                model.mediaDownloading = NO;
            }];
        } else {
            [self startPlay:model];
        }
    } else if([model.message.content isKindOfClass:[WFCCConferenceInviteMessageContent class]]) {
        if ([WFAVEngineKit sharedEngineKit].supportConference) {

        }
    } else if([model.message.content isKindOfClass:[WFCCCardMessageContent class]]) {
        
        

    } else if([model.message.content isKindOfClass:[WFCCCompositeMessageContent class]]) {
        WFCUCompositeMessageViewController *vc = [[WFCUCompositeMessageViewController alloc] init];
        vc.compositeContent = (WFCCCompositeMessageContent *)model.message.content;
        [self.navigationController pushViewController:vc animated:YES];
    } else if([model.message.content isKindOfClass:[WFCCLinkMessageContent class]]) {
        WFCCLinkMessageContent *content = (WFCCLinkMessageContent *)model.message.content;
        WFCUBrowserViewController *bvc = [[WFCUBrowserViewController alloc] init];
        bvc.url = content.url;
        [self.navigationController pushViewController:bvc animated:YES];
    } else if ([model.message.content isKindOfClass:[WFCCVideoCallMessageContent class]]){
        if (model.message.direction == MessageDirection_Send ) {
                
            NSData *data =  [model.message.content.extra dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *extroData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            int msgType = [extroData[@"msgType"] intValue];
            
            if (msgType < 60) {
                UserModel * userM = [[UserModel alloc]init];
                [userM setDataWithDataSource:self.targetUserInfo.userInfo];
                [HWAVAuthModel.shared objcCallAudio:userM];
            } else {
                UserModel * userM = [[UserModel alloc]init];
                [userM setDataWithDataSource:self.targetUserInfo.userInfo];
                [HWAVAuthModel.shared objcCallVideo:userM];
            }
        }
    }
}

- (void)didDoubleTapMessageCell:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    if ([model.message.content isKindOfClass:[WFCCTextMessageContent class]]) {
        WFCCTextMessageContent *txtMsgContent = (WFCCTextMessageContent *)model.message.content;
        [self.chatInputBar resetInputBarStatue];
        
        UIView *textContainer = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        textContainer.backgroundColor = self.view.backgroundColor;
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - kStatusBarAndNavigationBarHeight - kTabbarSafeBottomMargin)];
         textView.text = txtMsgContent.text;
        textView.textAlignment = NSTextAlignmentCenter;
        textView.font = [UIFont systemFontOfSize:28];
        textView.editable = NO;
        textView.backgroundColor = self.view.backgroundColor;
        
        [textContainer addSubview:textView];
        [textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTextMessageDetailView:)]];
        [[UIApplication sharedApplication].keyWindow addSubview:textContainer];
    }
}

- (void)didTapTextMessageDetailView:(id)sender {
    if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
        UIGestureRecognizer *gesture = (UIGestureRecognizer *)sender;
        [gesture.view.superview removeFromSuperview];
    }
    NSLog(@"close windows");
}

- (void)didTapMessagePortrait:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    
    if (![model.message.fromUser isEqualToString:@"239"] && ![model.message.fromUser isEqualToString:@"238"] ) {
        HWProfileViewController * profile = [[HWProfileViewController alloc] init:  [NSNumber numberWithInt:[model.message.fromUser intValue]]];
        [self.navigationController pushViewController:profile animated:YES];
    }
}

- (void)didLongPressMessageCell:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    if ([cell isKindOfClass:[WFCUMessageCellBase class]]) {
        //        if (!self.isFirstResponder) {
        //            [self becomeFirstResponder];
        //        }
        
        [self displayMenu:(WFCUMessageCellBase *)cell];
    }
}

- (void)didLongPressMessagePortrait:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    if (self.conversation.type == Group_Type) {
        if (model.message.direction == MessageDirection_Receive) {
            WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:model.message.fromUser refresh:NO];
            [self.chatInputBar appendMention:model.message.fromUser name:sender.displayName];
        }
    } else if(self.conversation.type == Channel_Type) {
        WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.conversation.target refresh:NO];
        if ([channelInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:WFCString(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:WFCString(@"ChatWithSubscriber") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (model.message.direction == MessageDirection_Receive) {
                    WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.conversation.target refresh:NO];
                    if ([channelInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
                        WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
                        mvc.conversation = [WFCCConversation conversationWithType:self.conversation.type target:self.conversation.target line:self.conversation.line];
                        mvc.privateChatUser = model.message.fromUser;
                        [self.navigationController pushViewController:mvc animated:YES];
                    }
                }
                
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}
- (void)didTapResendBtn:(WFCUMessageModel *)model {
    NSInteger index = [self.modelList indexOfObject:model];
    if (index >= 0) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [self.modelList removeObjectAtIndex:index];
        [self.collectionView deleteItemsAtIndexPaths:@[path]];
        [[WFCCIMService sharedWFCIMService] deleteMessage:model.message.messageId];
        [self sendMessage:model.message.content];
    }
}

- (void)didSelectUrl:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model withUrl:(NSString *)urlString {
    WFCUBrowserViewController *bvc = [[WFCUBrowserViewController alloc] init];
    bvc.url = urlString;
    [self.navigationController pushViewController:bvc animated:YES];
}

- (void)didSelectPhoneNumber:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model withPhoneNumber:(NSString *)phoneNumber {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:WFCString(@"PhoneNumberHint"), phoneNumber] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:WFCString(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:WFCString(@"Call") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"telprompt:%@", phoneNumber]];
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:WFCString(@"CopyNumber") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = phoneNumber;
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:callAction];
    [alertController addAction:copyAction];
    //    [alertController addAction:addContactAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)reeditRecalledMessage:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    WFCCRecallMessageContent *recall = (WFCCRecallMessageContent *)model.message.content;
    [self.chatInputBar appendText:recall.originalSearchableContent];
}

- (void)didTapReceiptView:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    WFCUReceiptViewController *receipt = [[WFCUReceiptViewController alloc] init];
    receipt.message = model.message;
    [self.navigationController pushViewController:receipt animated:YES];
}

- (void)didTapQuoteLabel:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    if ([model.message.content isKindOfClass:[WFCCTextMessageContent class]]) {
        WFCCTextMessageContent *txtContent = (WFCCTextMessageContent *)model.message.content;
        if (txtContent.quoteInfo) {
            WFCCMessage *msg = [[WFCCIMService sharedWFCIMService] getMessageByUid:txtContent.quoteInfo.messageUid];
            if (!msg || [msg.content isKindOfClass:[WFCCRecallMessageContent class]]) {
                [self.view makeToast:@"消息不存在了！"];
                NSLog(@"msg not exist");
                return;
            }

            if ([msg.content isKindOfClass:[WFCCTextMessageContent class]]) {
                WFCCTextMessageContent *txtContent = (WFCCTextMessageContent *)msg.content;
                
                [self.chatInputBar resetInputBarStatue];
                
                UIView *textContainer = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                textContainer.backgroundColor = self.view.backgroundColor;
                
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - kStatusBarAndNavigationBarHeight - kTabbarSafeBottomMargin)];
                 textView.text = txtContent.text;
                textView.textAlignment = NSTextAlignmentCenter;
                textView.font = [UIFont systemFontOfSize:28];
                textView.editable = NO;
                textView.backgroundColor = self.view.backgroundColor;
                
                [textContainer addSubview:textView];
                [textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTextMessageDetailView:)]];
                [[UIApplication sharedApplication].keyWindow addSubview:textContainer];
            } else if ([msg.content isKindOfClass:[WFCCImageMessageContent class]]) {
                self.imageMsgs = @[msg];
                SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
                browser.sourceImagesContainerView = self.backgroundView;
                browser.showAll = NO;
                browser.imageCount = self.imageMsgs.count;
                [self onResetKeyboard:nil];
                browser.currentImageIndex = 0;
                browser.delegate = self;
                [browser show]; // 展示图片浏览器
            } else if ([msg.content isKindOfClass:[WFCCLocationMessageContent class]]) {
                WFCCLocationMessageContent *locContent = (WFCCLocationMessageContent *)msg.content;
                WFCULocationViewController *vc = [[WFCULocationViewController alloc] initWithLocationPoint:[[WFCULocationPoint alloc] initWithCoordinate:locContent.coordinate andTitle:locContent.title]];
                [self.navigationController pushViewController:vc animated:YES];
            } else if ([msg.content isKindOfClass:[WFCCFileMessageContent class]]) {
                WFCCFileMessageContent *fileContent = (WFCCFileMessageContent *)msg.content;
                
                __weak typeof(self)ws = self;
                [[WFCCIMService sharedWFCIMService] getAuthorizedMediaUrl:msg.messageUid mediaType:Media_Type_FILE mediaPath:fileContent.remoteUrl success:^(NSString *authorizedUrl) {
                    WFCUBrowserViewController *bvc = [[WFCUBrowserViewController alloc] init];
                    bvc.url = authorizedUrl;
                    [ws.navigationController pushViewController:bvc animated:YES];
                } error:^(int error_code) {
                    WFCUBrowserViewController *bvc = [[WFCUBrowserViewController alloc] init];
                    bvc.url = fileContent.remoteUrl;
                    [ws.navigationController pushViewController:bvc animated:YES];
                }];
            } else if ([msg.content isKindOfClass:[WFCCCardMessageContent class]]) {
                WFCCCardMessageContent *card = (WFCCCardMessageContent *)msg.content;
                
            } else {
                //有些消息内容不能在当前页面显示，跳转到新的页面显示
//            if ([msg.content isKindOfClass:[WFCCSoundMessageContent class]])
//            if ([msg.content isKindOfClass:[WFCCStickerMessageContent class]])
//            if ([msg.content isKindOfClass:[WFCCVideoMessageContent class]])
                WFCUQuoteViewController *vc = [[WFCUQuoteViewController alloc] init];
                vc.messageUid = msg.messageUid;
                [self.navigationController pushViewController:vc animated:YES];
                
            }
        }
    }
    
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"player finished");
    [self stopPlayer];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"player decode error");
    [[[UIAlertView alloc] initWithTitle:WFCString(@"Warning") message:WFCString(@"NetworkError") delegate:nil cancelButtonTitle:WFCString(@"Ok") otherButtonTitles:nil, nil] show];
    [self stopPlayer];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.chatInputBar resetInputBarStatue];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.hasNewMessage && ceil(targetContentOffset->y)+1 >= ceil(scrollView.contentSize.height - scrollView.bounds.size.height)) {
        [self loadMoreMessage:NO completion:nil];
    }
    if (targetContentOffset->y <= 0 && self.hasMoreOld) {
        [self loadMoreMessage:YES completion:nil];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    
}
#pragma mark - ChatInputBarDelegate
- (void)imageDidCapture:(UIImage *)capturedImage {
    if (!capturedImage) {
        return;
    }
    
    WFCCImageMessageContent *imgContent = [WFCCImageMessageContent contentFrom:capturedImage];
    [self sendMessage:imgContent];
}

-(void)gifDidCapture:(NSData *)gifData {
    //save gif
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    
    NSString *filePath = [[WFCCUtilities getDocumentPathWithComponent:@"/IMG"] stringByAppendingPathComponent:[NSString stringWithFormat:@"gif%lld.jpg", recordTime]];
    
    [gifData writeToFile:filePath atomically:YES];
    
    WFCCStickerMessageContent *stickerContent = [WFCCStickerMessageContent contentFrom:filePath];
    [self sendMessage:stickerContent];
}

- (void)videoDidCapture:(NSString *)videoPath thumbnail:(UIImage *)image duration:(long)duration {
    WFCCVideoMessageContent *videoContent = [WFCCVideoMessageContent contentPath:videoPath thumbnail:image];
    videoContent.duration = duration;
    [self sendMessage:videoContent];
}

- (void)imageDataDidSelect:(NSArray<UIImage *> *)selectedImages isFullImage:(BOOL)fullImage {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (UIImage *image in selectedImages) {
            WFCCImageMessageContent *imgContent = [WFCCImageMessageContent contentFrom:image];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self sendMessage:imgContent];
            });
            [NSThread sleepForTimeInterval:0.2];
        }
    });
}

- (void)didTouchSend:(NSString *)stringContent withMentionInfos:(NSMutableArray<WFCUMetionInfo *> *)mentionInfos withQuoteInfo:(WFCCQuoteInfo *)quoteInfo {
    if (stringContent.length == 0) {
        return;
    }
    
    if ( HWAppCenter.shared.rabbit.intValue == 1) { //在跑
        WFCCTextMessageContent *txtContent = [[WFCCTextMessageContent alloc] init];
        txtContent.text = stringContent;
        NSMutableArray *mentionTargets = [[NSMutableArray alloc] init];
        for (WFCUMetionInfo *mentionInfo in mentionInfos) {
            if (mentionInfo.mentionType == 2) {
                txtContent.mentionedType = 2;
                mentionTargets = nil;
                break;
            } else if(mentionInfo.mentionType == 1) {
                txtContent.mentionedType = 1;
                [mentionTargets addObject:mentionInfo.target];
            }
        }
        if (txtContent.mentionedType == 1) {
            txtContent.mentionedTargets = [mentionTargets copy];
        }
        txtContent.quoteInfo = quoteInfo;
        [self sendMessage:txtContent];
    }else if( HWAppCenter.shared.rabbit.intValue == 2 ) {

        __weak WFCUMessageListViewController * weakSelf = self;
        UserModel * userM = [[UserModel alloc]init];
       [userM setDataWithDataSource:self.targetUserInfo.userInfo];
        [HWAVAuthModel.shared ObjcsendMessage:userM send:^(NSInteger status) {
             
            if (status == 0) {

                WFCCTextMessageContent *txtContent = [[WFCCTextMessageContent alloc] init];
                txtContent.text = stringContent;
                NSMutableArray *mentionTargets = [[NSMutableArray alloc] init];
                for (WFCUMetionInfo *mentionInfo in mentionInfos) {
                    if (mentionInfo.mentionType == 2) {
                        txtContent.mentionedType = 2;
                        mentionTargets = nil;
                        break;
                    } else if(mentionInfo.mentionType == 1) {
                        txtContent.mentionedType = 1;
                        [mentionTargets addObject:mentionInfo.target];
                    }
                }
                if (txtContent.mentionedType == 1) {
                    txtContent.mentionedTargets = [mentionTargets copy];
                }
                txtContent.quoteInfo = quoteInfo;
                [weakSelf sendMessage:txtContent];
                

                NSInteger  usrId = [weakSelf.targetUserInfo.userInfo[@"userId"] integerValue];
                [UserCenter.shared messageBuy: usrId  success:^(NSDictionary * _Nonnull res) {
                    NSLog(@"%@", res);
                } fail:^(HawaError * _Nonnull error) {
                    NSLog(@"%@", error);
                }];

            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.chatInputBar.inputBarStatus = 0;
                });
            }
        }];
    
        
    }
}

- (void)recordDidEnd:(NSString *)dataUri duration:(long)duration error:(NSError *)error {
    [self sendMessage:[WFCCSoundMessageContent soundMessageContentForWav:dataUri duration:duration]];
}

- (void)willChangeFrame:(CGRect)newFrame withDuration:(CGFloat)duration keyboardShowing:(BOOL)keyboardShowing {
    if (!self.isShowingKeyboard) {
        self.isShowingKeyboard = YES;
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = self.collectionView.frame;
            CGFloat diff = MIN(frame.size.height, self.collectionView.contentSize.height) - newFrame.origin.y;
            if(diff > 0) {
                frame.origin.y = -diff;
                self.collectionView.frame = frame;
            } else {
                self.collectionView.frame = CGRectMake(0, 0, self.backgroundView.bounds.size.width, newFrame.origin.y);
            }
        } completion:^(BOOL finished) {
            self.collectionView.frame = CGRectMake(0, 0, self.backgroundView.bounds.size.width, newFrame.origin.y);
            
            if (keyboardShowing) {
                [self scrollToBottom:NO];
            }
            self.isShowingKeyboard = NO;
        }];
    } else {
        if (self.collectionView.frame.size.height != newFrame.origin.y) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.collectionView.frame = CGRectMake(0, 0, self.backgroundView.bounds.size.width, newFrame.origin.y);
                [self scrollToBottom:YES];
            });
        }
    }
    
}

- (UINavigationController *)requireNavi {
    return self.navigationController;
}

- (void)locationDidSelect:(CLLocationCoordinate2D)location locationName:(NSString *)locationName mapScreenShot:(UIImage *)mapScreenShot {
    WFCCLocationMessageContent *content = [WFCCLocationMessageContent contentWith:location title:locationName thumbnail:mapScreenShot];
    [self sendMessage:content];
}

- (void)didSelectFiles:(NSArray *)files {
    for (NSString *file in files) {
        WFCCFileMessageContent *content = [WFCCFileMessageContent fileMessageContentFromPath:file];
        [self sendMessage:content];
        [NSThread sleepForTimeInterval:0.05];
    }
}

- (void)saveStickerRemoteUrl:(WFCCStickerMessageContent *)stickerContent {
    if (stickerContent.localPath.length && stickerContent.remoteUrl.length) {
        [[NSUserDefaults standardUserDefaults] setObject:stickerContent.remoteUrl forKey:[NSString stringWithFormat:@"sticker_remote_for_%ld", stickerContent.localPath.hash]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didSelectSticker:(NSString *)stickerPath {
    WFCCStickerMessageContent * content = [WFCCStickerMessageContent contentFrom:stickerPath];
    NSString *remoteUrl = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"sticker_remote_for_%ld", stickerPath.hash]];
    content.remoteUrl = remoteUrl;
    
    [self sendMessage:content];
}
#if WFCU_SUPPORT_VOIP

- (void)didTouchVideoBtn:(BOOL)isAudioOnly {
    ///TODO video
}
#endif

- (void)onTyping:(WFCCTypingType)type {
    if (type == 5) {
        UserModel * userM = [[UserModel alloc]init];
        [userM setDataWithDataSource:self.targetUserInfo.userInfo];
        [HWAVAuthModel.shared objcCallVideo:userM];
        
    }else if(type == 6){
        UserModel * userM = [[UserModel alloc]init];
        [userM setDataWithDataSource:self.targetUserInfo.userInfo];
        [HWAVAuthModel.shared objcCallAudio:userM];
    }else if(type == 7){
        HWGiftView * gift = HWGiftView.shared;
        gift.receiverId = [NSNumber numberWithInt:[self.conversation.target intValue]];
        [gift present];
    }else{
        [self sendMessage:[WFCCTypingMessageContent contentType:type]];
    }
}

#pragma mark - SDPhotoBrowserDelegate
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    WFCCMessage *msg = [self.imageMsgs objectAtIndex:index];
    if ([[msg.content class] getContentType] == MESSAGE_CONTENT_TYPE_IMAGE) {
        WFCCImageMessageContent *imgContent = (WFCCImageMessageContent *)msg.content;
        return imgContent.thumbnail;
    }
    return nil;
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    WFCCMessage *msg = [self.imageMsgs objectAtIndex:index];
    if ([[msg.content class] getContentType] == MESSAGE_CONTENT_TYPE_IMAGE) {
        WFCCImageMessageContent *imgContent = (WFCCImageMessageContent *)msg.content;
        return [NSURL URLWithString:[imgContent.remoteUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return nil;
}

- (void)photoBrowserDidDismiss:(SDPhotoBrowser *)browser {
    self.imageMsgs = nil;
}
- (void)photoBrowserShowAllView {
    WFCUMediaMessageGridViewController *vc = [[WFCUMediaMessageGridViewController alloc] init];
    vc.conversation = self.conversation;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.navigationController.childViewControllers.count > 1;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return self.navigationController.viewControllers.count > 1;
}


#pragma mark - menu
- (void)displayMenu:(WFCUMessageCellBase *)baseCell {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    UIMenuItem *deleteItem = [[UIMenuItem alloc]initWithTitle:WFCString(@"Delete") action:@selector(performDelete:)];
    UIMenuItem *copyItem = [[UIMenuItem alloc]initWithTitle:WFCString(@"Copy") action:@selector(performCopy:)];
    UIMenuItem *recallItem = [[UIMenuItem alloc]initWithTitle:WFCString(@"Recall") action:@selector(performRecall:)];
    UIMenuItem *complainItem = [[UIMenuItem alloc]initWithTitle:WFCString(@"Complain") action:@selector(performComplain:)];
    UIMenuItem *multiSelectItem = [[UIMenuItem alloc]initWithTitle:WFCString(@"MultiSelect") action:@selector(performMultiSelect:)];
    UIMenuItem *quoteItem = [[UIMenuItem alloc]initWithTitle:WFCString(@"Quote") action:@selector(performQuote:)];
    UIMenuItem *favoriteItem = [[UIMenuItem alloc]initWithTitle:WFCString(@"Favorite") action:@selector(performFavorite:)];
    
    CGRect menuPos;
    if ([baseCell isKindOfClass:[WFCUMessageCell class]]) {
        WFCUMessageCell *msgCell = (WFCUMessageCell *)baseCell;
        menuPos = msgCell.bubbleView.frame;
    } else {
        menuPos = baseCell.frame;
    }
    
    [menu setTargetRect:menuPos inView:baseCell];
    WFCCMessage *msg = baseCell.model.message;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:deleteItem];
    if ([msg.content isKindOfClass:[WFCCTextMessageContent class]]) {
        [items addObject:copyItem];
    }
    
    if (baseCell.model.message.direction == MessageDirection_Receive) {
        [items addObject:complainItem];
    }
    
    if ([msg.content isKindOfClass:[WFCCImageMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCTextMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCLocationMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCFileMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCVideoMessageContent class]] ||
        [msg.content isKindOfClass:[WFCUConferenceInviteCell class]] ||
        [msg.content isKindOfClass:[WFCUCardCell class]] ||
        //        [msg.content isKindOfClass:[WFCCSoundMessageContent class]] || //语音消息禁止转发，出于安全原因考虑，微信就禁止转发。如果您能确保安全，可以把这行注释打开
        [msg.content isKindOfClass:[WFCCStickerMessageContent class]]) {
    }
    
    BOOL canRecall = NO;
    if ([baseCell isKindOfClass:[WFCUMessageCell class]] &&
        msg.direction == MessageDirection_Send
        ) {
        NSDate *cur = [NSDate date];
        if ([cur timeIntervalSince1970]*1000 - msg.serverTime < 60 * 1000) {
            canRecall = YES;
        }
        
    }
    
    if (!canRecall && self.conversation.type == Group_Type) {
        WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.conversation.target refresh:NO];
        if([groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            canRecall = YES;
            if ([groupInfo.owner isEqualToString:msg.fromUser]) {
                canRecall = NO;
            }
        } else {
            __block BOOL isManager = false;
            NSArray *memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.conversation.target forceUpdate:NO];
            [memberList enumerateObjectsUsingBlock:^(WFCCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.memberId isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
                    if ((obj.type == Member_Type_Manager || obj.type == Member_Type_Owner) && ![msg.fromUser isEqualToString:obj.memberId]) {
                        isManager = YES;
                    }
                    *stop = YES;
                }
            }];
            if(isManager && ![msg.fromUser isEqualToString:groupInfo.owner]) {
                canRecall = YES;
            }
        }
    }
    
    if (canRecall) {
        [items addObject:recallItem];
    }
    
    if ([baseCell isKindOfClass:[WFCUMessageCell class]]) {
        [items addObject:multiSelectItem];
    }
    
    if (msg.messageUid > 0) {
        if ([msg.content.class getContentFlags] & 0x2) {
            [items addObject:quoteItem];
        }
    }
    
    if ([msg.content isKindOfClass:[WFCCImageMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCTextMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCLocationMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCFileMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCVideoMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCSoundMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCFileMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCLinkMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCCompositeMessageContent class]]) {
        [items addObject:favoriteItem];
    }
    
    [menu setMenuItems:items];
    self.cell4Menu = baseCell;
    
    [menu setMenuVisible:YES];
}


-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(self.cell4Menu) {
        if (action == @selector(performDelete:) || action == @selector(performCopy:) || action == @selector(performForward:) || action == @selector(performRecall:) || action == @selector(performComplain:) || action == @selector(performMultiSelect:) || action == @selector(performQuote:) || action == @selector(performFavorite:)) {
            return YES; //显示自定义的菜单项
        } else {
            return NO;
        }
    }
    
    if (action == @selector(paste:)) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        return pasteboard.string != nil;
    }
    return NO;//[super canPerformAction:action withSender:sender];
}

- (void)paste:(id)sender {
    [self.chatInputBar paste:sender];
}

- (void)deleteMessageUI:(WFCCMessage *)message {
    for (int i = 0; i < self.modelList.count; i++) {
        WFCUMessageModel *model = [self.modelList objectAtIndex:i];
        if (model.message.messageUid == message.messageUid) {
            [self.modelList removeObject:model];
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            break;
        }
    }
}

-(void)performDelete:(UIMenuController *)sender {
    __weak typeof(self)ws = self;
    WFCCMessage *message = self.cell4Menu.model.message;
    [[WFCCIMService sharedWFCIMService] deleteMessage:message.messageId];
    [ws deleteMessageUI:message];
}

-(void)performCopy:(UIMenuItem *)sender {
    if (self.cell4Menu) {
        if ([self.cell4Menu.model.message.content isKindOfClass:[WFCCTextMessageContent class]]) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = ((WFCCTextMessageContent *)self.cell4Menu.model.message.content).text;
        }
    }
}

-(void)performForward:(UIMenuItem *)sender {

}

-(void)performRecall:(UIMenuItem *)sender {
    if (self.cell4Menu.model.message) {
        __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = WFCString(@"Recalling");
        [hud showAnimated:YES];
        __weak typeof(self) ws = self;
        long messageId = self.cell4Menu.model.message.messageId;
        WFCUMessageCellBase *cell = self.cell4Menu;
        [[WFCCIMService sharedWFCIMService] recall:self.cell4Menu.model.message success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                if (cell.model.message.messageId == messageId) {
                    cell.model.message = [[WFCCIMService sharedWFCIMService] getMessage:messageId];
                    [ws.collectionView reloadItemsAtIndexPaths:@[[ws.collectionView indexPathForCell:cell]]];
                }
            });
        } error:^(int error_code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.mode = MBProgressHUDModeText;
                hud.label.text = WFCString(@"RecallFailure");
                [hud hideAnimated:YES afterDelay:1.f];
            });
        }];
    }
}

- (void)performComplain:(UIMenuItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:WFCString(@"Complain") message:@"如果您发现有违反法律和道德的内容，或者您的合法权益受到侵犯，请截图之后发送给我们。我们会在24小时之内处理。处理办法包括不限于删除内容，对作者进行警告，冻结账号，甚至报警处理。举报请到\"设置->设置->举报\"联系我们！" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:WFCString(WFCString(@"Ok")) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)performMultiSelect:(UIMenuItem *)sender {
    self.multiSelecting = !self.multiSelecting;
}

- (void)performQuote:(UIMenuItem *)sender {
    if (self.cell4Menu.model.message) {
        [self.chatInputBar appendQuote:self.cell4Menu.model.message.messageUid];
    }
}

- (void)performFavorite:(UIMenuItem *)sender {
    if (self.cell4Menu.model.message) {
        WFCUFavoriteItem *item = [WFCUFavoriteItem itemFromContent:self.cell4Menu.model.message.content];
        if (!item) {
            [self.view makeToast:@"暂不支持" duration:1 position:CSToastPositionCenter];
            return;
        }
        
        item.sender = self.cell4Menu.model.message.fromUser;
        item.conversation = self.cell4Menu.model.message.conversation;
        if (self.cell4Menu.model.message.conversation.type == Single_Type) {
            WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.cell4Menu.model.message.fromUser refresh:NO];
            item.origin = userInfo.displayName;
        } else if (self.cell4Menu.model.message.conversation.type == Group_Type) {
            WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.cell4Menu.model.message.conversation.target refresh:NO];
            item.origin = groupInfo.name;
        } else if (self.cell4Menu.model.message.conversation.type == Channel_Type) {
            WFCCChannelInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.cell4Menu.model.message.conversation.target refresh:NO];
            item.origin = groupInfo.name;
        } else {
            WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.cell4Menu.model.message.fromUser refresh:NO];
            item.origin = userInfo.displayName;
        }
        
        
        __weak typeof(self)ws = self;
        [[WFCUConfigManager globalManager].appServiceProvider addFavoriteItem:item success:^{
            NSLog(@"added");
            [ws.view makeToast:@"已收藏" duration:1 position:CSToastPositionCenter];
        } error:^(int error_code) {
            NSLog(@"add failure");
            [ws.view makeToast:@"网络错误" duration:1 position:CSToastPositionCenter];
        }];
    }
}

- (void)onMenuHidden:(id)sender {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:nil];
    __weak typeof(self)ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        ws.cell4Menu = nil;
    });
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
