//
//  NSString+S2MRegExValidation.h
//
//  Created by MetaJSONParser.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.

#import <Foundation/Foundation.h>

@interface NSString (S2MRegExValidation)

#ifndef s2m_emailRegex
#define s2m_emailRegex @"^[_a-z0-9-]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9-]+)*(\\.[a-z]{2,4})$"
#endif

- (NSUInteger)s2m_numberOfMatchesWithRegExString:(NSString *)regExString;

- (BOOL)s2m_matchesRegExString:(NSString *)regExString;

- (BOOL)s2m_isValidEmailFormatString;
@end
