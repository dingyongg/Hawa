//
//  ConversationTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUConversationTableViewController.h"
#import "WFCUConversationTableViewCell.h"

#import "WFCUMessageListViewController.h"
#import <WFChatClient/WFCChatClient.h>

#import "WFCUUtilities.h"
#import "UITabBar+badge.h"
#import "KxMenu.h"
#import "UIImage+ERCategory.h"
#import "MBProgressHUD.h"

#import "WFCUConfigManager.h"
#import "UIImage+ERCategory.h"
#import "UIFont+YH.h"
#import "UIColor+YH.h"
#import "UIView+Toast.h"
#import "WFUseInfo.h"

@interface WFCUConversationTableViewController () < UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray<WFCCConversationInfo *> *conversations;
@property (nonatomic, strong)NSMutableDictionary<NSString*, WFUseInfo *> *conversationUsersInfo;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *searchViewContainer;

@property (nonatomic, assign) BOOL firstAppear;

@property (nonatomic, strong) UIView *pcSessionView;
@end

@implementation WFCUConversationTableViewController
- (void)initSearchUIAndTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"expansion"];
    
    self.definesPresentationContext = YES;
    
    [self updatePcSession];
    self.view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
    
    WFCCUserInfo *userInfo = notification.userInfo[@"userInfo"];
    NSArray *dataSource = self.conversations;
    for (int i = 0; i < dataSource.count; i++) {
        WFCCConversationInfo *conv = dataSource[i];
        if (conv.conversation.type == Single_Type && [conv.conversation.target isEqualToString:userInfo.userId]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        } else if ([conv.lastMessage.fromUser isEqualToString:userInfo.userId]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}

- (void)onGroupInfoUpdated:(NSNotification *)notification {
    
    WFCCGroupInfo *groupInfo = notification.userInfo[@"groupInfo"];
    NSArray *dataSource = self.conversations;
    
    for (int i = 0; i < dataSource.count; i++) {
        WFCCConversationInfo *conv = dataSource[i];
        if (conv.conversation.type == Group_Type && [conv.conversation.target isEqualToString:groupInfo.target]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}

- (void)onChannelInfoUpdated:(NSNotification *)notification {
    
    WFCCChannelInfo *channelInfo = notification.userInfo[@"groupInfo"];
    NSArray *dataSource = self.conversations;
    
    
    for (int i = 0; i < dataSource.count; i++) {
        WFCCConversationInfo *conv = dataSource[i];
        if (conv.conversation.type == Channel_Type && [conv.conversation.target isEqualToString:channelInfo.channelId]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}

- (void)onSendingMessageStatusUpdated:(NSNotification *)notification {
    
    long messageId = [notification.object longValue];
    NSArray *dataSource = self.conversations;
    
    if (messageId == 0) {
        return;
    }
    
    for (int i = 0; i < dataSource.count; i++) {
        WFCCConversationInfo *conv = dataSource[i];
        if (conv.lastMessage && conv.lastMessage.direction == MessageDirection_Send && conv.lastMessage.messageId == messageId) {
            conv.lastMessage = [[WFCCIMService sharedWFCIMService] getMessage:messageId];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}

#if WFCU_GROUP_GRID_PORTRAIT
- (void)createGroup:(NSArray<NSString *> *)contacts {
    __weak typeof(self) ws = self;
    NSMutableArray<NSString *> *memberIds = [contacts mutableCopy];
    if (![memberIds containsObject:[WFCCNetworkService sharedInstance].userId]) {
        [memberIds insertObject:[WFCCNetworkService sharedInstance].userId atIndex:0];
    }
    
    NSString *name;
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[memberIds objectAtIndex:0]  refresh:NO];
    name = userInfo.displayName;
    
    for (int i = 1; i < MIN(8, memberIds.count); i++) {
        userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[memberIds objectAtIndex:i]  refresh:NO];
        if (userInfo.displayName.length > 0) {
            if (name.length + userInfo.displayName.length + 1 > 16) {
                name = [name stringByAppendingString:WFCString(@"Etc")];
                break;
            }
            name = [name stringByAppendingFormat:@",%@", userInfo.displayName];
        }
    }
    if (name.length == 0) {
        name = WFCString(@"GroupChat");
    }
    
    [[WFCCIMService sharedWFCIMService] createGroup:nil name:name portrait:nil type:GroupType_Restricted members:memberIds notifyLines:@[@(0)] notifyContent:nil success:^(NSString *groupId) {
        NSLog(@"create group success");
        
        WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
        mvc.conversation = [[WFCCConversation alloc] init];
        mvc.conversation.type = Group_Type;
        mvc.conversation.target = groupId;
        mvc.conversation.line = 0;
        
        mvc.hidesBottomBarWhenPushed = YES;
        [ws.navigationController pushViewController:mvc animated:YES];
    } error:^(int error_code) {
        NSLog(@"create group failure");
        [ws.view makeToast:WFCString(@"CreateGroupFailure")
                  duration:2
                  position:CSToastPositionCenter];
        
    }];
}
#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    self.conversations = [[NSMutableArray alloc] init];
    self.conversationUsersInfo = [[NSMutableDictionary alloc] init];
    
    [self initSearchUIAndTableView];
    self.definesPresentationContext = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClearAllUnread:) name:@"kTabBarClearBadgeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelInfoUpdated:) name:kChannelInfoUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendingMessageStatusUpdated:) name:kSendingMessageStatusUpdated object:nil];
    
    self.firstAppear = YES;
}

- (void)updateConnectionStatus:(ConnectionStatus)status {
    [self updateTitle];
}

- (void)updateTitle {
    UIView *title;
    ConnectionStatus status = [WFCCNetworkService sharedInstance].currentConnectionStatus;
    if (status != kConnectionStatusConnecting && status != kConnectionStatusReceiving) {
        UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 40, 0, 80, 44)];
        
        switch (status) {
            case kConnectionStatusLogout:
                navLabel.text = WFCString(@"NotLogin");
                break;
            case kConnectionStatusUnconnected:
                navLabel.text = WFCString(@"NotConnect");
                break;
            case kConnectionStatusConnected: {
                int count = 0;
                for (WFCCConversationInfo *info in self.conversations) {
                    if (!info.isSilent) {
                        count += info.unreadCount.unread;
                    }
                }
                
                navLabel.text = WFCString(@"News");
                
            }
                break;
                
            default:
                break;
        }
        
        navLabel.textColor = [WFCUConfigManager globalManager].naviTextColor;
        navLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
        
        navLabel.textAlignment = NSTextAlignmentCenter;
        title = navLabel;
    } else {
        UIView *continer = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 60, 0, 120, 44)];
        UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 2, 80, 40)];
        if (status == kConnectionStatusConnecting) {
            navLabel.text = WFCString(@"Connecting");
        } else {
            navLabel.text = WFCString(@"Synching");
        }
        
        navLabel.textColor = [WFCUConfigManager globalManager].naviTextColor;
        navLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
        [continer addSubview:navLabel];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.center = CGPointMake(20, 21);
        [indicatorView startAnimating];
        indicatorView.color = [WFCUConfigManager globalManager].naviTextColor;
        [continer addSubview:indicatorView];
        title = continer;
    }
    self.navigationItem.titleView = title;
}
- (void)onConnectionStatusChanged:(NSNotification *)notification {
    ConnectionStatus status = [notification.object intValue];
    [self updateConnectionStatus:status];
}

