//
//  KWSpec+S2MWaitFor.h
//  S2MToolbox
//
//  Created by François Benaiteau on 4/25/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//
// Snippet from http://blog.carbonfive.com/2012/07/11/ios-integration-tests-with-kiwi/
#import "KWSpec.h"

@interface KWSpec (S2MWaitFor)
+ (void)s2m_waitWithTimeout:(NSTimeInterval)timeout forCondition:(BOOL(^)())conditionalBlock;
@end
