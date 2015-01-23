//
//  S2MNotificationHelper.h
//  S2MToolbox
//
//  Created by ParkSanggeon on 21/01/15.
//  Copyright (c) 2015 S2M. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UILocalNotification+S2MNotificationHelper.h"

@interface S2MNotificationHelper : NSObject

/**
 * Converts Remote push notification payload to UILocalNotification
 *
 * @param key key for given notification to handle internally
 * @param userInfo given userInfo from remote notification.
 *
 * @return converted UILocalNotification object.
 */
+ (UILocalNotification *)localNotificationForKey:(NSString *)key userInfo:(NSDictionary *)userInfo;

/**
 * Present UILocalNotification on Notification Center
 *
 * @param notification it must have s2mKey value
 * (use setKey: in "UILocalNotification+S2MNotificationHelper.h")
 *
 * @return NO if notification is nil or if notification doesn't have key
 */
+ (BOOL)showNotification:(UILocalNotification *)notification;

/**
 * Present UILocalNotification on Notification Center
 *
 * @param notification UILocalNotification object
 * @param key key for given notification to handle internally
 *
 * @return NO if notification is nil or if key is zero length string (also nil)
 */
+ (BOOL)showNotification:(UILocalNotification *)notification withKey:(NSString *)key;

+ (BOOL)removeNotification:(UILocalNotification *)notification; /// returns NO if notification is nil or if notification doesn't have key.

+ (BOOL)removeNotificationForKey:(NSString *)key; /// returns NO if key is zero length string or nil).

+ (void)removeAllNotifications; /// remove all notification from Notification Center and cache.

+ (UILocalNotification *)notificationForKey:(NSString *)key; /// returns UILocalNotification for given key.

+ (NSArray *)allNotifications; /// returns array all cached Notifications

@end
