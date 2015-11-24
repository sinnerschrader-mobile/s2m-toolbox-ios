//
//  NSFileManager+S2MAdditions.m
//  MoreMobile
//
//  Created by Andreas Buff on 05/07/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "NSFileManager+S2MAdditions.h"

@implementation NSFileManager (S2MAdditions)

+ (NSString *)s2m_documentsDirectoryPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}
@end
