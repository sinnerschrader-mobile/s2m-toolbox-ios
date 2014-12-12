//
//  S2MQRViewController.m
//  S2MToolbox
//
//  Created by Joern Ehmann on 03/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "S2MQRViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface S2MQRViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIImageView *boundingImageView;

@property (nonatomic, strong) NSMutableSet *knownCodes;

@end

@implementation S2MQRViewController

#pragma mark Authorization
-(void)showSettingsAlert
{
    if (&UIApplicationOpenSettingsURLString != NULL) {
        //iOS8 only
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.title message:self.authorizationDeniedText preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:self.okButtonText style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                  [[UIApplication sharedApplication] openURL:appSettings];
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        //iOS 7, just show Alert
        [[[UIAlertView alloc] initWithTitle:self.title message:self.authorizationDeniedText delegate:nil cancelButtonTitle:nil otherButtonTitles:self.okButtonText, nil] show];
    }
}

#pragma mark Spinner
-(UIActivityIndicatorView*)showSpinner
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    return spinner;

}
-(void)removeSpinner:(UIActivityIndicatorView*)spinner
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
}


-(void)checkAuthorization
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized){
        UIActivityIndicatorView *spinner = [self showSpinner];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initCamera];
            [self startScanning];
            [self removeSpinner:spinner];
        });
        
        NSLog(@"%@", @"Camera access granted.");
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined){
        NSLog(@"%@", @"Camera access not determined. Ask for permission.");
        
        UIActivityIndicatorView *spinner = [self showSpinner];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
         {
             if(granted)
             {
                 NSLog(@"Granted access to %@", AVMediaTypeVideo);
                 [self initCamera];
                 [self startScanning];
             }
             else
             {
                 NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                 if(self.willLeadToSettingsIfNotAuthorized){
                     [self showSettingsAlert];
                 }
             }
             [self removeSpinner:spinner];
         }];
    }
    else if (authStatus == AVAuthorizationStatusRestricted){
        NSLog(@"Not granted access to %@", AVMediaTypeVideo);
        if(self.willLeadToSettingsIfNotAuthorized){
            [self showSettingsAlert];
        }
    }
    else{
        NSLog(@"Not granted access to %@", AVMediaTypeVideo);
        if(self.willLeadToSettingsIfNotAuthorized){
            [self showSettingsAlert];
        }
    }
}

#pragma mark Scanning
-(void)startScanning
{
    if (!self.session.running) {
        [self.session startRunning];
    }
}

-(void)stopScanning
{
    if (self.session.running) {
        [self.session stopRunning];
    }
}

-(void)checkForValidURL:(NSString*)scanned
{
    if (self.openURLsAutomatically) {
        NSURL *url = [NSURL URLWithString:scanned];
        BOOL canHandleURL = [[UIApplication sharedApplication] canOpenURL:url];
        if (canHandleURL) {
            [[UIApplication sharedApplication] openURL:url];
        }else{
            if (![self.knownCodes containsObject:scanned]) {
                [[[UIAlertView alloc] initWithTitle:scanned message:self.noValidURLText delegate:nil cancelButtonTitle:nil otherButtonTitles:self.okButtonText, nil] show];
            }
            //do not show alert for this code again
            [self.knownCodes addObject:scanned];
        }
    }
    
    //call delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(qrViewController:didRecognizeCode:)]) {
        [self.delegate qrViewController:self didRecognizeCode:scanned];
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

//Delegate for scanned objects
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject  *current in metadataObjects) {
        
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *readable = (AVMetadataMachineReadableCodeObject*)current;
            if (readable.type == AVMetadataObjectTypeQRCode) {
                NSString *scannedResult = readable.stringValue;
                [self checkForValidURL:scannedResult];
            }
        }
    }
}

#pragma mark Default Inits

-(void)initCamera
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    self.deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(qrViewController:didFailWithError:)]) {
            [self.delegate qrViewController:self didFailWithError:error];
        }
    }
    self.metadataOutput = [AVCaptureMetadataOutput new];
    self.session = [AVCaptureSession new];
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    [self.session addOutput:self.metadataOutput];
    if ([self.session canAddInput:self.deviceInput]) {
        [self.session addInput:self.deviceInput];
    }
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([[self.metadataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
        self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    if(self.previewLayer.connection.supportsVideoOrientation) {
        [self orientationDidChange:nil];
    }
    
    //Here it is added
    [self.cameraView.layer insertSublayer:self.previewLayer atIndex:0];
    self.previewLayer.frame = self.view.bounds;
}
#pragma mark UI

-(void)orientationDidChange:(NSNotification *)note
{
    AVCaptureVideoOrientation interfaceOrientation = AVCaptureVideoOrientationPortrait;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            interfaceOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            interfaceOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            interfaceOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
            
        default:
            interfaceOrientation = AVCaptureVideoOrientationPortrait;
    }
    self.previewLayer.connection.videoOrientation = interfaceOrientation;
}

-(void)setBoundingImage:(UIImage *)boundingImage
{
    _boundingImage = boundingImage;
    
    if (boundingImage) {
        self.boundingImageView.image = boundingImage;
    }
}

-(UIImageView *)boundingImageView
{
    if (!_boundingImageView) {
        _boundingImageView = [[UIImageView alloc] init];
        _boundingImageView.contentMode = UIViewContentModeCenter;
        _boundingImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
        [self.view addSubview:_boundingImageView];
        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_boundingImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:_boundingImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self.view addConstraints:@[centerXConstraint, centerYConstraint]];
    }
    return _boundingImageView;
}


#pragma mark Lifecycle
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    [self checkAuthorization];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self stopScanning];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.previewLayer.frame = self.view.bounds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.cameraView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.cameraView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.cameraView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.view addSubview:self.cameraView];
}


-(instancetype)initWithDelegate:(id<S2MQRViewControllerDelegate>)delegate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.delegate = delegate;
        self.knownCodes = [NSMutableSet set];
        self.boundingImage = nil;
        self.openURLsAutomatically = YES;
        self.willLeadToSettingsIfNotAuthorized = YES;
        
        self.authorizationDeniedText = @"App cannot access camera. Please grant access in Settings";
        self.noValidURLText = @"The scanned QR is not a valid URL and connot be opened";
        self.okButtonText = @"OK";
    }
    return self;
}

@end
