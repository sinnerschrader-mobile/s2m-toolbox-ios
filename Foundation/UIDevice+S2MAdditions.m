//
//  UIDevice+S2MAdditions.m
//  MoreMobile
//
//  Created by Andreas Buff on 03/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "UIDevice+S2MAdditions.h"

@implementation UIDevice (S2MAdditions)

+ (float)s2m_batteryState
{
    if (![UIDevice currentDevice].batteryMonitoringEnabled) {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    return [UIDevice currentDevice].batteryLevel;
}

@end
