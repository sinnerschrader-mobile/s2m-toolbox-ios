//
//  S2MWebViewController.h
//  S2MToolbox
//
//  Created by François Benaiteau on 26/01/15.
//
//

#import <UIKit/UIKit.h>

@interface S2MWebViewController : UIViewController
@property (nonatomic, strong, readonly) UIWebView *webView;/// webview used to load given URL.
@property (nonatomic, assign) BOOL shouldOpenLinks;/// will let application open links when a local URL is loaded

-(id)init __attribute__((unavailable("This method is not available, use initWithURL: instead")));
/**
 *  Loads and display given URL
 *
 *  @param url remote URL of the resource to load
 *
 *  @return instance of S2MWebViewController
 */
-(instancetype)initWithURL:(NSURL*)url NS_DESIGNATED_INITIALIZER;
/**
 *  Loads and display given local URL
 *
 *  @param file filename of resource contained in bundle of application
 *
 *  @return instance of S2MWebViewController
 */
-(instancetype)initWithBundleFile:(NSString*)file;

@end
