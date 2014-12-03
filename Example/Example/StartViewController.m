//
//  StartViewController.m
//  S2MToolboxApp
//
//  Created by Joern Ehmann on 04/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "StartViewController.h"
#import <S2MToolbox/S2MQRController.h>

static NSString *cellId = @"cellId2";

@interface StartViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation StartViewController


#pragma mark TableView Datatsource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"QR";
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        S2MQRController *vc = [[S2MQRController alloc] initWithDelegate:nil];
        vc.boundingImage = [UIImage imageNamed:@"qr"];
        vc.title = @"QR";
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark Actions
-(void)openQr{
    S2MQRController *vc = [[S2MQRController alloc] initWithDelegate:nil];
    vc.boundingImage = [UIImage imageNamed:@"qr"];
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


@end
