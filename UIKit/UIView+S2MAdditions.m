//
//  UIView+S2MAdditions.m
//
//
//  Created by François Benaiteau on 5/28/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import "UIView+S2MAdditions.h"

@implementation UIView (S2MAdditions)

-(id)addView
{
    UIView* view = [[UIView alloc] init];
    [self addSubview:view];
    return view;
}

#pragma mark -

-(id)addLabel
{
    UILabel* label = [[UILabel alloc] init];
    [self addSubview:label];
    return label;
}

-(id)addTextField
{
    UITextField* textField = [[UITextField alloc] init];
    [self addSubview:textField];
    return textField;
}

-(id)addSwitch
{
    UISwitch* control = [[UISwitch alloc] init];
    [self addSubview:control];
    return control;
}

-(id)addButton
{
    UIButton* control = [[UIButton alloc] init];
    [self addSubview:control];
    return control;
}

-(id)addSearchBar
{
    UISearchBar* searchBar = [[UISearchBar alloc] init];
    [self addSubview:searchBar];
    return searchBar;
}

-(id)addTableView
{
    UITableView* tableView  = [[UITableView alloc] init];
    [self addSubview:tableView];
    return tableView;
}

-(id)addActivityIndicatorView
{
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] init];
    [self addSubview:spinner];
    return spinner;
}

#pragma mark - Image

-(id)addImage:(UIImage*)image
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    return imageView;

}

-(id)addImageNamed:(NSString*)imageName
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [self addSubview:imageView];
    return imageView;
    
}


@end
