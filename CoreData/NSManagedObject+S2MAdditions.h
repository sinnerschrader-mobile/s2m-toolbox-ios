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

+ (NSManagedObject *)updateOrCreateManagedObjectWithDictionary:(NSDictionary *)jsonDic context:(NSManagedObjectContext *)context;
+ (BOOL)updateOrCreateManagedObjectWithDictionaryArray:(NSArray *)jsonDicArray context:(NSManagedObjectContext *)context;

+ (BOOL)deleteManagedObjectWithDictionary:(NSDictionary *)jsonDic context:(NSManagedObjectContext *)context;
+ (BOOL)deleteManagedObjectWithDictionaryArray:(NSArray *)jsonDicArray context:(NSManagedObjectContext *)context;

@end
