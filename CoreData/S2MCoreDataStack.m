//
//  S2MCoreDataStack.m
//  S2MToolbox
//
//
//  Copyright (c) 2013 SinnerSchrader-Mobile. All rights reserved.
//

#import "S2MCoreDataStack.h"

NSString *const kSQLiteFilename = @"S2MStore.sqlite";
NSString *const kModelName = @"S2MModel";

@interface S2MCoreDataStack ()
@property (nonatomic, strong) NSManagedObjectContext *writingManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;
@property (nonatomic, assign, readwrite) S2MCoreDataStackOptions options;
@end

@implementation S2MCoreDataStack

- (instancetype)initWithOptions:(S2MCoreDataStackOptions)options
{
    self = [super init];
    if (self) {
        self.options = options;
    }
    return self;
}

#pragma mark - Private

- (NSURL *)storeURL
{
	NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [documentsPaths objectAtIndex:0];
	NSString *storePath = [documentsPath stringByAppendingPathComponent:kSQLiteFilename];
	
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    return storeURL;
}

- (BOOL)setUpCoreDataStackError:(NSError **)error
{

	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSURL *url = [bundle URLForResource:kModelName withExtension:@"momd"];
    NSAssert(url, @"no model found in bundle");
    
	NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

    if (self.options & S2MCoreDataStackOptionsAdvancedStack) {
        self.backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.backgroundManagedObjectContext.persistentStoreCoordinator = psc;
    }

    self.mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    if (self.options & S2MCoreDataStackOptionsAdvancedStack) {
        self.mainManagedObjectContext.parentContext = self.backgroundManagedObjectContext;
    }else{
        self.mainManagedObjectContext.persistentStoreCoordinator = psc;
    }
    
    self.writingManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.writingManagedObjectContext.parentContext = self.mainManagedObjectContext;
	
	NSURL *storeURL = [self storeURL];

    if (self.options & S2MCoreDataStackOptionsForceRemoveDB) {
        if (![self removeFileAtURL:storeURL error:error]) {
            return NO;
        }
    }

    if (self.options & S2MCoreDataStackOptionsCopyInitialDB) {
        if (![self copyInitialDatabaseWithError:error]) {
            return NO;
        }
    }

	NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
							NSInferMappingModelAutomaticallyOption: @YES,
							NSSQLiteAnalyzeOption: @YES};
	
	NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType
												 configuration:nil
														   URL:storeURL
													   options:options
														 error:error];

	return store ? YES : NO;
}

- (BOOL)removeFileAtURL:(NSURL*)fileURL error:(NSError**)pError
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[fileURL path]]) {
        BOOL success = [fileManager removeItemAtURL:fileURL error:pError];
        if (!success && pError && *pError) {
            NSLog(@"Error deleting the old store: %@", *pError);
        }
        return success;
    }
    // file does not exist so let's not make a fuss of it and move on, shall we.
    return YES;
}

- (BOOL)saveToDisk:(NSError**)error
{
    if (self.backgroundManagedObjectContext) {
        return [self.backgroundManagedObjectContext save:error];
    }else{
        return [self.mainManagedObjectContext save:error];
    }
}

- (BOOL)copyInitialDatabaseWithError:(NSError**)pError
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.storeURL path]])
    {
        return NO; // skip copy database already exists
    }
    
    NSURL* fileURL;
    
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
	NSArray* sqliteFiles = [bundle URLsForResourcesWithExtension:@"sqlite" subdirectory:nil];

    NSAssert(sqliteFiles.count > 0, @"no databases files found in Bundle");
    fileURL = sqliteFiles[0];

    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[self storeURL] error:pError];
    if (success && !(self.options & S2MCoreDataStackOptionsBackupToiCloud)) {
        [self addSkipBackupAttributeToItemAtURL:[self storeURL]];
    }
    return success;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (NSManagedObjectContext*)cleanWritingManagedObjectContext
{
    [self.writingManagedObjectContext rollback];
    return self.writingManagedObjectContext;
}
@end
