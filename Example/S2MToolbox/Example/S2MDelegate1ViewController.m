//
//  S2MDelegate1ViewController.m
//  S2MToolbox
//
//  Created by Nils Grabenhorst on 28/05/15.
//  Copyright (c) 2015 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MDelegate1ViewController.h"

@interface S2MDelegate1ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic) NSUInteger count;

@end

@implementation S2MDelegate1ViewController

- (void)setCount:(NSUInteger)count
{
	_count = count;
	self.label.text = [NSString stringWithFormat:@"%lu", _count];
}

- (void)viewController:(S2MDelegateDispatchSampleViewController *)viewController didUpdateTapCount:(NSUInteger)count
{
	self.count = count;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.count = 0;
}

@end
