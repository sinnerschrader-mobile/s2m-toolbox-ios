//
//  S2MProtocolIntrospector.h
//  DelegateDispatch
//
//  Created by Nils Grabenhorst on 22/05/15.
//  Copyright (c) 2015 SinnerSchrader-Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface S2MProtocolIntrospector : NSObject

- (BOOL)protocolDeclaresMethodForSelector:(SEL)aSelector;
- (NSMethodSignature *)protocolMethodSignatureForSelector:(SEL)aSelector;

- (instancetype)initWithProtocol:(Protocol *)protocol NS_DESIGNATED_INITIALIZER;

@end
