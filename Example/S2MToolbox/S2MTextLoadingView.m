//
//  S2MTextLoadingView.m
//  S2MToolbox
//
//  Created by François Benaiteau on 12/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MTextLoadingView.h"
#import <S2MToolbox/UIView+S2MAutolayout.h>

@interface S2MTextLoadingView ()
@property(nonatomic, strong, readwrite)NSTimer* timer;
@end

@implementation S2MTextLoadingView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 250, 30)];
    if (self) {
        self.label = [[UILabel alloc] init];
        self.label.text = @"Pulling...";
        [self addSubview:self.label];
        [self.label sizeToFit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark - <S2MControlLoadingView>

- (void)startAnimating
{
    self.label.text = @"Loading...";
    [self.label sizeToFit];
    self.label.textColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.3 animations:^{
        self.superview.backgroundColor = [UIColor clearColor];
    }];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFires:) userInfo:nil repeats:YES];
}

- (void)stopAnimating
{
    [self.timer invalidate];
    self.label.text = @"Pulling...";
    [self.label sizeToFit];
    self.label.textColor = [UIColor whiteColor];
}

- (void)animateWithFractionDragged:(CGFloat)fractionDragged
{
    NSLog(@"%f", fractionDragged);
    // just an example
    CGFloat hue = fractionDragged;
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    self.superview.backgroundColor = color;
}


- (void)timerFires:(NSTimer*)timer;
{
    // just an example
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    self.label.textColor = color;

}

@end
