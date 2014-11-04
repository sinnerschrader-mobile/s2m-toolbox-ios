//
//  NSDate+S2MAdditions.h
//  MoreMobile
//
//  Created by Andreas Buff on 26/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (S2MAdditions)

+ (instancetype)s2m_dateFromString:(NSString *)dateString
                        dateFormat:(NSString *)format;

/**
 *  Whether or not the date is before now.
 *
 *  @return YES, if timeinterval since now is negative;
            NO, otherwize
 */
- (BOOL)s2m_inPast;

/**
 *  Whether or not the date is after now.
 *
 *  @return YES, if timeinterval since now is positive, but not zero;
            NO, otherwize
 */
- (BOOL)s2m_inFuture;

/**
 *  Returns the string representation of the date in a given format.  *
 *  Example format: "dd.MM.yyyy"
 *  Output:         "23.12.1972"
 *
 *  @param aFormat format to format the string in
 *
 *  @return string representation
 *  @note The format must meet Apple's Data Formatting Criteria:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/DataFormatting/DataFormatting.html#//apple_ref/doc/uid/10000029i
 
 */
- (NSString *)s2m_toStringWithFormat:(NSString *)aFormat;

- (NSDate *)s2m_beginningOfDay;
- (NSDate *)s2m_beginningOfMonth;
- (NSDate *)s2m_endOfMonth;
- (NSDate *)s2m_dateByAddingMonths:(NSInteger)monthsToAdd;
@end
