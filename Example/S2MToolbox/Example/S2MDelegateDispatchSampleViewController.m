//
//  S2MDelegateDispatchSampleViewController.m
//  S2MToolbox
//
//  Created by Nils Grabenhorst on 28/05/15.
//  Copyright (c) 2015 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MDelegateDispatchSampleViewController.h"
#import "S2MDelegateDispatcher.h"

@interface S2MDelegateDispatchSampleViewController ()
@property (nonatomic) NSUInteger tapCount;
@end

@implementation S2MDelegateDispatchSampleViewController

- (IBAction)buttonTapped:(id)sender {
	++self.tapCount;
	[self.delegateDispatcher viewController:self didUpdateTapCount:self.tapCount];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.delegateDispatcher = (id)[[S2MDelegateDispatcher alloc] initWithDelegateProtocol:@protocol(S2MViewControllerDelegate)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.destinationViewController conformsToProtocol:@protocol(S2MViewControllerDelegate) ]) {
		[self.delegateDispatcher addDelegate:segue.destinationViewController];
	}
}

@end
