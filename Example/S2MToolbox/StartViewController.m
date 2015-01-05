//
//  StartViewController.m
//  S2MToolboxApp
//
//  Created by Joern Ehmann on 04/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "StartViewController.h"
#import "S2MShopFinderSearchDelegate.h"
#import "S2MViewController.h"
#import "S2MHockeyViewController.h"
#import "S2MFoldViewController.h"
#import "S2MFoldTransition.h"

static NSString *cellId = @"cellId2";

@interface StartViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) S2MShopFinderSearchDelegate *searchDelegate;

@end

@implementation StartViewController


#pragma mark TableView Datatsource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"QR";
    }else if(indexPath.row == 1){
        cell.textLabel.text = @"ShopFinder";
    }else if (indexPath.row == 2){
        cell.textLabel.text = @"AutoLayout Sample";
    }else if (indexPath.row == 3){
        cell.textLabel.text = @"Hockey App";
    }else if (indexPath.row == 4){
        cell.textLabel.text = @"S2M Fold Animator";
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        S2MQRViewController *vc = [[S2MQRViewController alloc] initWithDelegate:nil];
        vc.boundingImage = [UIImage imageNamed:@"qr"];
        vc.title = @"QR";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.row == 1){
        S2MShopFinderController *vc = [[S2MShopFinderController alloc] init];
        vc.title = @"ShopFinder";
        self.searchDelegate = [S2MShopFinderSearchDelegate new];
        vc.searchDelegate = self.searchDelegate;
        vc.locateButtonImage = [UIImage imageNamed:@"icn_location_active"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.row == 2){
        S2MViewController *vc = [[S2MViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row == 3){
        S2MHockeyViewController *vc = [[S2MHockeyViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 4){
        S2MFoldViewController* vc = [[S2MFoldViewController alloc] init];
        self.navigationController.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }

}


#pragma mark Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Start";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.translatesAutoresizingMaskIntoConstraints = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
}


#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if ([toVC isKindOfClass:[S2MFoldViewController class]] || [fromVC isKindOfClass:[S2MFoldViewController class]]) {
        S2MFoldTransition* transition = [S2MFoldViewController transitionAnimator];
        transition.foldAnimator.unfolding = operation == UINavigationControllerOperationPush;
        transition.foldAnimator.direction = operation == UINavigationControllerOperationPush ? S2MFoldAnimatorDirectionRightToLeft : S2MFoldAnimatorDirectionLeftToRight;
        return transition;
    }
    return nil;
}
@end
