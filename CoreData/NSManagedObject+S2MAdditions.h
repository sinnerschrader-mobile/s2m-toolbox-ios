//
//  NSManagedObject+S2MAdditions.h
//  S2MToolbox
//
//  Created by ParkSanggeon on 13. 10. 22..
//  Copyright (c) 2013년 SinnerSchrader Mobile. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (S2MAdditions)

- (NSMutableDictionary *)jsonDictionary;

+ (NSManagedObject *)updateOrCreateWithDictionary: (NSDictionary *)jsonDic
                                           entity: (NSEntityDescription *)entity
                                          context: (NSManagedObjectContext *)context;

+ (BOOL)updateOrCreateWithDictionaries: (NSArray *)jsonDicArray
                                entity: (NSEntityDescription *)entity
                               context: (NSManagedObjectContext *)context;

+ (BOOL)deleteWithDictionary: (NSDictionary *)jsonDic
                      entity: (NSEntityDescription *)entity
                     context: (NSManagedObjectContext *)context;

+ (BOOL)deleteWithDictionaries: (NSArray *)jsonDicArray
                        entity: (NSEntityDescription *)entity
                       context: (NSManagedObjectContext *)context;

@end




@interface NSManagedObject (S2MAdditions_toBeMovedToMOGeneratorTemplate)

+ (NSManagedObject *)updateOrCreateWithDictionary: (NSDictionary *)jsonDic
                                          context: (NSManagedObjectContext *)context;

+ (BOOL)updateOrCreateWithDictionaries: (NSArray *)jsonDicArray
                               context: (NSManagedObjectContext *)context;

+ (BOOL)deleteWithDictionary: (NSDictionary *)jsonDic
                     context: (NSManagedObjectContext *)context;

+ (BOOL)deleteWithDictionaries: (NSArray *)jsonDicArray
                       context: (NSManagedObjectContext *)context;
@end