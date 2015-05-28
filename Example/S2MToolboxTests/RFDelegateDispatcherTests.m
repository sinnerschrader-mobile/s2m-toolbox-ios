//
//  RFDelegateDispatcherTests.m
//  MessageTrampoline
//
//  Created by Nils Grabenhorst on 27/05/15.
//  Copyright (c) 2015 SinnerSchrader-Mobile. All rights reserved.
//

@import Foundation;
@import XCTest;
#import "RFDelegateDispatcher.h"

@protocol TestDelegateProtocol <NSObject>
- (void)testMethodWithStringArgument:(NSString *)string;
@optional
- (void)optionalTestMethodWithStringArgument:(NSString *)argument;
@end

@interface Delegate : NSObject<TestDelegateProtocol>
@property (nonatomic, strong) NSMutableArray *arguments;
@end
@implementation Delegate
- (void)testMethodWithStringArgument:(NSString *)argument {
	[self.arguments addObject:argument];
}

- (BOOL)isEqual:(id)object {
	if ([object class] == [self class]) {
		return YES;
	}
	return [super isEqual:object];
}

- (NSUInteger)hash {
	return 1;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_arguments = [[NSMutableArray alloc] init];
	}
	return self;
}
@end

@interface DelegateWithOptionalMethod : Delegate
@end
@implementation DelegateWithOptionalMethod
- (void)optionalTestMethodWithStringArgument:(NSString *)argument {
	[self.arguments addObject:argument];
}
@end





@interface RFDelegateDispatcherTests : XCTestCase {
	id<RFDelegateDispatcher, TestDelegateProtocol> sut;
}

@end

@implementation RFDelegateDispatcherTests

- (void)setUp {
    [super setUp];
	sut = (id)[[RFDelegateDispatcher alloc] initWithDelegateProtocol:@protocol(TestDelegateProtocol)];
}

- (void)tearDown {
	sut = nil;
    [super tearDown];
}



#pragma mark - Registering, Deregistering Delegates

- (void)testCanRegisterDelegate
{
	// given
	Delegate *delegate = [[Delegate alloc] init];
	
	// when
	[sut addDelegate:delegate];
	
	// then
	XCTAssertTrue([sut isRegisteredAsDelegate:delegate]);
	XCTAssertEqual([sut delegateCount], 1);
}

- (void)testCanUnregisterDelegate
{
	// given
	Delegate *delegate = [[Delegate alloc] init];
	[sut addDelegate:delegate];
	
	// when
	[sut removeDelegate:delegate];
	
	// then
	XCTAssertFalse([sut isRegisteredAsDelegate:delegate]);
	XCTAssertEqual([sut delegateCount], 0);
}

- (void)testDoesNotRetainDelegate
{
	@autoreleasepool {
		// given
		Delegate *delegate = [[Delegate alloc] init];
		[sut addDelegate:delegate];
		
		// when
		delegate = nil;
	}
	
	// then
	XCTAssertEqual([sut delegateCount], 0);
}

- (void)testCanRegisterDelegateOnlyOnce
{
	// given
	Delegate *delegate = [[Delegate alloc] init];
	
	// when
	[sut addDelegate:delegate];
	[sut addDelegate:delegate];
	
	// then
	XCTAssertTrue([sut isRegisteredAsDelegate:delegate]);
	XCTAssertEqual([sut delegateCount], 1);
}

- (void)testCanRegisterTwoDifferentDelegatesThatAreEqual
{
	// given
	Delegate *delegate1 = [[Delegate alloc] init];
	Delegate *delegate2 = [[Delegate alloc] init];
	
	// when
	[sut addDelegate:delegate1];
	[sut addDelegate:delegate2];
	
	// then
	XCTAssertTrue([sut isRegisteredAsDelegate:delegate1]);
	XCTAssertTrue([sut isRegisteredAsDelegate:delegate2]);
	XCTAssertEqual([sut delegateCount], 2);
}



#pragma mark - Passing Messages

- (void)testMessageIsPassedOnToDelegates
{
	// given
	Delegate *delegate = [[Delegate alloc] init];
	[sut addDelegate:delegate];
	
	DelegateWithOptionalMethod *delegateWithOptional = [[DelegateWithOptionalMethod alloc] init];
	[sut addDelegate:delegateWithOptional];
	
	NSString *argument = @"cool";
	
	// when
	[sut testMethodWithStringArgument:argument];
	
	// then
	XCTAssertEqualObjects(delegate.arguments, @[argument]);
	XCTAssertEqualObjects(delegateWithOptional.arguments, @[argument]);
}

- (void)testOptionalMessageIsPassedOnlyToInterestedDelegates
{
	// given
	Delegate *delegate = [[Delegate alloc] init];
	[sut addDelegate:delegate];
	
	DelegateWithOptionalMethod *delegateWithOptional = [[DelegateWithOptionalMethod alloc] init];
	[sut addDelegate:delegateWithOptional];
	
	NSString *argument = @"cool";
	
	// when
	[sut optionalTestMethodWithStringArgument:argument];
	
	// then
	XCTAssertEqualObjects(delegate.arguments, @[]);
	XCTAssertEqualObjects(delegateWithOptional.arguments, @[argument]);
}

- (void)testMessagesAreNotPassedToUnregisteredDelegates
{
	// given
	Delegate *delegate = [[Delegate alloc] init];
	[sut addDelegate:delegate];
	
	NSString *argument1 = @"whileRegistered";
	NSString *argument2 = @"afterUnregistering";
	
	// when
	[sut testMethodWithStringArgument:argument1];
	[sut removeDelegate:delegate];
	[sut testMethodWithStringArgument:argument2];
	
	// then
	XCTAssertEqualObjects(delegate.arguments, @[argument1]);
}


@end
