//
//  NSManagedObject+S2MAdditions.m
//  S2MToolbox
//
//  Created by ParkSanggeon on 13. 10. 22..
//  Copyright (c) 2013년 SinnerSchrader Mobile. All rights reserved.
//

#import "NSManagedObject+S2MAdditions.h"

@implementation NSManagedObject (S2MAdditions)



#pragma mark - Public

- (NSMutableDictionary *)jsonDictionary
{
    // this object is to avoid recusive relationships calls
    NSMutableDictionary *managedObjectJSONCache = [[NSMutableDictionary alloc] init];
    return [self dictionaryWithManagedObjectDictionary:managedObjectJSONCache];
}

+ (NSManagedObject *)updateOrCreateWithDictionary: (NSDictionary *)jsonDic
                                           entity: (NSEntityDescription *)entity
                                          context: (NSManagedObjectContext *)context
{
    
    NSDictionary *userInfo = entity.userInfo;
    
    NSDictionary *objectRelationships = [entity relationshipsByName];
    NSMutableDictionary *relationshipObjectsDic = [[NSMutableDictionary alloc] init];
    
    // check relationship property & get relationship objects
    for (NSString *relationKey in objectRelationships) {
        NSString *jsonRelationKey = [userInfo valueForKey:relationKey];
        NSString *theKey = jsonRelationKey ? :relationKey;
        id object = [jsonDic objectForKey:theKey];
        if (!object) {
            continue;
        }
        
        NSMutableArray *newRelationshipObjectIDs = [[NSMutableArray alloc] init];
        NSRelationshipDescription *relationshipDescription = objectRelationships[relationKey];
        NSEntityDescription *relationShipEntity = relationshipDescription.entity;
        
        if ([object isKindOfClass:[NSArray class]]) {
            NSArray *jsonObjects = [jsonDic objectForKey:theKey];
            
            for (NSDictionary *objectDic in jsonObjects) {
                id returnObject = [self updateOrCreateWithDictionary:objectDic context:context];
                if (returnObject) {
                    [newRelationshipObjectIDs addObject:[returnObject objectID]];
                }
            }
            
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDic = [jsonDic objectForKey:theKey];
            id returnObject = [self updateOrCreateWithDictionary:objDic entity:relationShipEntity context:context];
            [newRelationshipObjectIDs addObject:[returnObject objectID]];
        } else {
            NSLog(@"WOW it should not be called");
            NSAssert(FALSE, @"WOW it should not be called");
        }
        if (newRelationshipObjectIDs.count) {
            [relationshipObjectsDic setObject:newRelationshipObjectIDs forKey:relationKey];
        }
    }
    
    NSManagedObjectContext* writeContext = context;
    
    __block id fetchedObject = nil;
    
    
    NSString *lookupKey = [userInfo valueForKey:@"uniqueKey"];
    
    // find existing object.
    if (lookupKey) {
        NSError *error;
        NSString *jsonLookupKey = [userInfo valueForKey:lookupKey];
        jsonLookupKey = jsonLookupKey? : lookupKey;
        NSFetchRequest* request  = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", lookupKey, [jsonDic objectForKey:jsonLookupKey]]];
        
        NSArray* results = [writeContext executeFetchRequest:request error:&error];
        
        
        if (results && results.count) {
            fetchedObject = [results objectAtIndex:0];
        }
    }
    
    BOOL localIsNew = NO;
    // if it does not exist
    if (!fetchedObject) {
        // insert a new one
        fetchedObject = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:writeContext];
        localIsNew = YES;
    }
    
    
    if (fetchedObject) {
        NSDictionary *objectAttributes = [entity attributesByName];
        for (NSString *propKey in objectAttributes) {
            NSString *jsonPropKey = [userInfo valueForKey:propKey];
            id val = [jsonDic objectForKey:jsonPropKey?:propKey];
            if (val) {
                [fetchedObject setValue:val forKey:propKey];
            }
        }
        
        for (NSString *relationshipKey in relationshipObjectsDic) {
            NSArray *newRelationshipObjectIDs = [relationshipObjectsDic objectForKey:relationshipKey];
            NSMutableSet *relationSet = [[NSMutableSet alloc] init];
            NSRelationshipDescription *relationshipDescription = objectRelationships[relationshipKey];
            
            for (NSManagedObjectID *mngObjID in newRelationshipObjectIDs){
                NSManagedObject *relationObject = [writeContext objectWithID:mngObjID];
                [relationSet addObject:relationObject];
            }
            
            if ([relationshipDescription isToMany]) {
                [fetchedObject setValue:relationSet forKey:relationshipKey];
            } else {
                NSManagedObject *relationObject = [relationSet anyObject];
                if (relationObject) {
                    [fetchedObject setValue:relationObject forKey:relationshipKey];
                } else {
                    [fetchedObject removeObjectForKey:relationshipKey];
                }
            }
        }
    }
    
    NSError* error = nil;
    if (fetchedObject && localIsNew) {
        // Occasionally the parent context tries to increment the ref count of this
        // object before it got its permanent objectID and then crashes. To prevent this,
        // let's get the permanent objectID now:
        if ( ! [writeContext obtainPermanentIDsForObjects:@[fetchedObject] error:&error]) {
            NSLog(@"Error obtaining permanent objectIDs: %@", error);
            return nil;
        }
    }
    
    return fetchedObject;
}

