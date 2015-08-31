//
//  S2MDelegateDispatchSampleViewController.h
//  S2MToolbox
//
//  Created by Nils Grabenhorst on 28/05/15.
//  Copyright (c) 2015 Sinnerschrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol S2MDelegateDispatcher;
@protocol S2MViewControllerDelegate;

@interface S2MDelegateDispatchSampleViewController : UIViewController
@property (nonatomic, strong) id<S2MDelegateDispatcher, S2MViewControllerDelegate> delegateDispatcher;
@end




@protocol S2MViewControllerDelegate <NSObject>
- (void)viewController:(S2MDelegateDispatchSampleViewController *)viewController didUpdateTapCount:(NSUInteger)count;
@end