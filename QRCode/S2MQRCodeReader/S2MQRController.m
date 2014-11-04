//
//  ViewController.m
//  S2MQRCodeReader
//
//  Created by Joern Ehmann on 03/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "S2MQRController.h"
#import <AVFoundation/AVFoundation.h>

@interface S2MQRController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIImageView *boundingImageView;

@property (nonatomic, strong) NSMutableSet *knownCodes;

//private lazy var previewLayer: AVCaptureVideoPreviewLayer = { return AVCaptureVideoPreviewLayer(session: self.session) }()

@end

@implementation S2MQRController

#pragma mark Authorization
-(void)showSettingsAlert
{
    if (&UIApplicationOpenSettingsURLString != NULL) {
        //iOS8 only
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.title message:self.authorizationDeniedText preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                  [[UIApplication sharedApplication] openURL:appSettings];
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        //iOS 7, just show Alert
        [[[UIAlertView alloc] initWithTitle:self.title message:self.authorizationDeniedText delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    }
}

-(void)checkAuthorization
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized){

        [self initCamera];
        [self startScanning];

        NSLog(@"%@", @"Camera access granted.");
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined){
        NSLog(@"%@", @"Camera access not determined. Ask for permission.");
        
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.session.running) {
        [self.session stopRunning];
    }
}

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

-(void)checkForValidURL:(NSString*)scanned
{
    if (self.openURLsAutomatically) {
        NSURL *url = [NSURL URLWithString:scanned];
        BOOL canHandleURL = [[UIApplication sharedApplication] canOpenURL:url];
        if (canHandleURL) {
            [[UIApplication sharedApplication] openURL:url];
        }else{
            if (![self.knownCodes containsObject:scanned]) {
                [[[UIAlertView alloc] initWithTitle:scanned message:self.noValidURLText delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            }
            //do not show alert for this code again
            [self.knownCodes addObject:scanned];
        }
    }
    
    //call delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(qrController:didRecognizeCode:)]) {
        [self.delegate qrController:self didRecognizeCode:scanned];
    }
}

#pragma mark Default Inits

-(void)initDefaultSettings
{
    self.boundingImage = nil;
    self.openURLsAutomatically = YES;
    self.willLeadToSettingsIfNotAuthorized = YES;
    
    self.authorizationDeniedText = @"App cannot access camera. Please grant access in Settings";
    self.noValidURLText = @"The scanned QR is not a valid URL and connot be opened";
}

-(void)initCamera
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    self.deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(qrController:didFailWithError:)]) {
            [self.delegate qrController:self didFailWithError:error];
        }
    }
    self.metadataOutput = [AVCaptureMetadataOutput new];
    self.session = [AVCaptureSession new];
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    [self.session addOutput:self.metadataOutput];
    [self.session addInput:self.deviceInput];
    
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
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

-(void)setBoundingImage:(UIImage *)boundingImage{
    _boundingImage = boundingImage;
    
    if (boundingImage) {
        self.boundingImageView.image = boundingImage;
    }
}
-(UIImageView *)boundingImageView{
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

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopScanning];
}

-(void)viewWillLayoutSubviews
{
    self.previewLayer.frame = self.view.bounds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cameraView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.cameraView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.cameraView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.view addSubview:self.cameraView];
}


-(instancetype)initWithDelegate:(NSObject<S2MQRControllerDelegate>*)delegate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.delegate = delegate;
        self.knownCodes = [NSMutableSet set];
        [self initDefaultSettings];
    }
    return self;
}

@end
