//
//  NSBundle+S2MAdditions.m
//  MoreMobile
//
//  Created by Andreas Buff on 28/05/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "NSBundle+S2MAdditions.h"

@implementation NSBundle (S2MAdditions)

+ (UIView *)s2m_loadXibNamed:(NSString *)xibName
                       owner:(id)owner
{
    return (UIView *)[[[NSBundle mainBundle] loadNibNamed:xibName
                                                    owner:owner
                                                  options:nil]
                      objectAtIndex:0];
}
@end
