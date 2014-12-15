//
//  S2MFoldAnimator.m
//  S2MToolbox
//
//  Created by François Benaiteau on 23/07/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//


#import "S2MFoldAnimator.h"

@implementation S2MFoldAnimator

- (id)init
{
    self = [super init];
    if (self) {
        self.folds = 1;
        self.unfolding = YES;
        self.direction = S2MFoldAnimatorDirectionRightToLeft;
    }
    return self;
}

#pragma mark - Public


- (void)animateWithDuration:(NSTimeInterval)duration
                          initialOffset:(CGFloat)initialOffset
                                 toView:(UIView *)toView
                          containerView:(UIView*)containerView
                             completion:(void (^)(BOOL finished))completion
{
    if (self.direction == S2MFoldAnimatorDirectionTopToBottom ||
        self.direction == S2MFoldAnimatorDirectionBottomToTop) {
        [self animateVerticallyWithDuration:duration
                              initialOffset:initialOffset
                                     toView:toView
                              containerView:containerView
                                 completion:completion];
    }else{
        [self animateHorizontallyWithDuration:duration
                              initialOffset:initialOffset
                                     toView:toView
                              containerView:containerView
                                 completion:completion];
    }
}

#pragma mark - Private
         
- (void)animateHorizontallyWithDuration:(NSTimeInterval)duration
                          initialOffset:(CGFloat)initialOffset
                                 toView:(UIView *)toView
                          containerView:(UIView*)containerView
                             completion:(void (^)(BOOL finished))completion
{
    __block CGSize toViewSize;
    __block CGPoint initialPosition;
    __block CGFloat toViewFoldWidth;
    __block NSMutableArray* toViewFolds;
    __block CATransform3D transform;
    [UIView performWithoutAnimation:^{
        if (self.unfolding) {
            // move offscreen
            [self moveView:toView offScreenSize:containerView.frame.size];
        }
        if (toView.superview == nil) {
            [containerView addSubview:toView];
        }
        toViewSize = toView.frame.size;
        
        // Add a perspective transform
        transform = CATransform3DIdentity;
        transform.m34 = -0.005;
        containerView.layer.sublayerTransform = transform;
        
        toViewFoldWidth = toViewSize.width * 0.5 / (CGFloat)self.folds;
        
        // arrays that hold the snapshot views
        toViewFolds = [NSMutableArray new];
        
        // create the folds for the form- and to- views
        for (NSUInteger i = 0 ; i < self.folds; i++){
            CGFloat toViewOffset = (CGFloat)i * toViewFoldWidth * 2;
            
            if (self.unfolding) {
                initialPosition = CGPointMake((self.direction != S2MFoldAnimatorDirectionRightToLeft) ? initialOffset : containerView.bounds.size.width - initialOffset, toViewSize.height/2);
                // the left and right side of the fold for the to- view, with a 90-degree transform and 1.0 alpha
                // on the shadow, with each view positioned at the very edge of the screen
                UIView *leftToViewFold = [self createSnapshotFromView:toView afterUpdates:YES location:toViewOffset left:YES];
                leftToViewFold.layer.position = initialPosition;
                leftToViewFold.layer.transform = CATransform3DMakeRotation(M_PI_2, 0.0, 1.0, 0.0);
                [toViewFolds addObject:leftToViewFold];
                
                UIView *rightToViewFold = [self createSnapshotFromView:toView afterUpdates:YES location:toViewOffset + toViewFoldWidth left:NO];
                rightToViewFold.layer.position = initialPosition;
                rightToViewFold.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0.0, 1.0, 0.0);
                [toViewFolds addObject:rightToViewFold];
            }else{
                // the left and right side of the fold for the from- view, with identity transform and 0.0 alpha
                // on the shadow, with each view at its initial position
                UIView *leftFromViewFold = [self createSnapshotFromView:toView afterUpdates:NO location:toViewOffset left:YES];
                leftFromViewFold.layer.position = CGPointMake(initialOffset + toViewOffset, toViewSize.height/2);
                [toViewFolds addObject:leftFromViewFold];
                [leftFromViewFold.subviews[1] setAlpha:0.0];
                
                UIView *rightFromViewFold = [self createSnapshotFromView:toView afterUpdates:NO location:toViewOffset + toViewFoldWidth left:NO];
                rightFromViewFold.layer.position = CGPointMake(initialOffset + toViewOffset + toViewFoldWidth * 2, toViewSize.height/2);
                [toViewFolds addObject:rightFromViewFold];
                [rightFromViewFold.subviews[1] setAlpha:0.0];
            }
        }
        toView.hidden = YES;
        
    }];
    
    // create the animation
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         // set the final state for each fold
                         for (NSUInteger i=0; i< self.folds; i++){
                             if (self.unfolding) {
                                 CGFloat toViewOffset = (CGFloat)i * toViewFoldWidth * 2;
                                 
                                 // the left and right side of the fold for the to- view, with identity transform and 0.0 alpha
                                 // on the shadow, with each view at its final position
                                 UIView* leftToView = toViewFolds[i*2];
                                 if (self.direction == S2MFoldAnimatorDirectionRightToLeft) {
                                     leftToView.layer.position = CGPointMake(initialPosition.x - (toViewOffset + toViewFoldWidth * 2),
                                                                             toViewSize.height/2);
                                 }else{
                                     NSAssert(false, @"not supported");
                                 }
                                 
                                 leftToView.layer.transform = CATransform3DIdentity;
                                 [leftToView.subviews[1] setAlpha:0.0];
                                 
                                 UIView* rightToView = toViewFolds[i*2+1];
                                 if (self.direction == S2MFoldAnimatorDirectionRightToLeft) {
                                     rightToView.layer.position = CGPointMake(initialPosition.x - toViewOffset,
                                                                              toViewSize.height/2);
                                 }else{
                                     NSAssert(false, @"not supported");
                                 }
                                 // somehow the transform reset the width of layer
                                 rightToView.layer.transform = CATransform3DIdentity;
                                 [rightToView.subviews[1] setAlpha:0.0];
                             }else{
                                 // the left and right side of the fold for the from- view, with 90 degree transform and 1.0 alpha
                                 // on the shadow, with each view positioned at the edge of thw screen.
                                 UIView* leftFromView = toViewFolds[i*2];
                                 leftFromView.layer.position = CGPointMake( (self.direction == S2MFoldAnimatorDirectionRightToLeft) ? initialOffset + 0.0 : initialOffset + toViewSize.width, toViewSize.height/2);
                                 leftFromView.layer.transform = CATransform3DRotate(transform, M_PI_2, 0.0, 1.0, 0);
                                 [leftFromView.subviews[1] setAlpha:1.0];
                                 
                                 UIView* rightFromView = toViewFolds[i*2+1];
                                 rightFromView.layer.position = CGPointMake( (self.direction == S2MFoldAnimatorDirectionRightToLeft) ? initialOffset + 0.0 : initialOffset + toViewSize.width, toViewSize.height/2);
                                 rightFromView.layer.transform = CATransform3DRotate(transform, -M_PI_2, 0.0, 1.0, 0);
                                 [rightFromView.subviews[1] setAlpha:1.0];
                             }
                         }
                     }  completion:^(BOOL finished) {
                         [UIView performWithoutAnimation:^{
                             // restore the to- and from- to the initial location
                             if (self.unfolding) {
                                 // put back toView frame to expected location
                                 if (self.direction == S2MFoldAnimatorDirectionRightToLeft) {
                                     toView.frame = CGRectOffset(toView.bounds, initialPosition.x - toView.bounds.size.width, 0);
                                 }else{
                                     toView.frame = CGRectOffset(toView.bounds, initialPosition.x, 0);
                                 }
                             }else{
                                 if (self.direction == S2MFoldAnimatorDirectionRightToLeft) {
                                     toView.frame = CGRectOffset(toView.bounds, containerView.bounds.size.width - initialOffset - toView.bounds.size.width, 0);
                                 }else{
                                     toView.frame = CGRectOffset(toView.bounds, initialOffset + toView.bounds.size.width, 0);
                                 }
                             }
                             toView.hidden = NO;
                             // remove the snapshot views
                             for (UIView *view in toViewFolds) {
                                 [view removeFromSuperview];
                             }
                         }];
                         
                         if(completion){
                             completion(finished);
                         }
                     }];
}