- (void)onReceiveMessages:(NSNotification *)notification {
    NSArray<WFCCMessage *> *messages = notification.object;
    if ([messages count]) {
        [self refreshList];
        [self refreshLeftButton];
    }
}

- (void)onSettingUpdated:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshList];
        [self refreshLeftButton];
        [self updatePcSession];
    });
}

- (void)onRecallMessages:(NSNotification *)notification {
    [self refreshList];
    [self refreshLeftButton];
}

- (void)onDeleteMessages:(NSNotification *)notification {
    [self refreshList];
    [self refreshLeftButton];
}


- (void)onClearAllUnread:(NSNotification *)notification {
    if ([notification.object intValue] == 0) {
        [[WFCCIMService sharedWFCIMService] clearAllUnreadStatus];
        [self refreshList];
        [self refreshLeftButton];
    }
}

- (void)refreshList {
    self.conversations = [[[WFCCIMService sharedWFCIMService] getConversationInfos:@[@(Single_Type)] lines:@[@(0)]] mutableCopy];
    
    for (WFCCConversationInfo * conInfo in self.conversations) {
        
        WFUseInfo * userInfo = self.conversationUsersInfo[conInfo.conversation.target];
        if (!userInfo) {
            WFUseInfo * newUserInfo = [[WFUseInfo alloc]init];
            newUserInfo.userId = conInfo.conversation.target;
            [self.conversationUsersInfo setValue:newUserInfo forKey:conInfo.conversation.target];
        }
    }
    
    [self updateBadgeNumber];
    [self.tableView reloadData];
}

- (void)updateBadgeNumber {
    int count = 0;
    for (WFCCConversationInfo *info in self.conversations) {
        if (!info.isSilent) {
            count += info.unreadCount.unread;
        }
    }
    
    if (count > 0) {
        [self.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d", count]];
    }else{
        [self.tabBarItem setBadgeValue:nil];
    }
    [self updateTitle];
}

- (void)updatePcSession {
    NSArray<WFCCPCOnlineInfo *> *onlines = [[WFCCIMService sharedWFCIMService] getPCOnlineInfos];
    
    if (@available(iOS 11.0, *)) {
        if (onlines.count) {
            self.tableView.tableHeaderView = self.pcSessionView;
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"wfc_uikit_had_pc_session"]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wfc_uikit_had_pc_session"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            self.tableView.tableHeaderView = nil;
        }
    } else {
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self refreshLeftButton];
    
    if ([KxMenu isShowing]) {
        [KxMenu dismissMenu];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.firstAppear) {
        self.firstAppear = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionStatusChanged:) name:kConnectionStatusChanged object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessages:) name:kReceiveMessages object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecallMessages:) name:kRecallMessages object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeleteMessages:) name:kDeleteMessages object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSettingUpdated:) name:kSettingUpdated object:nil];
    }
    
    [self updateConnectionStatus:[WFCCNetworkService sharedInstance].currentConnectionStatus];
    [self refreshList];
    [self refreshLeftButton];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self.tableView reloadData];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)refreshLeftButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        WFCCUnreadCount *unreadCount = [[WFCCIMService sharedWFCIMService] getUnreadCount:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0)]];
        NSUInteger count = unreadCount.unread;
        
        NSString *title = nil;
        if (count > 0 && count < 1000) {
            title = [NSString stringWithFormat:WFCString(@"BackNumber"), count];
        } else if (count >= 1000) {
            title = WFCString(@"BackMore");
        } else {
            title = WFCString(@"Back");
        }
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
        item.title = title;
        
        self.navigationItem.backBarButtonItem = item;
    });
}

