//
//  AppDelegate+S2MTesting.h
//
//
//  Created by François Benaiteau on 10/22/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (S2MTesting)
// see http://stackoverflow.com/questions/7274711/run-logic-tests-in-xcode-4-without-launching-the-simulator
// skips the appDelegate didFinishLaunching method in order not to mess with the environment of tests
@end
