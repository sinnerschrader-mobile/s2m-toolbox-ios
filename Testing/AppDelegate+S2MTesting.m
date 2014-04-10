//
//  AppDelegate+S2MTesting.m
//
//
//  Created by François Benaiteau on 10/22/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import "AppDelegate+S2MTesting.h"

#import <objc/runtime.h>

@implementation AppDelegate (S2MTesting)

+ (void)initialize
{
    SEL new = @selector(application:didFinishLaunchingWithOptions:);
    SEL orig = @selector(s2m_swizzledApplication:didFinishLaunchingWithOptions:);
    Class c = [self class];
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);

    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

- (BOOL)s2m_swizzledApplication:(id)app didFinishLaunchingWithOptions:(id)opts
{
    return YES;
}

@end
