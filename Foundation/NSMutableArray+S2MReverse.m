//
//  NSMutableArray+S2MReverse.m
//  MoreMobile
//
//  Created by Andreas Buff on 26/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "NSMutableArray+S2MReverse.h"

@implementation NSMutableArray (S2MReverse)

- (void)reverse
{
    if ([self count] == 0) {
        return;
    }
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        i++;
        j--;
    }
}

@end
