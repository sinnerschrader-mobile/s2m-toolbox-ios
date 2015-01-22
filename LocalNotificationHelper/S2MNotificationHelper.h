//
//  S2MNotificationHelper.h
//  S2MLocalNotification
//
//  Created by ParkSanggeon on 21/01/15.
//  Copyright (c) 2015 S2M. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UILocalNotification+S2MNotificationHelper.h"

@interface S2MNotificationHelper : NSObject

+ (UILocalNotification *)localNotificationForKey:(NSString *)key userInfo:(NSDictionary *)userInfo;

// returns NO if notification is nil or if notification doesn't have key (user setKey: in "UILocalNotification+S2MNotificationHelper.h")
+ (BOOL)showNotification:(UILocalNotification *)notification;

// returns NO if notification is nil or if key is zero length string (also nil).
+ (BOOL)showNotification:(UILocalNotification *)notification withKey:(NSString *)key;

// returns NO if notification is nil or if notification doesn't have key
+ (BOOL)removeNotification:(UILocalNotification *)notification;

// returns NO if key is zero length string or nil).
+ (BOOL)removeNotificationForKey:(NSString *)key;

+ (void)removeAllNotifications;

+ (UILocalNotification *)notificationForKey:(NSString *)key;

+ (NSArray *)allNotifications;

@end
