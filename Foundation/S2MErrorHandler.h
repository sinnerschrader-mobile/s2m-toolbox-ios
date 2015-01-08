//
//  S2MErrorHandler.h
//  S2MToolbox
//
//  Created by Uli Luckas on 7/31/12.
//  Copyright (c) 2012 SinnerSchrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol S2MErrorHandler <NSObject>
-(void)handleError:(NSError*)error;
@end
