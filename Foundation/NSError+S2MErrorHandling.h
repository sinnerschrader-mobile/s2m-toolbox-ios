//
//  NSError+S2MErrorHandling.h
//  S2MToolbox
//
//  Created by Uli Luckas on 6/04/12.
//  Copyright (c) 2012 SinnerSchrader Mobile. All rights reserved.
//

#import "S2MErrorAlertViewDelegate.h"

@protocol S2MErrorHandler;

@interface NSError(S2MErrorHandling)

-(NSString*)errorMessage;
-(NSString*)alertTitleString;
-(NSString*)alertButtonString;
/**
 Indicates whether this error has been handled. If an error is passed through a chain of methods, the method that elects to deal with this error sets this property to `YES`. Methods further up the chain can then determine if an error needs handling. Another approach would be that the handling method doesn't pass the error on, however other methods may still need the information contained whithin the error object.
 */
@property (nonatomic, assign) BOOL handled;


/**
 Provides default error handling.
 Calls #handleErrorWithChainHandler:alertViewDelegate:alertViewTag: with default parameters `nil`, `nil`, `0`.
 */
-(void)handleError;

/**
 Provides default error handling.
 Calls #handleErrorWithChainHandler:alertViewDelegate:alertViewTag: with the given values for the `delegate` and `tag` parameters, and `nil` for the `chainHandler`.
 @param delegate The delegate for the alertView
 @param tag The tag for the alertView. This may be useful to determine a specific alertView in a delegate callback. Just tag different alertViews differently and query the alertView for its `tag` in a callback method.
 */
-(void)handleErrorWithAlertViewDelegate:(id<S2MErrorAlertViewDelegate>)delegate
						   alertViewTag:(NSInteger)tag;


/**
 Provides default error handling.
 Calls #handleErrorWithChainHandler:alertViewDelegate:alertViewTag: with the given `chainErrorHandler`, `nil` as the `delegate`, and `0` as the `tag`.
 @param chainErrorHandler
 */
-(void)handleErrorWithChainHandler:(id<S2MErrorHandler>)chainErrorHandler;


/**
 Provides default error handling.
 If #handled is `YES`, nothing happens. Otherwise, an alertView is shown for normal errors.
 Side effect: #handled will be `YES` afterwards.
 @param chainErrorHandler
 @param delegate The delegate for the alertView
 @param tag The tag for the alertView. This may be useful to determine a specific alertView in a delegate callback. Just tag different alertViews differently and query the alertView for its `tag` in a callback method.
 */
-(void)handleErrorWithChainHandler:(id<S2MErrorHandler>)chainErrorHandler
				 alertViewDelegate:(id<S2MErrorAlertViewDelegate>)delegate
					  alertViewTag:(NSInteger)tag;
@end
