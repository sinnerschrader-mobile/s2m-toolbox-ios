//
//  S2MProtocolIntrospector.m
//  DelegateDispatch
//
//  Created by Nils Grabenhorst on 22/05/15.
//  Copyright (c) 2015 SinnerSchrader-Mobile. All rights reserved.
//

#import "S2MProtocolIntrospector.h"
#import <ObjC/runtime.h>
#import <libkern/OSAtomic.h>

@interface S2MProtocolIntrospector () {
	CFDictionaryRef _signatures;
}
@property (nonatomic) Protocol *protocol;
@property (nonatomic) CFDictionaryRef signatures;
@end

@implementation S2MProtocolIntrospector

#pragma mark - Lifecycle

- (instancetype)initWithProtocol:(Protocol *)protocol {
	self = [super init];
	if (self) {
		_protocol = protocol;
	}
	return self;
}

#pragma mark - Public

- (BOOL)protocolDeclaresMethodForSelector:(SEL)aSelector {
	return [self protocolMethodSignatureForSelector:aSelector] != nil;
}

- (NSMethodSignature *)protocolMethodSignatureForSelector:(SEL)aSelector {
	return CFDictionaryGetValue(self.signatures, aSelector);
}


#pragma mark - Accessors

- (CFDictionaryRef)signatures {
	if (!_signatures) {
		_signatures = [self methodSignaturesForProtocol:self.protocol];
	}
	return _signatures;
}

#pragma mark - Private

// See https://github.com/steipete/PSTDelegateProxy
static CFMutableDictionaryRef _protocolCache = nil;
static OSSpinLock _lock = OS_SPINLOCK_INIT;

- (CFDictionaryRef)methodSignaturesForProtocol:(Protocol *)protocol {
	OSSpinLockLock(&_lock);
	// Cache lookup
	if (!_protocolCache) _protocolCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
	CFDictionaryRef signatureCache = CFDictionaryGetValue(_protocolCache, (__bridge const void *)(protocol));
	
	if (!signatureCache) {
		// Add protocol methods + derived protocol method definitions into protocolCache.
		signatureCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
		[self methodSignaturesForProtocol:protocol inDictionary:(CFMutableDictionaryRef)signatureCache];
		CFDictionarySetValue(_protocolCache, (__bridge const void *)(protocol), signatureCache);
		CFRelease(signatureCache);
	}
	OSSpinLockUnlock(&_lock);
	return signatureCache;
}

- (void)methodSignaturesForProtocol:(Protocol *)protocol inDictionary:(CFMutableDictionaryRef)cache {
	void (^enumerateRequiredMethods)(BOOL) = ^(BOOL isRequired) {
		unsigned int methodCount;
		struct objc_method_description *descr = protocol_copyMethodDescriptionList(protocol, isRequired, YES, &methodCount);
		for (NSUInteger idx = 0; idx < methodCount; idx++) {
			NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:descr[idx].types];
			CFDictionarySetValue(cache, descr[idx].name, (__bridge const void *)(signature));
		}
		free(descr);
	};
	// We need to enumerate both required and optional protocol methods.
	enumerateRequiredMethods(NO); enumerateRequiredMethods(YES);
	
	// There might be sub-protocols we need to catch as well.
	unsigned int inheritedProtocolCount;
	Protocol *__unsafe_unretained* inheritedProtocols = protocol_copyProtocolList(protocol, &inheritedProtocolCount);
	for (NSUInteger idx = 0; idx < inheritedProtocolCount; idx++) {
		[self methodSignaturesForProtocol:inheritedProtocols[idx] inDictionary:cache];
	}
	free(inheritedProtocols);
}


@end
