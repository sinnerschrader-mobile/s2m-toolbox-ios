//
//  UIView+S2MAdditions.h
//  S2MToolbox
//
//  Created by François Benaiteau on 5/28/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (S2MAdditions)

-(id)s2m_addView;

#pragma mark -

-(id)s2m_addLabel;
-(id)s2m_addTextField;
-(id)s2m_addSwitch;
-(id)s2m_addButton;
-(id)s2m_addSearchBar;
-(id)s2m_addTableView;
-(id)s2m_addActivityIndicatorView;

#pragma mark - Image

-(id)s2m_addImage:(UIImage*)image;
-(id)s2m_addImageNamed:(NSString*)imageName;

#pragma mark - Animation

- (void)s2m_rotateWithDuration:(CGFloat)duration repeat:(float)repeat;
- (void)s2m_removeRotationAnimation;
@end
