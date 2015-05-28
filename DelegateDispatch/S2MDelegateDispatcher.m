//
//  S2MDelegateDispatcher.m
//  DelegateDispatch
//
//  Created by Nils Grabenhorst on 22/05/15.
//  Copyright (c) 2015 SinnerSchrader-Mobile. All rights reserved.
//

#import "S2MDelegateDispatcher.h"
#import "S2MProtocolIntrospector.h"
#import <ObjC/runtime.h>

@interface S2MDelegateDispatcher ()

@property (nonatomic, strong) NSHashTable *delegates;
@property (nonatomic, strong) S2MProtocolIntrospector *protocolIntrospector;
@property (nonatomic) Protocol *delegateProtocol;
@end

@implementation S2MDelegateDispatcher

- (instancetype)initWithDelegateProtocol:(Protocol *)protocol
{
	NSParameterAssert(protocol);
	if (self) {
		self.delegateProtocol = protocol;
	}
	return self;
}

#pragma mark - Public

- (void)addDelegate:(id)delegate
{
	NSAssert([delegate conformsToProtocol:self.delegateProtocol], @"You can only add delegates conforming to %@.", self.delegateProtocol);
	if ([delegate conformsToProtocol:self.delegateProtocol]) {
		[self.delegates addObject:delegate];
	}
}

- (void)removeDelegate:(id)delegate
{
	[self.delegates removeObject:delegate];
}

- (BOOL)isRegisteredAsDelegate:(id)delegate
{
	return [self.delegates containsObject:delegate];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@<%@> (current delegates: %@)", NSStringFromClass(self.class), NSStringFromProtocol(self.delegateProtocol), self.delegates];
}



#pragma mark - Accessors

- (void)setDelegateProtocol:(Protocol *)delegateProtocol {
	_delegateProtocol = delegateProtocol;
	self.protocolIntrospector = [[S2MProtocolIntrospector alloc] initWithProtocol:delegateProtocol];
}

- (NSHashTable *)delegates
{
	if (!_delegates) {
		_delegates = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory | NSHashTableObjectPointerPersonality
												 capacity:1];
		
	}
	return _delegates;
}

- (NSUInteger)delegateCount
{
	// the count of an NSHashTable does not update if a collection member has been deallocated and therefore zeroed out. Hence we need to count allObjects to get the correct number.
	return [[self.delegates allObjects] count];
}



#pragma mark - HOM

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
	return protocol_isEqual(aProtocol, self.delegateProtocol);
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	if ([self.protocolIntrospector protocolDeclaresMethodForSelector:aSelector]) {
		return YES;
	}
	return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	for (id delegate in self.delegates) {
		if ([delegate respondsToSelector:anInvocation.selector]) {
			[anInvocation invokeWithTarget:delegate];
		}
	}
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	NSAssert(self.protocolIntrospector, @"There is no protocolIntrospector!");
	NSMethodSignature *signature = [self.protocolIntrospector protocolMethodSignatureForSelector:aSelector];
	
	if (!signature) {
		signature = [super methodSignatureForSelector:aSelector];
	}
	NSAssert(signature, @"Could not get a method description for the selector '%@' from protocol '%@'.", NSStringFromSelector(aSelector), NSStringFromProtocol(self.delegateProtocol));
	
	return signature;
}




@end
