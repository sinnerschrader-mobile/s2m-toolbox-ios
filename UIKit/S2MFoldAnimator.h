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
    S2MFoldAnimatorDirectionLeftToRight, // TODO: test it
    S2MFoldAnimatorDirectionTopToBottom,
    S2MFoldAnimatorDirectionBottomToTop // TODO: implement
};

/**
 * Animates two views using a paper-fold style transition.
 *
 */
@interface S2MFoldAnimator : NSObject

@property (nonatomic) NSUInteger folds; // Number of folds for the view
@property (nonatomic, assign) S2MFoldAnimatorDirection direction;
@property (nonatomic, assign) BOOL unfolding; // If unfolding set to NO. Folding animation is performed

/**
 *  Fold/Unfold toView. If unfolding is set, unfolding animation is performed.
 *
 *  @param duration      duration of animation
 *  @param initialOffset position offset of toView related to the bounds of container. Offset applied on direction of animator
 *                       Used if animation should start elsewhere than bounds of container.
 *  @param toView        view to be fold. The view will be added to containerView if no superview
 *  @param containerView view containing animation
 *  @param completion    animation completion block
 */
- (void)animateWithDuration:(NSTimeInterval)duration
              initialOffset:(CGFloat)initialOffset
                     toView:(UIView *)toView
              containerView:(UIView*)containerView
                 completion:(void (^)(BOOL finished))completion;
@end
