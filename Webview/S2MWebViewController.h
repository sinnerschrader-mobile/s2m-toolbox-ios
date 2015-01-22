//
//  S2MWebViewController.h
//  S2MToolbox
//
//  Created by François Benaiteau on 26/01/15.
//
//

#import <UIKit/UIKit.h>

@interface S2MWebViewController : UIViewController
@property (nonatomic, strong, readonly) UIWebView *webView;
@property (nonatomic, assign) BOOL shouldOpenLinks;

-(id)init __attribute__((unavailable("This method is not available, use initWithURL: instead")));
-(instancetype)initWithURL:(NSURL*)url NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithBundleFile:(NSString*)file;

@end
