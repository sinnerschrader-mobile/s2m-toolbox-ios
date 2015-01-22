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
@property (nonatomic, strong) NSURL* url;

@end

@implementation S2MWebViewController


-(void)loadURL:(NSURL *)url
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    if ([url isEqual:self.url]) {
        return YES;
    }
    
    if (self.shouldOpenLinks) {
        [[UIApplication sharedApplication] openURL:url];
    }
    return NO;
}

#pragma mark -

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;

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
        
    }
    return self;
}
@end
