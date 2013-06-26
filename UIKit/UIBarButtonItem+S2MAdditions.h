//
//  UIBarButtonItem+S2MAdditions.h
//
//
//  Created by François Benaiteau on 6/10/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (S2MAdditions)
-(id)initWithImageName:(NSString*)imageName target:(id)target action:(SEL)action;
-(id)initWithTitle:(NSString*)title backgroundImage:(UIImage*)image target:(id)target action:(SEL)action;

@end