- (UIView *)pcSessionView {
    if (!_pcSessionView) {
        BOOL darkMode = NO;
        if (@available(iOS 13.0, *)) {
            if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                darkMode = YES;
            }
        }
        UIColor *bgColor;
        if (darkMode) {
            bgColor = [WFCUConfigManager globalManager].backgroudColor;
        } else {
            bgColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.f];
        }
        
        _pcSessionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        [_pcSessionView setBackgroundColor:bgColor];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 4, 32, 32)];
        iv.image = [UIImage imageNamed:@"pc_session"];
        [_pcSessionView addSubview:iv];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(68, 10, 100, 20)];
        NSArray<WFCCPCOnlineInfo *> *infos = [[WFCCIMService sharedWFCIMService] getPCOnlineInfos];
        if (infos.count) {
            if (infos[0].platform == PlatformType_Windows) {
                label.text = @"Windows 已登录";
            } else if(infos[0].platform == PlatformType_OSX) {
                label.text = @"Mac 已登录";
            } else if(infos[0].platform == PlatformType_Linux) {
                label.text = @"Linux 已登录";
            } else if(infos[0].platform == PlatformType_WEB) {
                label.text = @"Web 已登录";
            } else if(infos[0].platform == PlatformType_WX) {
                label.text = @"小程序已登录";
            }
        }
        
        [_pcSessionView addSubview:label];
        _pcSessionView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapPCBar:)];
        [_pcSessionView addGestureRecognizer:tap];
    }
    return _pcSessionView;
}

- (void)onTapPCBar:(id)sender {
    NSArray<WFCCPCOnlineInfo *> *onlines = [[WFCCIMService sharedWFCIMService] getPCOnlineInfos];
    if ([[WFCUConfigManager globalManager].appServiceProvider respondsToSelector:@selector(showPCSessionViewController:pcClient:)]) {
        [[WFCUConfigManager globalManager].appServiceProvider showPCSessionViewController:self pcClient:[onlines objectAtIndex:0]];
    }
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.conversations.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WFCUConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationCell"];
    if (cell == nil) {
        cell = [[WFCUConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"conversationCell"];
    }
    cell.big = YES;
    cell.separatorInset = UIEdgeInsetsMake(0, 76, 0, 0);
    cell.info = self.conversations[indexPath.row];
    cell.userInfo =  self.conversationUsersInfo[cell.info.conversation.target];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) ws = self;
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:WFCString(@"Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[WFCCIMService sharedWFCIMService] clearUnreadStatus:ws.conversations[indexPath.row].conversation];
        [[WFCCIMService sharedWFCIMService] removeConversation:ws.conversations[indexPath.row].conversation clearMessage:YES];
        [ws.conversations removeObjectAtIndex:indexPath.row];
        [ws updateBadgeNumber];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    UITableViewRowAction *setTop = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:WFCString(@"Pinned") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[WFCCIMService sharedWFCIMService] setConversation:ws.conversations[indexPath.row].conversation top:YES success:^{
            [ws refreshList];
        } error:^(int error_code) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:NO];
            hud.label.text = WFCString(@"UpdateFailure");
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
        }];
    }];
    
    UITableViewRowAction *setUntop = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:WFCString(@"Unpinned") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[WFCCIMService sharedWFCIMService] setConversation:ws.conversations[indexPath.row].conversation top:NO success:^{
            [ws refreshList];
        } error:^(int error_code) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:NO];
            hud.label.text = WFCString(@"UpdateFailure");
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
        }];
        
        [self refreshList];
    }];
    
    setTop.backgroundColor = [UIColor purpleColor];
    setUntop.backgroundColor = [UIColor orangeColor];
    
    return  @[delete];
};


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
    WFCCConversationInfo *info = self.conversations[indexPath.row];
    mvc.conversation = info.conversation;
    mvc.hidesBottomBarWhenPushed = YES;
    mvc.targetUserInfo = self.conversationUsersInfo[info.conversation.target];
    [self.navigationController pushViewController:mvc animated:YES];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
