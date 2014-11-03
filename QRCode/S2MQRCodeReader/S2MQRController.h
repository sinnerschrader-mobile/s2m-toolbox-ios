//
//  ViewController.h
//  S2MQRCodeReader
//
//  Created by Joern Ehmann on 03/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class S2MQRController;
@protocol S2MQRControllerDelegate <NSObject>

@optional

-(void)qrController:(S2MQRController*)qrController didRecognizeCode:(NSString*)code;
-(void)qrController:(S2MQRController*)qrController didFailWithError:(NSError*)error;

@end


@interface S2MQRController : UIViewController

/**
 *  designated Initializer
 *
 *  @param delegate S2MQRControllerDelegate //may be nil if you want automatic handling
 *
 *  @return instance of S2MQRController
 */
-(instancetype)initWithDelegate:(NSObject<S2MQRControllerDelegate>*)delegate;

/**
 *  designated delegate. Is called when QR is detected
 */
@property (nonatomic, weak) NSObject<S2MQRControllerDelegate> *delegate;

/**
 *  Overlays video capute view with this image. Default is nil. The image is centered in the container and takes the image size as intrinsic size
 */
@property (nonatomic, strong) UIImage *boundingImage;

/**
 *  Default is NO. If YES detected URLs are automatically opened in Safari. If NO, only delegate will be called and you can handle the recognized String on your own.
 */
@property (nonatomic, assign) BOOL openURLsAutomatically;

/**
 *  Default is NO. If YES, an alert is shown to the user if the URL should be opened.
 */
@property (nonatomic, assign) BOOL askBeforeOpeningURL;

/**
 *  Default is YES. iOS8 and up only.
 */
@property (nonatomic, assign) BOOL willLeadToSettingsIfNotAuthorized;

/**
 *  Text displayed for denied authorization Alert
 */
@property (nonatomic, copy) NSString *authorizationDeniedText;
/**
 *  Text displayed for no valid URL found text
 */
@property (nonatomic, copy) NSString *noValidURLText;

@end