- (void)animateVerticallyWithDuration:(NSTimeInterval)duration
                        initialOffset:(CGFloat)initialOffset
                               toView:(UIView *)toView
                        containerView:(UIView*)containerView
                           completion:(void (^)(BOOL finished))completion
{
    __block CGSize toViewSize;
    __block CGFloat toViewFoldHeight;
    __block NSMutableArray* toViewFolds;
    [UIView performWithoutAnimation:^{
        
        if(self.unfolding){
            [self moveView:toView offScreenSize:containerView.bounds.size];
        }
        if (toView.superview == nil) {
            [containerView addSubview:toView];
        }
        [containerView bringSubviewToFront:toView];
        
        
        toViewSize = toView.bounds.size;
        
        // Add a perspective transform
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -0.005;
        containerView.layer.sublayerTransform = transform;
        
        toViewFoldHeight = toViewSize.height * 0.5 / (CGFloat)self.folds;
        
        // arrays that hold the snapshot views
        toViewFolds = [NSMutableArray new];
        
        // create the folds for the form- and to- views
        for (NSUInteger i = 0 ; i < self.folds; i++){
            CGFloat toViewOffset = (CGFloat)i * toViewFoldHeight * 2;
            
            if (self.unfolding) {
                
                // the left and right side of the fold for the to- view, with a 90degree transform and 1.0 alpha
                // on the shadow, with each view positioned at the very edge of the screen
                UIView *topToViewFold = [self createSnapshotFromView:toView afterUpdates:YES location:toViewOffset top:YES];
                topToViewFold.layer.position = CGPointMake(toViewSize.width/2, (self.direction != S2MFoldAnimatorDirectionTopToBottom) ?  0.0 : initialOffset);
                topToViewFold.layer.transform = CATransform3DMakeRotation(-M_PI_2, 1.0, 0.0, 0.0);
                [toViewFolds addObject:topToViewFold];
                
                UIView *bottomToViewFold = [self createSnapshotFromView:toView afterUpdates:YES location:toViewOffset + toViewFoldHeight top:NO];
                bottomToViewFold.layer.position = CGPointMake(toViewSize.width / 2, (self.direction != S2MFoldAnimatorDirectionTopToBottom) ?  0.0 : initialOffset);
                bottomToViewFold.layer.transform = CATransform3DMakeRotation(M_PI_2, 1.0, 0.0, 0.0);
                [toViewFolds addObject:bottomToViewFold];
            }else{
                
                // the left and right side of the fold for the from- view, with identity transform and 0.0 alpha
                // on the shadow, with each view at its initial position
                UIView *topToViewFold = [self createSnapshotFromView:toView afterUpdates:NO location:toViewOffset top:YES];
                topToViewFold.layer.position = CGPointMake(toViewSize.width/2, initialOffset + toViewOffset);
                topToViewFold.layer.transform = CATransform3DIdentity;
                [toViewFolds addObject:topToViewFold];
                [topToViewFold.subviews[1] setAlpha:0.0];
                
                UIView *bottomToViewFold = [self createSnapshotFromView:toView afterUpdates:NO location:toViewOffset + toViewFoldHeight top:NO];
                bottomToViewFold.layer.position = CGPointMake(toViewSize.width/2, initialOffset + toViewOffset + toViewFoldHeight * 2);
                bottomToViewFold.layer.transform = CATransform3DIdentity;
                [toViewFolds addObject:bottomToViewFold];
                [bottomToViewFold.subviews[1] setAlpha:0.0];
            }
        }
        toView.hidden = YES;
    }];
    // create the animation
    [UIView animateWithDuration:duration delay:0 options:0
                     animations:^{
                         // set the final state for each fold
                         for (NSUInteger i=0; i< self.folds; i++){
                             if (self.unfolding) {
                                 CGFloat toViewOffset = (CGFloat)i * toViewFoldHeight * 2;
                                 
                                 // the left and right side of the fold for the to- view, with identity transform and 0.0 alpha
                                 // on the shadow, with each view at its final position
                                 UIView* topToView = toViewFolds[i*2];
                                 topToView.layer.position = CGPointMake(toViewSize.width/2, initialOffset + toViewOffset);
                                 topToView.layer.transform = CATransform3DIdentity;
                                 [topToView.subviews[1] setAlpha:0.0];
                                 
                                 UIView* bottomToView = toViewFolds[i*2+1];
                                 bottomToView.layer.position = CGPointMake(toViewSize.width/2, initialOffset + toViewOffset + toViewFoldHeight * 2);
                                 bottomToView.layer.transform = CATransform3DIdentity;
                                 [bottomToView.subviews[1] setAlpha:0.0];
                             }else{
                                 // the left and right side of the fold for the from- view, with 90 degree transform and 1.0 alpha
                                 // on the shadow, with each view positioned at the edge of thw screen.
                                 UIView* topToView = toViewFolds[i*2];
                                 topToView.layer.position = CGPointMake( toViewSize.width/2, (self.direction == S2MFoldAnimatorDirectionTopToBottom) ? initialOffset + 0.0 : initialOffset + toViewSize.height);
                                 topToView.layer.transform = CATransform3DMakeRotation(-M_PI_2, 1.0, 0.0, 0.0);
                                 [topToView.subviews[1] setAlpha:1.0];
                                 
                                 UIView* bottomToView = toViewFolds[i*2+1];
                                 bottomToView.layer.position = CGPointMake( toViewSize.width/2, (self.direction == S2MFoldAnimatorDirectionTopToBottom) ? initialOffset + 0.0 : initialOffset + toViewSize.height + toViewFoldHeight);
                                 bottomToView.layer.transform = CATransform3DMakeRotation(M_PI_2, 1.0, 0.0, 0.0);
                                 [bottomToView.subviews[1] setAlpha:1.0];
                             }
                         }
                         
                     }  completion:^(BOOL finished) {
                         // remove the snapshot views
                         for (UIView *view in toViewFolds) {
                             [view removeFromSuperview];
                         }
                         toView.hidden = NO;
                         if (self.unfolding) {
                             toView.frame = CGRectMake(toView.frame.origin.x, initialOffset,  toView.frame.size.width, toView.frame.size.height);
                         }else{
                             // Disable this in order not to break constraints
                             //                             toView.frame = CGRectMake(toView.frame.origin.x, initialOffset,  toView.frame.size.width, 0);
                         }
                         if(completion){
                             completion(finished);
                         }
                     }];
}


