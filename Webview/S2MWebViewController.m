//
//  S2MWebViewController.m
//  S2MToolbox
//
//  Created by François Benaiteau on 26/01/15.
//
//

#import "S2MWebViewController.h"

@interface S2MWebViewController ()<UIWebViewDelegate>

@property (nonatomic, strong, readwrite) UIWebView* webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSURL* url;
@property (nonatomic, assign) int networkActivity;
@property (nonatomic, assign) BOOL isURLRemote;
@end

@implementation S2MWebViewController


-(void)loadURL:(NSURL *)url
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (self.isURLRemote) {
        return YES;
    }
    NSURL *url = request.URL;
    if ([url isEqual:self.url]) {
        return YES;
    }
    
    if (self.shouldOpenLinks) {
        [[UIApplication sharedApplication] openURL:url];
    }
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.networkActivity++;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.networkActivity--;
    if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
        NSLog(@"didFailLoadWithError: ignoring NSURLErrorCancelled");
        return;
    }
    NSLog(@"didFailLoadWithError: %@", error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.networkActivity--;
    NSLog(@"webViewDidFinishLoad: %@", webView.request);
}

#pragma mark - getter/setter

- (void)setNetworkActivity:(int)networkActivity
{
    _networkActivity = networkActivity;
    if (networkActivity == 0) {
        [self.activityIndicator stopAnimating];
    } else {
        [self.activityIndicator startAnimating];
    }
    if (self.isURLRemote) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = (networkActivity != 0);
    }
}

#pragma mark -

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    
    if (self.isURLRemote) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.center = self.view.center;
        [self.view addSubview:self.activityIndicator];
    }
    
    if (self.url) {
        [self loadURL:self.url];
    }
}

-(instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.url = url;
        self.shouldOpenLinks = NO;
        self.isURLRemote = YES;
    }
    return self;
}

-(instancetype)initWithBundleFile:(NSString*)file
{
    NSString* resourceBasename = [file stringByDeletingPathExtension];
    NSString* resourceExtension = [file pathExtension];
    NSURL* htmlURL = [[NSBundle mainBundle] URLForResource:resourceBasename withExtension:resourceExtension];
    self = [self initWithURL:htmlURL];
    if (self) {
        self.isURLRemote = NO;
    }
    return self;
}
@end
