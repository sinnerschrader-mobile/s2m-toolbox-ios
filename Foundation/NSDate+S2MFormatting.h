//
//  NSDate+S2MFormatting.h
//  Pods
//
//  Created by Andreas Buff on 26/05/14.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (S2MFormatting)

/**
 *  Returns the string representation of the date in a given format. The format must meet Apple's Data Formatting Criteria:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/DataFormatting/DataFormatting.html#//apple_ref/doc/uid/10000029i
 *
 *  Example format: "dd.MM.yyyy"
 *  Output:         "23.12.1972"
 *
 *  @param aFormat format to format the string in
 *
 *  @return stzring representation
 */
- (NSString *)s2m_toStringWithFormat:(NSString *)aFormat;

@end