// to call this method, please make it sure that you've already called this method in "saveOnWritingQueueWithBlock" !!!
// ???: What does the comment above mean?
+ (BOOL)updateOrCreateWithDictionaries: (NSArray *)jsonDicArray
                                entity: (NSEntityDescription *)entity
                               context: (NSManagedObjectContext *)context
{
    if (jsonDicArray.count == 0) {
        return NO;
    }
    
    for (NSDictionary *jsonDic in jsonDicArray) {
        [self updateOrCreateWithDictionary:jsonDic entity:entity context:context];
    }
    
    return YES;
}

+ (BOOL)deleteWithDictionary: (NSDictionary *)jsonDic
                      entity: (NSEntityDescription *)entity
                     context: (NSManagedObjectContext *)context
{
    if (jsonDic == nil) {
        return NO;
    }
    return [self deleteWithDictionaries:@[jsonDic] entity:entity context:context];
}

+ (BOOL)deleteWithDictionaries: (NSArray *)jsonDicArray
                        entity: (NSEntityDescription *)entity
                       context: (NSManagedObjectContext *)context
{
    if (jsonDicArray.count == 0) {
        return NO;
    }
    
    NSDictionary *userInfo = entity.userInfo;
    
    NSString *lookupKey = [userInfo valueForKey:@"uniqueKey"];
    
    if (!lookupKey) {
        return NO;
    }
    
    NSManagedObjectContext* writeContext = context;
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSMutableString *predicateString = [[NSMutableString alloc] init];
    
    NSString *jsonLookupKey = [userInfo valueForKey:lookupKey];
    jsonLookupKey = jsonLookupKey? : lookupKey;
    
    NSUInteger index = 0;
    for (NSDictionary *jsonPropDic in jsonDicArray) {
        [predicateString appendFormat:@"%@ = %@", lookupKey, [jsonPropDic objectForKey:jsonLookupKey]];
        index++;
        if (index < jsonDicArray.count) {
            [predicateString appendString:@" || "];
        }
    }
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:predicateString];
    
    
    NSError *error;
    NSArray* results = [writeContext executeFetchRequest:request error:&error];
    if (!error) {
        
        for (NSManagedObject *object in results) {
            [writeContext deleteObject:object];
            
        }
        return YES;
    }
    
    return YES;
}



#pragma mark - Private

- (NSMutableDictionary *)attributesDictionary
{
    NSMutableDictionary *attributeDict = [[NSMutableDictionary alloc] init];
    NSDictionary *userInfo = self.entity.userInfo;
    NSDictionary *objectAttributes = [self.entity attributesByName];
    for (NSString *attributeKey in objectAttributes) {
        NSString *jsonPropKey = [userInfo valueForKey:attributeKey];
        id val = [self valueForKey:attributeKey];
        if (val && [val isKindOfClass:[NSObject class]]) {
            [attributeDict setValue:val forKey:jsonPropKey?:attributeKey];
#warning handle this property.
        } else if (val) {
            // show message to handle this property.
        } else {
            // show message no value for key
        }
    }
    
    return attributeDict;
}

