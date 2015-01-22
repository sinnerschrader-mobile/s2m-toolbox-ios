//
//  UILocalNotification+S2MNotificationHelper.m
//  S2MLocalNotification
//
//  Created by ParkSanggeon on 21/01/15.
//  Copyright (c) 2015 S2M. All rights reserved.
//

#import "UILocalNotification+S2MNotificationHelper.h"

#define LOCALNOTIFICATION_HELPER_KEY @"S2M_LOCALNOTIFICATION_HELPER_KEY"

@implementation UILocalNotification (S2MNotificationHelper)

- (void)setS2mKey:(NSString *)key
{
    NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    [newUserInfo setObject:key forKey:LOCALNOTIFICATION_HELPER_KEY];
    self.userInfo = newUserInfo;
}
- (NSString *)s2mKey
{
    return [self.userInfo objectForKey:LOCALNOTIFICATION_HELPER_KEY];
}

@end
