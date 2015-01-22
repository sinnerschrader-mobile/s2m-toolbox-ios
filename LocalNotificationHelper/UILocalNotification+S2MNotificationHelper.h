//
//  UILocalNotification+S2MNotificationHelper.h
//  S2MLocalNotification
//
//  Created by ParkSanggeon on 21/01/15.
//  Copyright (c) 2015 S2M. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILocalNotification (S2MNotificationHelper)
- (void)setS2mKey:(NSString *)key;
- (NSString *)s2mKey;
@end
