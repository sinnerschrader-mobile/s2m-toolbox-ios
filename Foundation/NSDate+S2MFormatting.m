//
//  NSDate+S2MFormatting.m
//  Pods
//
//  Created by Andreas Buff on 26/05/14.
//
//

#import "NSDate+S2MFormatting.h"

@implementation NSDate (S2MFormatting)

- (NSString *)toStringWithFormat:(NSString *)aFormat
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:aFormat];
    return [dateFormatter stringFromDate:self];
}

@end
