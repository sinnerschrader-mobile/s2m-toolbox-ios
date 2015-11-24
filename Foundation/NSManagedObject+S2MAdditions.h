//
//  NSManagedObject+S2MAdditions.h
//  MoreMobile
//
//  Created by Andreas Buff on 11/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (S2MAdditions)

/**
 *  Gets the ManagedObject which matches the instance's object ID from a given context if it is already registered.
 
 Otherwise it creates a fault corresponding to that objectID.  It never returns nil, and never performs I/O.  The object specified by objectID is assumed to exist, and if that assumption is wrong the fault may throw an exception when used.
 *
 *  @param moc context to get the object from
 *
 *  @return object matching the givens object ID if exists, fault corresponding to that objectID otherwize
 */
- (instancetype)s2m_fromManagedObjectContext:(NSManagedObjectContext *)moc;

@end
