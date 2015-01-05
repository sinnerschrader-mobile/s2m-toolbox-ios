//
//  S2MRefreshControl.m
//  S2MToolbox
//
//  Created by François Benaiteau on 15/08/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "S2MRefreshControl.h"

#import "UIView+S2MAdditions.h"
#import "UIView+S2MAutolayout.h"

@interface S2MRefreshControl ()<UIScrollViewDelegate>
@property(nonatomic, strong)UIScrollView* scrollView;
@property(nonatomic, weak)id<UIScrollViewDelegate>originalScrollViewDelegate;
@property(nonatomic, assign)BOOL isRefreshing;

@property(nonatomic, assign)UIEdgeInsets scrollViewInitialInsets;
@property(nonatomic, strong, readwrite)UIView* loadingView;

@end

@implementation S2MRefreshControl

- (instancetype)initWithLoadingView:(UIView<S2MControlLoadingView>*)loadingView
{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.refreshControlHeight = 40;
        self.startLoadingThreshold = self.refreshControlHeight + 25;
        NSAssert(loadingView, @"loadingView cannot be nil");
        NSAssert([loadingView conformsToProtocol:@protocol(S2MControlLoadingView)], @"loadingView must conform to S2MControlLoadingView protocol");
        self.loadingView = loadingView;
    }
    return self;
}

- (instancetype)initWithLoadingImage:(UIImage*)image;
{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.refreshControlHeight = 40;
        self.startLoadingThreshold = self.refreshControlHeight + 25;
        self.loadingView = [[UIImageView alloc] initWithImage:image];
    }
    return self;
}

- (void)dealloc
{
    // restore delegate
    _scrollView.delegate = self.originalScrollViewDelegate;
    self.scrollView = nil;
    self.originalScrollViewDelegate = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = CGRectMake(0, 0, self.superview.bounds.size.width, self.refreshControlHeight);
    self.center = CGPointMake(self.superview.center.x, self.superview.frame.origin.y - self.refreshControlHeight / 2);
    self.loadingView.center = CGPointMake(self.center.x, self.refreshControlHeight/ 2 );
}

- (void)didMoveToSuperview
{
    [self addSubview:self.loadingView];
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        self.scrollView = (UIScrollView*)self.superview;
    }
    [self layoutIfNeeded];
}

#pragma mark - Accessors

- (void)setScrollView:(UIScrollView *)scrollView
{
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(delegate))];
    }
    _scrollView = scrollView;
    if (scrollView.delegate) {
        self.originalScrollViewDelegate = scrollView.delegate;
    }
    scrollView.delegate = self;
    [_scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(delegate)) options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - Animation

- (void)startAnimating
{
    self.loadingView.alpha = 1.0;
    if ([self.loadingView conformsToProtocol:@protocol(S2MControlLoadingView)]) {
        [self.loadingView performSelector:@selector(startAnimating) withObject:nil];
    }else if([self.loadingView isKindOfClass:[UIImageView class]]){
        [self.loadingView s2m_removeRotationAnimation];
        [self.loadingView s2m_rotateWithDuration:0.5 repeat:INFINITY];
    }else{
        NSAssert(false, @"Expected loadingView to conforms to S2MControlLoadingView protocol or subclass UIImageView");
    }
}

- (void)stopAnimating
{
    if ([self.loadingView conformsToProtocol:@protocol(S2MControlLoadingView)]) {
        [self.loadingView performSelector:@selector(stopAnimating) withObject:nil];
    }else if([self.loadingView isKindOfClass:[UIImageView class]]){
        self.loadingView.alpha = 0.0;
        [self.loadingView s2m_removeRotationAnimation];
    }else{
        NSAssert(false, @"Expected loadingView to conforms to S2MControlLoadingView protocol or subclass UIImageView");
    }

}

- (void)animateWithFractionDragged:(CGFloat)fractionDragged
{
    if ([self.loadingView conformsToProtocol:@protocol(S2MControlLoadingView)]) {
        id<S2MControlLoadingView> controlLoadingView = (id<S2MControlLoadingView>)self.loadingView;
        [controlLoadingView animateWithFractionDragged:fractionDragged];
    }else if([self.loadingView isKindOfClass:[UIImageView class]]){
        self.loadingView.alpha = 1;
        self.loadingView.transform = CGAffineTransformMakeRotation(2*M_PI * MAX(0.0, fractionDragged));
    }else{
        NSAssert(false, @"Expected loadingView to conforms to S2MControlLoadingView protocol or subclass UIImageView");
    }
}

- (void)beginRefreshing
{
    if (self.isRefreshing) {
        return;
    }
    
    self.scrollViewInitialInsets = self.scrollView.contentInset;
    self.isRefreshing = YES;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(self.startLoadingThreshold, 0, 0, 0);
    self.scrollView.scrollEnabled = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self startAnimating];
        self.scrollView.scrollEnabled = YES;
    });
}

- (void)endRefreshing
{
    if (!self.isRefreshing) {
        [self stopAnimating];
        return;
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.loadingView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self.scrollView setContentOffset:CGPointZero];
            self.scrollView.contentInset = self.scrollViewInitialInsets;
        } completion:^(BOOL finished2) {
            [self stopAnimating];
            self.isRefreshing = NO;
        }];
    }];
}

#pragma mark - ScrollView

- (void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // do nothing
}

- (void)containingScrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y + scrollView.contentInset.top;
    if (offset <= 0.0 && !self.isRefreshing && !scrollView.isDecelerating) {
        CGFloat fractionDragged = -offset/self.startLoadingThreshold;
        [self animateWithFractionDragged:fractionDragged];
        if (fractionDragged >= 1.0) {
            [self beginRefreshing];
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:NSStringFromSelector(@selector(delegate))]) {
        id newDelegate = change[NSKeyValueChangeNewKey];
        self.originalScrollViewDelegate = newDelegate;
    }
}


#pragma mark - UIScrollViewDelegate
//// We forward delegate calls

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] || [self.originalScrollViewDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if([self.originalScrollViewDelegate respondsToSelector:aSelector]){
        return self.originalScrollViewDelegate;
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self containingScrollViewDidScroll:scrollView];
    if ([self.originalScrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.originalScrollViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self containingScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if ([self.originalScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.originalScrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

@end
