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
        self.foldAnimator.folds = 2;
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
    UIView* foldingView = self.foldAnimator.unfolding ? toView : fromView;
    UIView* slidedView = self.foldAnimator.unfolding ? fromView : toView;

    CGRect foldingOriginalFrame = foldingView.frame;
    CGRect slidedOriginalFrame = slidedView.frame;
    
    UIView *containerView = [transitionContext containerView];

    if (slidedView.superview == nil) {
        [containerView addSubview:slidedView];
    }


    if (self.foldAnimator.unfolding) {
        // safety.
        slidedView.frame = slidedOriginalFrame;
    }else{
        slidedView.frame = CGRectOffset(slidedView.frame, - CGRectGetWidth(slidedOriginalFrame), 0);
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         // the animator just do the (un)folding of the view, so take care of the rest in case of UIVC transitions
                         if (self.foldAnimator.unfolding) {
                             slidedView.frame = CGRectOffset(slidedOriginalFrame, - CGRectGetWidth(slidedOriginalFrame), 0);

                         }else{
                             slidedView.frame = CGRectOffset(slidedView.frame, CGRectGetWidth(slidedOriginalFrame), 0);
                         }
                         
                         [self.foldAnimator animateWithDuration:[self transitionDuration:transitionContext]
                                                  initialOffset:0
                                                         toView:foldingView
                                                  containerView:containerView
                                                     completion:NULL];
                         
                     } completion:^(BOOL finished) {
                         BOOL cancel = [transitionContext transitionWasCancelled];
                         if (cancel) {
                             toView.frame = foldingOriginalFrame;
                             fromView.frame = slidedOriginalFrame;
                             if (self.interactive) {
                                 [toView removeFromSuperview];
                             }
                         }
                         [transitionContext completeTransition:!cancel];
                     }];
}

@end
