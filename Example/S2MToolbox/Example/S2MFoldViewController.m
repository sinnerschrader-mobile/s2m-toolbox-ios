//
//  S2MFoldViewController.m
//  S2MToolbox
//
//  Created by François Benaiteau on 15/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MFoldViewController.h"

@interface S2MFoldViewController ()

@end

@implementation S2MFoldViewController

+(S2MFoldTransition*)transitionAnimator
{
    return [[S2MFoldTransition alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"S2M Fold Animator";
    self.view.backgroundColor = [UIColor blueColor];
}


@end
