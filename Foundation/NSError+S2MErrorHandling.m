//
//  NSError+S2MErrorHandling.m
//  S2MToolbox
//
//  Created by Uli Luckas on 6/04/12.
//  Copyright (c) 2012 SinnerSchrader Mobile. All rights reserved.
//

#import "NSError+S2MErrorHandling.h"
#import "S2MErrorHandler.h"
#import "S2MErrorAlertViewDelegate.h"
#import <objc/runtime.h>

static const NSString *handledKey = @"handled";
static const NSString *delegatesKey = @"delegates";


#pragma mark - S2MErrorAlertViewDelegateProxy

@interface S2MErrorAlertViewDelegateProxy : NSObject <UIAlertViewDelegate>
@property (nonatomic, strong) NSError *error;
@property (nonatomic, weak) id<S2MErrorAlertViewDelegate> delegate;
@end

@implementation S2MErrorAlertViewDelegateProxy


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:error:)]) {
        [self.delegate alertView:alertView clickedButtonAtIndex:buttonIndex error:self.error];
    }
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView
{
    if ([self.delegate respondsToSelector:@selector(alertViewCancel:error:)]) {
        [self.delegate alertViewCancel:alertView error:self.error];
    }
}
- (void)willPresentAlertView:(UIAlertView *)alertView  // before animation and showing view
{
    if ([self.delegate respondsToSelector:@selector(willPresentAlertView:error:)]) {
        [self.delegate willPresentAlertView:alertView error:self.error];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView  // after animation
{
    if ([self.delegate respondsToSelector:@selector(didPresentAlertView:error:)]) {
        [self.delegate didPresentAlertView:alertView error:self.error];
    }
}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex // before animation and hiding view
{
    if ([self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:error:)]) {
        [self.delegate alertView:alertView willDismissWithButtonIndex:buttonIndex error:self.error];
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{
    if ([self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:error:)]) {
        [self.delegate alertView:alertView didDismissWithButtonIndex:buttonIndex error:self.error];
    }
}

// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if ([self.delegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:error:)]) {
        return [self.delegate alertViewShouldEnableFirstOtherButton:alertView error:self.error];
    }
    
    return YES;
}

@end

#pragma mark - S2MErrorAlertView

@interface S2MErrorAlertView : UIAlertView
@property (nonatomic, strong) S2MErrorAlertViewDelegateProxy *proxyDelegate;
@end

@implementation S2MErrorAlertView
@end


@implementation NSError(S2MErrorHandling)

#pragma mark - Accessors

-(void)setHandled:(BOOL)handled {
    objc_setAssociatedObject (self,
                              &handledKey,
                              [NSNumber numberWithBool:handled],
                              OBJC_ASSOCIATION_RETAIN);
}

-(BOOL)handled {
    BOOL handledValue = NO;
    id handled = objc_getAssociatedObject(self, &handledKey);
    if ([handled isKindOfClass:[NSNumber class]]) {
        handledValue = ((NSNumber*)handled).boolValue;
    }
    return handledValue;
}

#pragma mark - Error Handling

- (void)handleError {
	[self handleErrorWithChainHandler:nil alertViewDelegate:nil alertViewTag:0];
}

-(void)handleErrorWithAlertViewDelegate:(id<S2MErrorAlertViewDelegate>)delegate
						   alertViewTag:(NSInteger)tag {
    [self handleErrorWithChainHandler:nil alertViewDelegate:delegate alertViewTag:tag];
}

-(void)handleErrorWithChainHandler:(id<S2MErrorHandler>)chainErrorHandler {
    [self handleErrorWithChainHandler:chainErrorHandler alertViewDelegate:nil alertViewTag:0];
}

-(void)handleErrorWithChainHandler:(id<S2MErrorHandler>)chainErrorHandler
				 alertViewDelegate:(id<S2MErrorAlertViewDelegate>)delegate
					  alertViewTag:(NSInteger)tag {
    // Make sure we are on main thread
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _handleErrorWithChainHandler:chainErrorHandler alertViewDelegate:delegate alertViewTag:tag];
        });
    } else {
        [self _handleErrorWithChainHandler:chainErrorHandler alertViewDelegate:delegate alertViewTag:tag];
    }
}

-(NSString*)alertTitleString
{
    return @"S2M_SERVER_ALERT_TITLE";
}

-(NSString*)alertButtonString
{
    return @"S2M_SERVER_ALERT_CANCEL_BUTTON";
}

-(NSString*)errorMessage
{
    NSString *errorMessage = [NSString stringWithFormat:@"S2M_SERVER_ERROR_%ld", (long)self.code];
    return NSLocalizedString(errorMessage,nil);
}

#pragma mark - Private Error Handling

-(UIAlertView *)alertViewWithDelegate:(id<S2MErrorAlertViewDelegate>)delegate alertViewTag:(NSInteger)tag
{
    S2MErrorAlertViewDelegateProxy *proxyObject = [[S2MErrorAlertViewDelegateProxy alloc] init];
    proxyObject.delegate = delegate;
    proxyObject.error = self;
    S2MErrorAlertView *alertView = [[S2MErrorAlertView alloc] initWithTitle:[self alertTitleString]
                                           message:[self errorMessage]
                                          delegate:proxyObject
                                 cancelButtonTitle:[self alertButtonString]
                                 otherButtonTitles:nil];
    alertView.tag = tag;
    alertView.proxyDelegate = proxyObject;
    
    return alertView;
}
// Only call on main thread
-(void)_handleErrorWithAlertViewDelegate:(id<S2MErrorAlertViewDelegate>)delegate alertViewTag:(NSInteger)tag {
    if (!self.handled) {
        UIAlertView *alertView = [self alertViewWithDelegate:delegate alertViewTag:tag];
        [alertView show];
        self.handled = YES;
    }
}

// Only call on main thread
-(void)_handleErrorWithChainHandler:(id<S2MErrorHandler>)chainErrorHandler
				  alertViewDelegate:(id<S2MErrorAlertViewDelegate>)delegate
					   alertViewTag:(NSInteger)tag {
    if (chainErrorHandler) {
        [chainErrorHandler handleError:self];
    }
    [self _handleErrorWithAlertViewDelegate:delegate alertViewTag:tag];
}



@end
