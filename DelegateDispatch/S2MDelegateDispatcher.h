//
//  S2MDelegateDispatcher.h
//  DelegateDispatch
//
//  Created by Nils Grabenhorst on 22/05/15.
//  Copyright (c) 2015 SinnerSchrader-Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DelegateDispatcherCallback)();

@protocol S2MDelegateDispatcher
@property (nonatomic, readonly) NSUInteger delegateCount;

/**
 Adds a delegate to an internal list of delegates.
 @param delegate The delegate @b must conform to the protocol that was provided when initializing an instance of this RFMessageTrampoline.
 */
- (void)addDelegate:(id)delegate;


/**
 Removes a delegate from the internal list of delegates.
 */
- (void)removeDelegate:(id)delegate;
/**
 Removes a delegate from the internal list of delegates, calls callback in case the last delegate was removed.
 */
- (void)removeDelegate:(id)delegate noDelegatesLeftCallback:(DelegateDispatcherCallback) callback;

- (BOOL)isRegisteredAsDelegate:(id)delegate;
@end





/**
 Forwards messages to multiple delegates.
 The messages must belong to a given protocol.
 Works for instance methods only, not for class methods.
 
 @note Each delegate can only be added once. Pointer equality is checked to determine whether a delegate can be added to the list. Two separate objects with the same hash and returning \c YES for \c isEqual can therefore be added to the list of delegates.
 
 @warning The return value of a message is undefined. Only the return value of the last delegate is returned to the sender of a message. Since the order of delegates called is undefined, it is best to only specify methods that do not return anything in the given protocol.
 */
@interface S2MDelegateDispatcher : NSProxy <S2MDelegateDispatcher>
- (instancetype)initWithDelegateProtocol:(Protocol *)protocol;
@end




