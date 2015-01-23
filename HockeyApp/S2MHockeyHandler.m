//
//  S2MHockeyHandler.m
//  S2MToolbox
//
//  Created by François Benaiteau on 31/10/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "S2MHockeyHandler.h"

NSString *const S2MHockeyHandlerInfoPlistKey = @"HOCKEY_APP_ID";

// macro definition from cocoapods xcconfig
#ifdef BITHOCKEY_VERSION
#import "HockeySDK.h"

@interface S2MHockeyHandler ()<BITHockeyManagerDelegate,BITCrashManagerDelegate,UIAlertViewDelegate>

@end
#endif
@implementation S2MHockeyHandler

- (void)makeApplicationCrash
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self performSelector:@selector(makeApplicationCrashOnPurpose)
               withObject:nil];
#pragma clang diagnostic pop
}


-(void)configureHockeyWithAppId:(NSString*)hockeyAppId
{
#ifdef BITHOCKEY_VERSION
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:hockeyAppId delegate:self];
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus:BITCrashManagerStatusAutoSend];
	[[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
	[[BITHockeyManager sharedHockeyManager] setDisableUpdateManager:[BITHockeyManager sharedHockeyManager].isAppStoreEnvironment];
#endif
}


- (BOOL)didCrashInLastSessionOnStartup
{
#ifdef BITHOCKEY_VERSION
    return ([[BITHockeyManager sharedHockeyManager].crashManager didCrashInLastSession] &&
            [[BITHockeyManager sharedHockeyManager].crashManager timeintervalCrashInLastSessionOccured] < S2M_DEFAULT_CRASH_TIME_INTERVAL);
#else
    return NO;
#endif
}

#pragma mark - BITCrashManagerDelegate
#ifdef BITHOCKEY_VERSION
- (void)crashManagerWillCancelSendingCrashReport:(BITCrashManager *)crashManager {
	if ([self didCrashInLastSessionOnStartup]) {
		if (self.crashManagerdDidFinishBlock) {
			self.crashManagerdDidFinishBlock(nil);
		}
	}
}

- (void)crashManager:(BITCrashManager *)crashManager didFailWithError:(NSError *)error
{
    NSLog(@"crashManager didFailWithError %@", error);
    if ([self didCrashInLastSessionOnStartup]) {
        if (self.crashManagerdDidFinishBlock) {
            self.crashManagerdDidFinishBlock(error);
        }
    }
}

- (void)crashManagerDidFinishSendingCrashReport:(BITCrashManager *)crashManager
{
    NSLog(@"crashManagerDidFinishSendingCrashReport");
    if ([self didCrashInLastSessionOnStartup]) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:self.appCrashAlertTitle
                                                       message:appCrashAlertMessage
                                                      delegate:self
                                             cancelButtonTitle:self.appCrashAlertCancelButton
                                             otherButtonTitles:nil];
        [view show];
    }
}
#endif

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.crashManagerdDidFinishBlock) {
        self.crashManagerdDidFinishBlock(nil);
    }
}

#pragma mark - Lifecycle

- (id)initWithHockeyAppId:(NSString*)hockeyAppId
{
    self = [super init];
    if (self) {
        [self configureHockeyWithAppId:hockeyAppId];
        self.appCrashAlertTitle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        self.appCrashAlertMessage = @"Application crashed on last Session. Crash Report sent.";
        self.appCrashAlertCancelButton = @"OK";
    }
    return self;

}

- (id)init
{
    NSString* hockeyAppId = [[[NSBundle mainBundle] infoDictionary] objectForKey:S2MHockeyHandlerInfoPlistKey];
    self = [self initWithHockeyAppId:hockeyAppId];
    if (self) {

    }
    return self;
}

@end
