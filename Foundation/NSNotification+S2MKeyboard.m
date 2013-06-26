//
//  NSNotification+Keyboard.m
//  
//
//  Created by Falko Richter on 10.12.12.
//  Copyright (c) 2012 SinnerSchrader Mobile. All rights reserved.
//

#import "NSNotification+S2MKeyboard.h"

@implementation NSNotification (S2MKeyboard)

- (NSTimeInterval)keyboardAnimationDurationForNotification
{
    NSDictionary* info = [self userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    return duration;
}

@end