#pragma mark Helper

- (void)moveView:(UIView*)view offScreenSize:(CGSize)size
{
    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    switch (self.direction) {
        case S2MFoldAnimatorDirectionRightToLeft:
            offsetX = size.width;
            break;
        case S2MFoldAnimatorDirectionTopToBottom:
        case S2MFoldAnimatorDirectionLeftToRight:
            offsetX = - size.width;
            break;
        default:
            break;
    }
    view.frame = CGRectOffset(view.frame, offsetX, offsetY);
}



- (UIView*)createSnapshotFromView:(UIView *)view afterUpdates:(BOOL)afterUpdates location:(CGFloat)offset top:(BOOL)top
{
    
    CGSize size = view.frame.size;
    UIView *containerView = view.superview;
    float foldHeight = size.height * 0.5 / (float)self.folds;
    
    UIView* snapshotView;
    
    if (!afterUpdates) {
        // create a regular snapshot
        CGRect snapshotRegion = CGRectMake(0.0, offset, size.width, foldHeight);
        snapshotView = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        
    } else {
        // for the to- view for some reason the snapshot takes a while to create. Here we place the snapshot within
        // another view, with the same bckground color, so that it is less noticeable when the snapshot initially renders
        snapshotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, foldHeight)];
        snapshotView.backgroundColor = view.backgroundColor;
        CGRect snapshotRegion = CGRectMake(0.0, offset, size.width, foldHeight);
        UIView* snapshotView2 = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        [snapshotView addSubview:snapshotView2];
        
    }
    
    // create a shadow
    UIView* snapshotWithShadowView = [self addShadowToView:snapshotView reverse:top];
    
    // add to the container
    [containerView addSubview:snapshotWithShadowView];
    
    // set the anchor to the top or bottom edge of the view
    snapshotWithShadowView.layer.anchorPoint = CGPointMake( 0.5, top ? 0.0 : 1.0);
    
    return snapshotWithShadowView;
}


