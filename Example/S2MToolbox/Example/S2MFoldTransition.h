//
//  S2MFoldTransition.h
//  S2MToolbox
//
//  Created by François Benaiteau on 15/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "S2MFoldAnimator.h"

@interface S2MFoldTransition : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong)S2MFoldAnimator* foldAnimator;
@property (nonatomic, assign)BOOL interactive;
@end
