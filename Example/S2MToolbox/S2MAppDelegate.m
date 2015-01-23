//
//  S2MAppDelegate.m
//  S2MToolbox
//
//  Created by François Benaiteau on 27/10/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MAppDelegate.h"

#import "StartViewController.h"
#import <S2MToolbox/S2MHockeyHandler.h>

@interface S2MAppDelegate ()

@property (strong, nonatomic) S2MHockeyHandler* hockeyHandler;

@end

@implementation S2MAppDelegate

static BOOL isRunningTests(void) __attribute__((const));

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (isRunningTests()) {
        return YES;
    }
    NSLog(@"appDelegate didFinishLaunchingWithOptions!");

    self.hockeyHandler = [[S2MHockeyHandler alloc] init];
    [self.hockeyHandler setCrashManagerdDidFinishBlock:^(NSError * error) {
        NSLog(@"CrashManagerdDidFinishBlock. Error %@", error);
    }];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[StartViewController alloc] init]];
    [self.window makeKeyAndVisible];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    if (isRunningTests()) {
        return;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (isRunningTests()) {
        return;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (isRunningTests()) {
        return;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (isRunningTests()) {
        return;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (isRunningTests()) {
        return;
    }
}

#pragma mark - Testing

static BOOL isRunningTests(void)
{
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"octest"] || [[injectBundle pathExtension] isEqualToString:@"xctest"];
}

#pragma mark HockeyApp

- (void)testCrash
{
    [self.hockeyHandler makeApplicationCrash];
}
@end