// creates a snapshot for the gives view
- (UIView*)createSnapshotFromView:(UIView *)view afterUpdates:(BOOL)afterUpdates location:(CGFloat)offset left:(BOOL)left
{
    
    CGSize size = view.frame.size;
    UIView *containerView = view.superview;
    float foldWidth = size.width * 0.5 / (float)self.folds;
    
    UIView* snapshotView;
    
    if (!afterUpdates) {
        // create a regular snapshot
        CGRect snapshotRegion = CGRectMake(offset, 0.0, foldWidth, size.height);
        snapshotView = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        
    } else {
        // for the to- view for some reason the snapshot takes a while to create. Here we place the snapshot within
        // another view, with the same bckground color, so that it is less noticeable when the snapshot initially renders
        snapshotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, foldWidth, size.height)];
        snapshotView.backgroundColor = view.backgroundColor;
        CGRect snapshotRegion = CGRectMake(offset, 0.0, foldWidth, size.height);
        UIView* snapshotView2 = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        [snapshotView addSubview:snapshotView2];
        
    }
    
    // create a shadow
    UIView* snapshotWithShadowView = [self addShadowToView:snapshotView reverse:left];
    
    // add to the container
    [containerView addSubview:snapshotWithShadowView];
    
    // set the anchor to the left or right edge of the view
    snapshotWithShadowView.layer.anchorPoint = CGPointMake( left ? 0.0 : 1.0, 0.5);
    
    return snapshotWithShadowView;
}


// adds a gradient to an image by creating a containing UIView with both the given view
// and the gradient as subviews
- (UIView*)addShadowToView:(UIView*)view reverse:(BOOL)reverse
{
    // create a view with the same frame
    UIView* viewWithShadow = [[UIView alloc] initWithFrame:view.frame];
    
    // create a shadow
    UIView* shadowView = [[UIView alloc] initWithFrame:viewWithShadow.bounds];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = shadowView.bounds;
    gradient.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                        (id)[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    gradient.startPoint = CGPointMake(reverse ? 0.0 : 1.0, reverse ? 0.2 : 0.0);
    gradient.endPoint = CGPointMake(reverse ? 1.0 : 0.0, reverse ? 0.0 : 1.0);
    [shadowView.layer insertSublayer:gradient atIndex:1];
    
    // add the original view into our new view
    view.frame = view.bounds;
    [viewWithShadow addSubview:view];
    
    // place the shadow on top
    [viewWithShadow addSubview:shadowView];
    
    return viewWithShadow;
}


@end
