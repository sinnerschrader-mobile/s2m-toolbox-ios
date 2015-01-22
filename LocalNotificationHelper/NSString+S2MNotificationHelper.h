//
//  NSString+S2MNotificationHelper.h
//  S2MLocalNotification
//
//  Created by ParkSanggeon on 22/01/15.
//  Copyright (c) 2015 S2M. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (S2MNotificationHelper)

+ (instancetype)s2m_stringWithFormat:(NSString *)format array:(NSArray*)arguments;
- (NSString *)s2m_hashString;

@end
