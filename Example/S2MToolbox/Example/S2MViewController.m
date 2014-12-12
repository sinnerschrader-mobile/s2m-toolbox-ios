//
//  S2MViewController.m
//  S2MToolbox
//
//  Created by François Benaiteau on 27/10/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MViewController.h"

@interface S2MViewController ()<UITextFieldDelegate>

@end

@implementation S2MViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass(self.class);
    // example of autolayout and UIView additions
    UIView* autoLayoutView = [self.view s2m_addView];
    autoLayoutView.backgroundColor = [UIColor grayColor];
    [autoLayoutView s2m_addWidthConstraint:200];
    [autoLayoutView s2m_addHeightConstraint:200];
    [autoLayoutView s2m_addCenterInSuperViewConstraint];
    
    UITextField* textField = [self.view s2m_addTextField];
    [textField s2m_addLeftRightConstraint:20];
    [textField s2m_addBottomConstraint:20];
    [textField s2m_addHeightConstraint:50];
    textField.placeholder = @"Type here";
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.delegate = self;
    [self registerForKeyboardNotifications];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:[aNotification s2m_keyboardAnimationDurationForNotification]
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        self.view.frame = CGRectOffset(self.view.bounds, 0, -kbSize.height);
    } completion:NULL];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    // example of NSNotification category
    [UIView animateWithDuration:[aNotification s2m_keyboardAnimationDurationForNotification]
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.frame = self.view.bounds;

                     } completion:NULL];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

@end
