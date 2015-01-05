//
//  S2MTextLoadingView.h
//  S2MToolbox
//
//  Created by François Benaiteau on 12/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <S2MToolbox/S2MRefreshControl.h>

@interface S2MTextLoadingView : UIView<S2MControlLoadingView>
@property(nonatomic, strong)UILabel* label;
@property(nonatomic, strong, readonly)NSTimer* timer;
@end
