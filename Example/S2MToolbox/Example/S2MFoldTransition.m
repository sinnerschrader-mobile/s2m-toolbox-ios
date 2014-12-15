//
//  S2MFoldTransition.m
//  S2MToolbox
//
//  Created by François Benaiteau on 15/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MFoldTransition.h"

@interface S2MFoldTransition ()

@end

@implementation S2MFoldTransition

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.foldAnimator = [[S2MFoldAnimator alloc] init];
        self.foldAnimator.unfolding = YES;
        self.foldAnimator.direction = S2MFoldAnimatorDirectionRightToLeft;
    }
    return self;
}

#pragma mark - <UIViewControllerAnimatedTransitioning>

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 2.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView* fromView = [[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] view];
    UIView* toView = [[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] view];
    CGRect toOriginalFrame = toView.frame;
    CGRect fromOriginalFrame = fromView.frame;
    
    UIView *containerView = [transitionContext containerView];
    if (self.interactive) {
        [containerView addSubview:toView];
    }
    [self.foldAnimator animateWithDuration:[self transitionDuration:transitionContext]
                             initialOffset:0
                                    toView:toView
                             containerView:containerView
                                completion:^(BOOL finished) {
        BOOL cancel = [transitionContext transitionWasCancelled];
        if (cancel) {
            toView.frame = toOriginalFrame;
            fromView.frame = fromOriginalFrame;
            if (self.interactive) {
                [toView removeFromSuperview];
            }
        }
        [transitionContext completeTransition:!cancel];
    }];
}

@end
