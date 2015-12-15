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

/// This queue is used to assure serial access to the delegates hashTable.
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@end

@implementation S2MDelegateDispatcher

- (instancetype)initWithDelegateProtocol:(Protocol *)protocol
{
	NSParameterAssert(protocol);
	if (self) {
		_serialQueue = dispatch_queue_create("com.sinnerschrader-mobile.delegateDispatcher.accessSerializationQueue", DISPATCH_QUEUE_SERIAL);
		
		_delegateProtocol = protocol;
		_protocolIntrospector = [[S2MProtocolIntrospector alloc] initWithProtocol:_delegateProtocol];
		_delegates = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory | NSHashTableObjectPointerPersonality
												 capacity:1];
	}
	return self;
}

#pragma mark - Public

- (void)addDelegate:(id)delegate
{
	NSAssert([delegate conformsToProtocol:self.delegateProtocol], @"You can only add delegates conforming to %@.", self.delegateProtocol);
	if ([delegate conformsToProtocol:self.delegateProtocol]) {
		dispatch_sync(self.serialQueue, ^{
			[self.delegates addObject:delegate];
		});
	}
}

- (void)removeDelegate:(id)delegate
{
    [self removeDelegate:delegate noDelegatesLeftCallback:nil];
}

- (void)removeDelegate:(id)delegate noDelegatesLeftCallback:(DelegateDispatcherCallback) callback
{
	dispatch_sync(self.serialQueue, ^{
		[self.delegates removeObject:delegate];
		if (0 == [self unsafeDelegatesCount] && callback)
		{
			callback();
		}
	});
}

- (BOOL)isRegisteredAsDelegate:(id)delegate
{
	__block BOOL isRegistered = NO;
	dispatch_sync(self.serialQueue, ^{
		isRegistered = [self.delegates containsObject:delegate];
	});
	return isRegistered;
}

- (NSString *)description
{
	NSString *__block description;
	dispatch_sync(self.serialQueue, ^{
		description = [NSString stringWithFormat:@"%@<%@> (current delegates: %@)", NSStringFromClass(self.class), NSStringFromProtocol(self.delegateProtocol), self.delegates];
	});
	return description;
}



#pragma mark - Accessors

- (NSUInteger)delegateCount
{
	__block NSUInteger count;
	dispatch_sync(self.serialQueue, ^{
		count = [self unsafeDelegatesCount];
	});
	return count;
}

/** MUST be used from inside self.serialQueue only! */
- (NSUInteger)unsafeDelegatesCount
{
	// the count of an NSHashTable does not update if a collection member has been deallocated and therefore zeroed out. Hence we need to count allObjects to get the correct number.
	return [self.delegates allObjects].count;
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
	NSArray *__block allDelegates;
	dispatch_sync(self.serialQueue, ^{
		allDelegates = [self.delegates allObjects];
	});
	
	for (id delegate in allDelegates) {
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
