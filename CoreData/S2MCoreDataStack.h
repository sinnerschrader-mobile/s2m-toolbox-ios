//
//  S2MCoreDataStack.h
//  S2MToolbox
//
//
//  Copyright (c) 2013 SinnerSchrader-Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_OPTIONS(NSUInteger, S2MCoreDataStackOptions) {
    S2MCoreDataStackOptionsNone = 0,
    S2MCoreDataStackOptionsAdvancedStack = 1 << 0, // Uses an extra background NSManagedObjectContext to save objects between mainContext and PSC
    S2MCoreDataStackOptionsForceRemoveDB  = 1 << 1, // Removes any Database present in Documents while setUpCoreDataStackError executes
    S2MCoreDataStackOptionsCopyInitialDB  = 1 << 2, // Copy database file present in Bundle to Documents if no other database file is present.
    S2MCoreDataStackOptionsBackupToiCloud = 1 << 3 // Set this option if you want the database file to be backup by iCloud
};

@interface S2MCoreDataStack : NSObject

@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, assign, readonly) S2MCoreDataStackOptions options;

- (instancetype)initWithOptions:(S2MCoreDataStackOptions)options;
- (BOOL)setUpCoreDataStackError:(NSError **)error;
- (BOOL)saveToDisk:(NSError**)error;
- (NSManagedObjectContext*)cleanWritingManagedObjectContext;// will give the writingManagedContext rollbacked
@end
