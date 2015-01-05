//
//  S2MHockeyHandler.h
//  S2MToolbox
//
//  Created by François Benaiteau on 31/10/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef S2M_DEFAULT_CRASH_TIME_INTERVAL
#define S2M_DEFAULT_CRASH_TIME_INTERVAL 5 // seconds in userSession (hockey) while the crash happened
#endif

extern NSString *const S2MHockeyHandlerInfoPlistKey;

@interface S2MHockeyHandler : NSObject

@property(nonatomic, copy)NSString* appCrashAlertTitle;
@property(nonatomic, copy)NSString* appCrashAlertMessage;
@property(nonatomic, copy)NSString* appCrashAlertCancelButton;
@property(nonatomic, copy)void (^crashManagerdDidFinishBlock)(NSError* error);

/**
 *  method to test crash reporter. Will make app crash
 */
- (void)makeApplicationCrash;
/**
 *  Indicate if application crashed on last startup
 *
 *  @return BOOL Yes if it crashed on last startup, NO otherwise
 */
- (BOOL)didCrashInLastSessionOnStartup;

/**
 *  Initialize Hockey Handler with specific AppId
 *
 *  @param hockeyAppId application Id from HockeyApp.
 *
 *  @return instance of Hockey handler
 *  @note use `-(id)init` method to read appId from info.plist file of application
 */
- (id)initWithHockeyAppId:(NSString*)hockeyAppId;
@end
