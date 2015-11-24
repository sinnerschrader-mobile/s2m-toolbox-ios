//
//  UIDevice+S2MAdditions.h
//  MoreMobile
//
//  Created by Andreas Buff on 03/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (S2MAdditions)

/**
 *  Returns the battery charge level for the device.
 Battery level ranges from 0.0 to 1.0 (100% charged).
 *
 *  @return battery level
 */
+ (float)s2m_batteryState;

@end
