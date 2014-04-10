//
//  KWSpec+S2MWaitFor.m
//
//
//  Created by François Benaiteau on 4/25/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import "KWSpec+S2MWaitFor.h"

@implementation KWSpec (S2MWaitFor)

+ (void)s2m_waitWithTimeout:(NSTimeInterval)timeout forCondition:(BOOL(^)())conditionalBlock
{
    NSDate *timeoutDate = [[NSDate alloc] initWithTimeIntervalSinceNow:timeout];
    while (conditionalBlock() == NO) {
        if ([timeoutDate timeIntervalSinceDate:[NSDate date]] < 0) {
            return;
        }
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}


@end
