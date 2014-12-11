//
//  UIView+S2MAdditions.m
//  S2MToolbox
//
//  Created by François Benaiteau on 5/28/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import "UIView+S2MAdditions.h"

#import <QuartzCore/QuartzCore.h>

static NSString *const S2MRotationAnimationKey = @"com.s2m.rotationAnimation";

@implementation UIView (S2MAdditions)

-(id)s2m_addView
{
    UIView* view = [[UIView alloc] init];
    [self addSubview:view];
    return view;
}

#pragma mark -

-(id)s2m_addLabel
{
    UILabel* label = [[UILabel alloc] init];
    [self addSubview:label];
    return label;
}

-(id)s2m_addTextField
{
    UITextField* textField = [[UITextField alloc] init];
    [self addSubview:textField];
    return textField;
}

-(id)s2m_addSwitch
{
    UISwitch* control = [[UISwitch alloc] init];
    [self addSubview:control];
    return control;
}

-(id)s2m_addButton
{
    UIButton* control = [[UIButton alloc] init];
    [self addSubview:control];
    return control;
}

-(id)s2m_addSearchBar
{
    UISearchBar* searchBar = [[UISearchBar alloc] init];
    [self addSubview:searchBar];
    return searchBar;
}

-(id)s2m_addTableView
{
    UITableView* tableView  = [[UITableView alloc] init];
    [self addSubview:tableView];
    return tableView;
}

-(id)s2m_addActivityIndicatorView
{
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] init];
    [self addSubview:spinner];
    return spinner;
}

#pragma mark - Image

-(id)s2m_addImage:(UIImage*)image
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    return imageView;

}

-(id)s2m_addImageNamed:(NSString*)imageName
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [self addSubview:imageView];
    return imageView;
    
}

#pragma mark - Animation

- (void)s2m_rotateWithDuration:(CGFloat)duration repeat:(float)repeat
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = repeat;
    rotationAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:rotationAnimation forKey:S2MRotationAnimationKey];
}

- (void)s2m_removeRotationAnimation
{
    [self.layer removeAnimationForKey:S2MRotationAnimationKey];
}


@end
