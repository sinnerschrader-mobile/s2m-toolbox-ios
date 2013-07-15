//
//  UIView+S2MAdditions.h
//
//
//  Created by François Benaiteau on 5/28/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SYNAdditions)

-(id)addView;

-(id)addLabel;
-(id)addTextField;
-(id)addSwitch;
-(id)addButton;

-(id)addImage:(UIImage*)image;
-(id)addImageNamed:(NSString*)imageName;

-(id)addSearchBar;
-(id)addTableView;
-(id)addActivityIndicatorView;


@end
