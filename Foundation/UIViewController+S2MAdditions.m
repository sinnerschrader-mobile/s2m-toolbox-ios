//
//  UIViewController+S2MAdditions.m
//  MoreMobile
//
//  Created by Andreas Buff on 13/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "UIViewController+S2MAdditions.h"

@implementation UIViewController (S2MAdditions)

- (void)s2m_noEdgeForExtendedLayout
{
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)s2m_removeBackButtonText
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
