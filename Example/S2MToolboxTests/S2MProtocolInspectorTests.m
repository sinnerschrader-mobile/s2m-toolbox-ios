//
//  S2MProtocolInspectorTests.m
//  DelegateDispatcher
//
//  Created by Nils Grabenhorst on 26/05/15.
//  Copyright (c) 2015 SinnerSchrader-Mobile. All rights reserved.
//

@import Foundation;
@import XCTest;
#import "S2MProtocolIntrospector.h"

@protocol SuperTestProtocol <NSObject>
- (void)inheritedMandatoryMethod;
@optional
- (void)inheritedOptionalMethod;
@end

@protocol TestProtocol <SuperTestProtocol>
- (void)mandatoryMethod;
@optional
- (void)optionalMethod;
@end


@interface S2MProtocolInspectorTests : XCTestCase
@property (nonatomic, strong) S2MProtocolIntrospector *sut;
@end

@implementation S2MProtocolInspectorTests

- (void)setUp {
    [super setUp];
	self.sut = [[S2MProtocolIntrospector alloc] initWithProtocol:@protocol(TestProtocol)];
}

- (void)tearDown {
	self.sut = nil;
    [super tearDown];
}



#pragma mark - Checking if protocol declares methods
- (void)testKnowsAboutMandatoryMethod
{
	XCTAssertTrue([self.sut protocolDeclaresMethodForSelector:@selector(mandatoryMethod)]);
}

- (void)testKnowsThatMethodIsNotInProtocol
{
	XCTAssertFalse([self.sut protocolDeclaresMethodForSelector:@selector(stringByAppendingString:)]);
}

- (void)testKnowsAboutOptionalMethod
{
	XCTAssertTrue([self.sut protocolDeclaresMethodForSelector:@selector(optionalMethod)]);
}

- (void)testKnowsAboutInheritedMandatoryMethod
{
	XCTAssertTrue([self.sut protocolDeclaresMethodForSelector:@selector(inheritedMandatoryMethod)]);
}

- (void)testKnowsAboutInheritedOptionalMethod
{
	XCTAssertTrue([self.sut protocolDeclaresMethodForSelector:@selector(inheritedOptionalMethod)]);
}



#pragma mark - Getting method signatures
- (void)testFindsMethodSignatureForMandatoryMethod
{
	NSMethodSignature *signature = [self.sut protocolMethodSignatureForSelector:@selector(mandatoryMethod)];
	XCTAssertNotNil(signature);
}

- (void)testReturnsNoSignatureIfMethodNotDeclared
{
	NSMethodSignature *signature = [self.sut protocolMethodSignatureForSelector:@selector(stringByAppendingString:)];
	XCTAssertNil(signature);
}

- (void)testFindsMethodSignatureForOptionalMethod
{
	NSMethodSignature *signature = [self.sut protocolMethodSignatureForSelector:@selector(optionalMethod)];
	XCTAssertNotNil(signature);
}

- (void)testFindsMethodSignatureForInheritedMandatoryMethod
{
	NSMethodSignature *signature = [self.sut protocolMethodSignatureForSelector:@selector(inheritedMandatoryMethod)];
	XCTAssertNotNil(signature);
}

- (void)testFindsMethodSignatureForInheritedOptionalMethod
{
	NSMethodSignature *signature = [self.sut protocolMethodSignatureForSelector:@selector(inheritedOptionalMethod)];
	XCTAssertNotNil(signature);
}

@end
