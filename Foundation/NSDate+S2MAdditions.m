//
//  NSDate+S2MAdditions.m
//  MoreMobile
//
//  Created by Andreas Buff on 26/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "NSDate+S2MAdditions.h"

@implementation NSDate (S2MAdditions)

+ (instancetype)s2m_dateFromString:(NSString *)dateString
                        dateFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:dateString];
}

- (BOOL)s2m_inPast
{
    return [self timeIntervalSinceNow] < 0;
}

- (BOOL)s2m_inFuture
{
    return [self timeIntervalSinceNow] > 0;
}

- (NSString *)s2m_toStringWithFormat:(NSString *)aFormat
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:aFormat];
    return [dateFormatter stringFromDate:self];
}

- (NSDate *)s2m_beginningOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Get the weekday component of the current date
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
											   fromDate:self];
	return [calendar dateFromComponents:components];
}

- (NSDate *)s2m_beginningOfMonth
{
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    NSDateComponents * currentDateComponents = [calendar components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDate * startOfMonth = [calendar dateFromComponents: currentDateComponents];
    
    return startOfMonth;
}

- (NSDate *)s2m_endOfMonth
{
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    NSDate* plusOneMonthDate = [self s2m_dateByAddingMonths: 1];
    NSDateComponents * plusOneMonthDateComponents = [calendar components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate: plusOneMonthDate];
    NSDate* endOfMonth = [[calendar dateFromComponents: plusOneMonthDateComponents] dateByAddingTimeInterval:-1]; // One second before the start of next month
    
    return endOfMonth;
}

- (NSDate *)s2m_dateByAddingMonths:(NSInteger)monthsToAdd
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* months = [[NSDateComponents alloc] init];
    [months setMonth:monthsToAdd];
    
    return [calendar dateByAddingComponents:months toDate:self options:0];
}

@end