- (NSMutableDictionary *)relationshipWithPropertyDictionary:(NSMutableDictionary *)managedObjectJSONCache
{
    NSDictionary *userInfo = self.entity.userInfo;
    NSMutableDictionary *relationshipDict = [[NSMutableDictionary alloc] init];
    NSDictionary *objectRelationships = self.entity.relationshipsByName;
    
    for (NSString *relationshipKey in objectRelationships) {
        NSRelationshipDescription *relationshipDescription = objectRelationships[relationshipKey];
        NSString *jsonPropKey = [userInfo valueForKey:relationshipKey];
        if ([relationshipDescription isToMany]) {
            NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            [relationshipDict setValue:tmpArray forKey:jsonPropKey?:relationshipKey];// if jsonPropKey nil use relationshipKey else jsonPropKey
            NSSet *relationshipSet = [self valueForKey:relationshipKey];
            for (NSManagedObject *mngObj in relationshipSet) {
                NSDictionary *relationObjDict = [mngObj dictionaryWithManagedObjectDictionary:managedObjectJSONCache];
                if (relationObjDict) {
                    [tmpArray addObject:relationObjDict];
                }
            }
            
        } else {
            NSManagedObject *relationObj = [self valueForKey:relationshipKey];
            NSDictionary *relationObjDict = [relationObj dictionaryWithManagedObjectDictionary:managedObjectJSONCache];
            if (relationObjDict) {
                [relationshipDict setObject:relationObjDict forKey:jsonPropKey?:relationshipKey];
            }
        }
    }
    return relationshipDict;
}

- (NSMutableDictionary *)dictionaryWithManagedObjectDictionary:(NSMutableDictionary *)managedObjectJSONCache
{
    NSString *uriKey = [[[self objectID] URIRepresentation] absoluteString];
    NSDictionary* resultDictionary = [managedObjectJSONCache valueForKey:uriKey];
    if (resultDictionary) {
        NSLog(@"WARNING - CoreData Entity (%@) has recursive relationship", self.entity.name);
        return [resultDictionary mutableCopy];
    }
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [managedObjectJSONCache setObject:jsonDict forKey:uriKey];
    NSMutableDictionary *attributesDict = [self attributesDictionary];
    if (attributesDict) {
        [jsonDict setValuesForKeysWithDictionary:attributesDict];
    }
    
    NSMutableDictionary *relationshipDict = [self relationshipWithPropertyDictionary:managedObjectJSONCache];
    if (relationshipDict) {
        [jsonDict setValuesForKeysWithDictionary:relationshipDict];
    }
    
    return jsonDict;
}

@end





#pragma mark - We should move this into the MOGenerator template.

/**
 These methods all depend on the presence of the +entityInManagedObjectContext: method which
 is usually code-generated by MOGenerator (given the right template).
 
 We should probably ged rid of this category and move all methods into our MOGenerator template file.
 */
@implementation NSManagedObject (S2MAdditions_toBeMovedToMOGeneratorTemplate)

// TODO: Remove this method. It should be available via the MOGenerator template.
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_
{
#warning use mogenerator
    return nil;
}

// TODO: Remove this method. Put it into the MOGenerator template.
+ (NSManagedObject *)updateOrCreateWithDictionary:(NSDictionary *)jsonDic context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [[self class] entityInManagedObjectContext:context];
    return [self updateOrCreateWithDictionary:jsonDic entity:entity context:context];
}

// TODO: Remove this method. Put it into the MOGenerator template.
+ (BOOL)updateOrCreateWithDictionaries:(NSArray *)jsonDicArray context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [[self class] entityInManagedObjectContext:context];
    return [self updateOrCreateWithDictionaries:jsonDicArray entity:entity context:context];
}

// TODO: Remove this method. Put it into the MOGenerator template.
+ (BOOL)deleteWithDictionary:(NSDictionary *)jsonDic context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [[self class] entityInManagedObjectContext:context];
    return [self deleteWithDictionary:jsonDic entity:entity context:context];
}

// TODO: Remove this method. Put it into the MOGenerator template.
+ (BOOL)deleteWithDictionaries:(NSArray *)jsonDicArray context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [[self class] entityInManagedObjectContext:context];
    return [self deleteWithDictionaries:jsonDicArray entity:entity context:context];
}

@end
