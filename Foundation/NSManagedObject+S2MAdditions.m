//
//  NSManagedObject+S2MAdditions.m
//  MoreMobile
//
//  Created by Andreas Buff on 11/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "NSManagedObject+S2MAdditions.h"

@implementation NSManagedObject (S2MAdditions)

- (instancetype)s2m_fromManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [moc objectWithID:self.objectID];
}

@end
