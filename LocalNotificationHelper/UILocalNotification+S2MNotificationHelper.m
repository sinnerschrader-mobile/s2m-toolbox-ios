//
//  UILocalNotification+S2MNotificationHelper.m
//  S2MLocalNotification
//
//  Created by ParkSanggeon on 21/01/15.
//  Copyright (c) 2015 S2M. All rights reserved.
//

#import "UILocalNotification+S2MNotificationHelper.h"

static NSString* const kLocalNotificationHelperKey = @"S2M_LOCALNOTIFICATION_HELPER_KEY";

@implementation UILocalNotification (S2MNotificationHelper)

- (void)setS2mKey:(NSString *)key
{
    NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    [newUserInfo setObject:key forKey:kLocalNotificationHelperKey];
    self.userInfo = newUserInfo;
}
- (NSString *)s2mKey
{
    return [self.userInfo objectForKey:kLocalNotificationHelperKey];
}

@end
