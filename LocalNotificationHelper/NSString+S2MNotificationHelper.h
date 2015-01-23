//
//  NSString+S2MNotificationHelper.h
//  S2MToolbox
//
//  Created by ParkSanggeon on 22/01/15.
//  Copyright (c) 2015 S2M. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (S2MNotificationHelper)

/**
 * you can create string with format and given array.
 * @param format pass format like following @"%@, %@, %@"
 * @param arguments pass array of elements (ex : @[@(10), @"test", [NSDate date]])
 *
 * @return NSString Object
 */
+ (instancetype)s2m_stringWithFormat:(NSString *)format arguments:(NSArray*)arguments;
- (NSString *)s2m_hashString; // get Hash string with md5

@end
