//
//  S2MHockeyViewController.m
//  S2MToolbox
//
//  Created by François Benaiteau on 16/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MHockeyViewController.h"

#import "S2MAppDelegate.h"

@interface S2MHockeyViewController ()

@end

@implementation S2MHockeyViewController

- (void)buttonTapped:(id)sender
{
    // for example purpose only
    [((S2MAppDelegate*)[UIApplication sharedApplication].delegate) testCrash];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.title = @"HockeyApp";
    UIButton* button = [self.view s2m_addButton];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"Tap to crash!!" forState:UIControlStateNormal];
    [button sizeToFit];
    [button s2m_addCenterInSuperViewConstraint];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

@end
