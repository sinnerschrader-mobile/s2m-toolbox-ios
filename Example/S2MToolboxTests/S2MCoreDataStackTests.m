#import <XCTest/XCTest.h>

#import "S2MCoreDataStack.h"
#import "NSManagedObject+S2MAdditions.h"
@interface S2MCoreDataStack (PrivateInterfaceToTest)
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;
@property (nonatomic, assign, readwrite) S2MCoreDataStackOptions options;

- (NSURL*)storeURL;
@end


@interface Article : NSManagedObject {}
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@end

@implementation Article

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Article" inManagedObjectContext:moc_];
}
@end

@interface S2MCoreDataStackTests : XCTestCase
@property(nonatomic, strong) S2MCoreDataStack* stack;
@end

@implementation S2MCoreDataStackTests

- (void)tearDown
{
    [super tearDown];
    [self.stack removeDatabaseWithError:nil];
    self.stack = nil;
}

- (void)testNoOptionsIsDefault
{
    self.stack = [[S2MCoreDataStack alloc] init];
    XCTAssertEqual(self.stack.options, S2MCoreDataStackOptionsNone, @"has no options");
}

- (void)testSetUpCoreDataStackError
{
    self.stack = [[S2MCoreDataStack alloc] init];
    
    NSError* error = nil;
    BOOL success = [self.stack setUpCoreDataStackError:&error];
    
    XCTAssertTrue(success, @"setup Stack should be successful");
    XCTAssertNil(error, @"no error should come up");
    XCTAssertNotNil(self.stack.mainManagedObjectContext, @"should have a mainContext");
    XCTAssertNotNil(self.stack.writingManagedObjectContext, @"should have a writingContext");
    XCTAssertNil(self.stack.backgroundManagedObjectContext, @"should not have a backgroundContext");
}


- (void)testSetUpCoreDataStackWithAdvancedOption
{
    self.stack = [[S2MCoreDataStack alloc] initWithOptions:S2MCoreDataStackOptionsAdvancedStack];

    NSError* error = nil;
    BOOL success = [self.stack setUpCoreDataStackError:&error];

    XCTAssertTrue(success, @"setup Stack should be successful");
    XCTAssertNil(error, @"no error should come up");
    XCTAssertNotNil(self.stack.mainManagedObjectContext, @"should have a mainContext");
    XCTAssertNotNil(self.stack.writingManagedObjectContext, @"should have a writingContext");
    XCTAssertNotNil(self.stack.backgroundManagedObjectContext, @"should have a backgroundContext");

    // avoid the "xcode did not finish tests"
//    [self waitForTimeout:1];
}

