//
//  UILocalNotification+S2MNotificationHelper.h
//  S2MToolbox
//
//  Created by ParkSanggeon on 21/01/15.
//  Copyright (c) 2015 S2M. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILocalNotification (S2MNotificationHelper)

- (void)setS2mKey:(NSString *)key; // set key for internal usage of S2MNotificationHelper. to use S2MNotificationHelper, it has to be used.
- (NSString *)s2mKey; // get key for internal usage of S2MNotificationHelper

@end
