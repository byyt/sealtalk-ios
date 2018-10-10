//
//  RCWKAppInfoProvider.h
//  YunChuang
//
//  Created by litao on 15/5/11.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef YunChuang_RCWKAppInfoProvider_h
#define YunChuang_RCWKAppInfoProvider_h

@protocol RCWKAppInfoProvider
- (NSString *)getAppName;
- (NSString *)getAppGroups;
- (NSArray *)getAllUserInfo;
- (NSArray *)getAllGroupInfo;
- (NSArray *)getAllFriends;
- (void)openParentApp;
- (BOOL)getNewMessageNotificationSound;
- (void)setNewMessageNotificationSound:(BOOL)on;
- (void)logout;
- (BOOL)getLoginStatus;
@end

#endif