- (void)testSetUpCoreDataStackWithAdvanceOptionAndRemoveCurrentDatabase
{
    self.stack = [[S2MCoreDataStack alloc] initWithOptions:S2MCoreDataStackOptionsAdvancedStack | S2MCoreDataStackOptionsForceRemoveDB];
    
    // prepare
    NSURL* dbFileURL = [self.stack storeURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[dbFileURL path]]) {
        [[NSFileManager defaultManager] removeItemAtURL:dbFileURL error:nil];
    }
    
    [[NSFileManager defaultManager] createFileAtPath:[dbFileURL path] contents:nil attributes:nil];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[dbFileURL path]]);
    NSData* fileData = [NSData dataWithContentsOfFile:[dbFileURL path]];
    
    // test
    [self.stack setUpCoreDataStackError:nil];
    
    // assert
    XCTAssertNotNil(self.stack.backgroundManagedObjectContext, @"should have a writingContext");
    
    
    NSData* expectedFileData = [NSData dataWithContentsOfFile:[dbFileURL path]];
    XCTAssertNotEqual(expectedFileData, fileData, @"should not have the same file");
}
// TODO try to test the copy
- (void)pendingCopyInitialDB
{
    self.stack = [[S2MCoreDataStack alloc] initWithOptions:S2MCoreDataStackOptionsCopyInitialDB| S2MCoreDataStackOptionsForceRemoveDB | S2MCoreDataStackOptionsBackupToiCloud];

    NSURL* copyURL = [self.stack storeURL];
    copyURL = [[copyURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"dbcopy.sqlite"];
    
    // S2MModel.sqlite is part of both bundle test and App
	NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.S2MApiProviderSampleApp"];
    NSURL* sqliteFileURL = [bundle URLForResource:@"S2MStore" withExtension:@"sqlite"];
    [[NSFileManager defaultManager] copyItemAtURL:sqliteFileURL toURL:copyURL error:nil];
//    NSData* sqliteContent = [NSData dataWithContentsOfURL:copyURL];
//    XCTAssertNotNil(sqliteContent, @"should have a copy file");

    // test
    [self.stack setUpCoreDataStackError:nil];
    XCTAssertTrue([[NSFileManager defaultManager] contentsEqualAtPath:[sqliteFileURL path] andPath:[[self.stack storeURL] path]], @"db from bundle should be copied");
    
    // clean up
    [[NSFileManager defaultManager] removeItemAtURL:copyURL error:nil];
    
    //NSData* actualSQLiteContent = [[NSFileManager defaultManager] contentsAtPath:[[self.stack storeURL] path]];
//    XCTAssertEqualObjects(actualSQLiteContent, sqliteContent, @"db should be copied");
    
}

#pragma mark - Saving Tests

- (void)testSavingAnArticleObjectToMainContextSaveToDisk
{
    // Given a normal stack
    self.stack = [[S2MCoreDataStack alloc] initWithOptions:S2MCoreDataStackOptionsForceRemoveDB];
    [self.stack setUpCoreDataStackError:nil];
    
    // save Object and assert no error
    [self articleObjectWithContext:self.stack.mainManagedObjectContext save:YES];

    // is Object really saved to disk
    self.stack = [[S2MCoreDataStack alloc] init];
    [self.stack setUpCoreDataStackError:nil];
    [self articleObjectSavedWithContext:self.stack.mainManagedObjectContext];
}

- (void)testSavingAnArticleObjectToWritingContextSavedToMainContext
{
    self.stack = [[S2MCoreDataStack alloc] initWithOptions:S2MCoreDataStackOptionsForceRemoveDB];
    [self.stack setUpCoreDataStackError:nil];
    
    // save Object and assert no error
    [self articleObjectWithContext:self.stack.writingManagedObjectContext save:YES];

    // is Object really saved to disk
    [self articleObjectSavedWithContext:self.stack.mainManagedObjectContext];
}

- (void)testAdvancedStackSavingWithMainContextSavedToBackgroundContext
{
    self.stack = [[S2MCoreDataStack alloc] initWithOptions:S2MCoreDataStackOptionsForceRemoveDB|S2MCoreDataStackOptionsAdvancedStack];
    [self.stack setUpCoreDataStackError:nil];
    
    // save Object and assert no error
    [self articleObjectWithContext:self.stack.mainManagedObjectContext save:YES];
    
    // is Object saved to parent context
    [self articleObjectSavedWithContext:self.stack.backgroundManagedObjectContext];
}

- (void)testNormalStackSaveToDisk
{
    self.stack = [[S2MCoreDataStack alloc] initWithOptions:S2MCoreDataStackOptionsForceRemoveDB];
    [self.stack setUpCoreDataStackError:nil];
    
    // create an Object in context without saving
    [self articleObjectWithContext:self.stack.mainManagedObjectContext save:NO];

    NSError* error = nil;
    [self.stack saveToDisk:&error];
    XCTAssertNil(error, @"should have no error");
    
    // is Object really saved to disk
    self.stack = [[S2MCoreDataStack alloc] init];
    [self.stack setUpCoreDataStackError:nil];
    [self articleObjectSavedWithContext:self.stack.mainManagedObjectContext];
}

- (void)testAdvancedStackSaveToDisk
{
    self.stack = [[S2MCoreDataStack alloc] initWithOptions:S2MCoreDataStackOptionsForceRemoveDB|S2MCoreDataStackOptionsAdvancedStack];
    [self.stack setUpCoreDataStackError:nil];
    
    // create an Object in mainContext and save to parent context aka backgroundContext
    [self articleObjectWithContext:self.stack.mainManagedObjectContext save:YES];
    
    NSError* error = nil;
    [self.stack saveToDisk:&error];
    XCTAssertNil(error, @"should have no error");
    
    // is Object really saved to disk
    self.stack = [[S2MCoreDataStack alloc] init];
    [self.stack setUpCoreDataStackError:nil];
    [self articleObjectSavedWithContext:self.stack.mainManagedObjectContext];

}

- (void)testConvertArticleObjectToJSONDictionary
{
    // Given a normal stack
    self.stack = [[S2MCoreDataStack alloc] initWithOptions:S2MCoreDataStackOptionsForceRemoveDB];
    [self.stack setUpCoreDataStackError:nil];
    
    // save Object and assert no error
    [self articleObjectWithContext:self.stack.mainManagedObjectContext save:YES];
    
    // is Object really saved to disk
    self.stack = [[S2MCoreDataStack alloc] init];
    [self.stack setUpCoreDataStackError:nil];
    [self articleObjectToJSONDictionaryWithContext:self.stack.mainManagedObjectContext];
}

- (void)testConvertJSONDictionaryToArticleObject
{
    // Given a normal stack
    self.stack = [[S2MCoreDataStack alloc] initWithOptions:S2MCoreDataStackOptionsForceRemoveDB];
    [self.stack setUpCoreDataStackError:nil];
    
    // save Object and assert no error
    [self articleObjectWithContext:self.stack.mainManagedObjectContext save:YES];
    
    // is Object really saved to disk
    self.stack = [[S2MCoreDataStack alloc] init];
    [self.stack setUpCoreDataStackError:nil];
    [self JSONDictionaryToArticleObjectWithContext:self.stack.mainManagedObjectContext];
}

#pragma mark - Helper methods

- (void)articleObjectWithContext:(NSManagedObjectContext*)context save:(BOOL)save
{
    NSString* entityName = @"Article";
    NSString* titleKey = @"title";
    NSString* titleValue = @"test title";
    NSManagedObject* article;

    article = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    [article setValue:titleValue forKey:titleKey];
    XCTAssertNotNil(article, @"should have an article");

    if (save) {
        NSError* error = nil;
        [context save:&error];
        XCTAssertNil(error, @"should have no error");
    }
}

- (void)articleObjectSavedWithContext:(NSManagedObjectContext*)context
{
    NSString* entityName = @"Article";
    NSString* titleKey = @"title";
    NSString* titleValue = @"test title";
    NSManagedObject* article;

    // test we actually saved the object in fetching it
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSArray* results = [self.stack.mainManagedObjectContext executeFetchRequest:request error:nil];
    
    XCTAssertEqualObjects(@(results.count), @1, @"we should have one article");
    if (results.count) {
        article = results[0];
        XCTAssertEqualObjects([article valueForKey:titleKey], titleValue, @"have the same title");
    }
}

- (void)articleObjectToJSONDictionaryWithContext:(NSManagedObjectContext*)context
{
    NSString* entityName = @"Article";
    NSString* titleKey = @"title";
    NSString* titleValue = @"test title";
    
    // test we actually saved the object in fetching it
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSArray* results = [self.stack.mainManagedObjectContext executeFetchRequest:request error:nil];
    
    XCTAssertEqualObjects(@(results.count), @1, @"we should have one article");
    if (results.count) {
        NSManagedObject *article = results[0];
        NSDictionary *jsonDict = article.jsonDictionary;
        XCTAssertEqualObjects([jsonDict valueForKey:titleKey], titleValue, @"have the same title");
    }
}

- (void)JSONDictionaryToArticleObjectWithContext:(NSManagedObjectContext*)context
{
    NSString* titleKey = @"title";
    NSString* titleValue = @"First Title";
    
    NSString* nextTitleValue = @"next Title";
    NSString* othersTitleValue = @"others Title";
    NSDictionary *jsonDic = @{@"title":titleValue,
                              @"next" : @{@"title":nextTitleValue},
                              @"others" : @[@{@"title":othersTitleValue}]};
    
    Article *article = (Article *)[Article updateOrCreateManagedObjectWithDictionary:jsonDic context:context];
    XCTAssertNotNil(article, @"cannot convert!!!");
    XCTAssertNil([article valueForKey:@"previous"], @"previous should be nil.");
    XCTAssertEqualObjects([[article valueForKey:@"next"] valueForKey:titleKey], nextTitleValue, @"have the same title");
    XCTAssertTrue([[article valueForKey:@"others"] isKindOfClass:[NSSet class]], @"it should be NSSet");
}
@end
