//
//  NSMutableArray+S2MReverse.h
//  MoreMobile
//
//  Created by Andreas Buff on 26/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (S2MReverse)


/**
 *  Inverts the order of the contained elements.
 
 From: http://stackoverflow.com/questions/586370/how-can-i-reverse-a-nsarray-in-objective-c
 
 Example:
    Before: 12345
    After:  54321
 
 */
- (void)reverse;

@end
