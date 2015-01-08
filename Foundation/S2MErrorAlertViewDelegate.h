//
//  S2MErrorAlertViewDelegate.h
//  S2MToolbox
//
//  Created by ParkSanggeon on 13.10.28.
//  Copyright (c) 2012 SinnerSchrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol S2MErrorAlertViewDelegate <NSObject>

@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex error:(NSError *)error;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView error:(NSError *)error;

- (void)willPresentAlertView:(UIAlertView *)alertView error:(NSError *)error;  // before animation and showing view
- (void)didPresentAlertView:(UIAlertView *)alertView error:(NSError *)error;  // after animation

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex error:(NSError *)error; // before animation and hiding view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex error:(NSError *)error;  // after animation

// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView error:(NSError *)error;

@end
