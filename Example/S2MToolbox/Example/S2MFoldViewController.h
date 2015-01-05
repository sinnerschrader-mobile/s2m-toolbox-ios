//
//  S2MFoldViewController.h
//  S2MToolbox
//
//  Created by François Benaiteau on 15/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "S2MFoldTransition.h"

@interface S2MFoldViewController : UIViewController
- (IBAction)didSelectControl:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *foldingView;
+(S2MFoldTransition*)transitionAnimator;
@end
