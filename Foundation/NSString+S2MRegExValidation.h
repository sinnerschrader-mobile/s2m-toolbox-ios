//
//  NSString+S2MRegExValidation.h
//  S2MToolbox
//
//  Created by MetaJSONParser.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (S2MRegExValidation)

+ (void)s2m_setEmailFormat:(NSString *)emailFormat;

- (NSUInteger)s2m_numberOfMatchesWithRegExString:(NSString *)regExString;

- (BOOL)s2m_matchesRegExString:(NSString *)regExString;

- (BOOL)s2m_isValidEmailFormatString;
@end
