//
//  S2MFoldViewController.m
//  S2MToolbox
//
//  Created by François Benaiteau on 15/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MFoldViewController.h"

@interface S2MFoldViewController ()
@property(nonatomic, strong)UIView* foldView;
@property(nonatomic, strong)S2MFoldAnimator* animator;
@end

@implementation S2MFoldViewController

- (IBAction)didSelectControl:(UISegmentedControl*)control
{
    switch (control.selectedSegmentIndex) {
        case S2MFoldAnimatorDirectionRightToLeft:
            break;
        case S2MFoldAnimatorDirectionLeftToRight:
            break;
        case S2MFoldAnimatorDirectionTopToBottom:
            break;
        case S2MFoldAnimatorDirectionBottomToTop:
            break;
        default:
            NSAssert(false, @"unknown direction");
            break;
    }
    self.animator.unfolding = !self.animator.unfolding;
    self.animator.direction = control.selectedSegmentIndex;
    [self.animator animateWithDuration:2
                         initialOffset:0
                                toView:self.foldingView
                         containerView:self.view
                            completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"S2M Fold Animator";
    self.animator = [[S2MFoldAnimator alloc] init];
    self.animator.unfolding = NO;
}

+(S2MFoldTransition*)transitionAnimator
{
    return [[S2MFoldTransition alloc] init];
}

@end
