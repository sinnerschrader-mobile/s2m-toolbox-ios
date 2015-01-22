//
//  S2MNotificationViewController.m
//  S2MToolbox
//
//  Created by ParkSanggeon on 22/01/15.
//  Copyright (c) 2015 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MNotificationViewController.h"
#import "S2MNotificationHelper.h"

static NSString *CellIdentifier = @"TableViewCell";

@interface S2MNotificationViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *notifications;
@end


@implementation S2MNotificationViewController


#pragma mark - Accessors

- (void)setNotifications:(NSArray *)notifications
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"s2mKey" ascending:YES];
    _notifications = [notifications sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

#pragma mark - IBActions

- (IBAction)removeAllNotifications:(id)sender
{
    [S2MNotificationHelper removeAllNotifications];
    self.notifications = [S2MNotificationHelper allNotifications];
}

- (IBAction)reloadTableView:(id)sender
{
    self.notifications = [S2MNotificationHelper allNotifications];
}

- (IBAction)addLocalNotification:(id)sender
{
    NSString *keyForCache = [@([[NSDate date] timeIntervalSince1970]) stringValue];
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertAction = @"Let's Check";
    notification.alertBody = [NSString stringWithFormat:@"Test\n%@\n%@", [NSDate date], keyForCache];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    [notification setS2mKey:keyForCache];
    [S2MNotificationHelper showNotification:notification];
    self.notifications = [S2MNotificationHelper allNotifications];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILocalNotification *noti = self.notifications[indexPath.row];
    cell.textLabel.text = noti.alertBody;
    cell.textLabel.numberOfLines = 0;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notifications.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Notification"
                                                    message:@"Do you really want remove this notification?"
                                                   delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.tag = indexPath.row;
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [S2MNotificationHelper removeNotification:self.notifications[alertView.tag]];
        self.notifications = [S2MNotificationHelper allNotifications];
    }
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UIApplication *application = [UIApplication sharedApplication];
    BOOL authorized = YES;
    
    if ([application respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings* settings = [[UIApplication sharedApplication] performSelector:@selector(currentUserNotificationSettings) withObject:nil];
        authorized = (settings.types & UIUserNotificationTypeAlert);
    }
    
    if (!authorized && [application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.notifications = [S2MNotificationHelper allNotifications];
}


@end
