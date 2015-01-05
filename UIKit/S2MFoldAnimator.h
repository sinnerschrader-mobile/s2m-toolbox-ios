//
//  S2MFoldAnimator.h
//  S2MToolbox
//
//  Created by François Benaiteau on 23/07/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//
//  Inspired by https://github.com/ColinEberhardt/VCTransitionsLibrary

typedef NS_ENUM(NSUInteger, S2MFoldAnimatorDirection) {
    S2MFoldAnimatorDirectionRightToLeft,
    S2MFoldAnimatorDirectionLeftToRight,
    S2MFoldAnimatorDirectionTopToBottom,
    S2MFoldAnimatorDirectionBottomToTop
};

/**
 * Animates a view with a paper-fold effect.
 *
 */
@interface S2MFoldAnimator : NSObject

@property (nonatomic) NSUInteger folds; // Number of folds for the view. default 1
@property (nonatomic, assign) S2MFoldAnimatorDirection direction; // direction in which view is animated. default from right to left (S2MFoldAnimatorDirectionRightToLeft)
@property (nonatomic, assign) BOOL unfolding; // If unfolding set to NO. Folding animation is performed. default YES

/**
 *  Fold/Unfold toView. If unfolding is set, unfolding animation is performed.
 *
 *  @param duration      duration of animation
 *  @param view          view to be fold. The view will be added to containerView if no superview.
 *                       The view's frame should be set to be the initial position
 *  @param containerView view containing the animation and the view to be animated
 *  @param completion    A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
 */
- (void)animateWithDuration:(NSTimeInterval)duration
                     view:(UIView *)view
              containerView:(UIView*)containerView
                 completion:(void (^)(BOOL finished))completion;
@end
