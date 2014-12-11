//
//  UIBarButtonItem+S2MAdditions.h
//  S2MToolbox
//
//  Created by François Benaiteau on 6/10/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (S2MAdditions)
-(id)s2m_initWithImageName:(NSString*)imageName target:(id)target action:(SEL)action NS_RETURNS_RETAINED;
-(id)s2m_initWithTitle:(NSString*)title backgroundImage:(UIImage*)image target:(id)target action:(SEL)action NS_RETURNS_RETAINED;

@end
