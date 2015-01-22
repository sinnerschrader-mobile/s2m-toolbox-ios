//
//  S2MNotificationHelper.m
//  S2MToolbox
//
//  Created by ParkSanggeon on 21/01/15.
//  Copyright (c) 2015 S2M. All rights reserved.
//

#import "S2MNotificationHelper.h"
#import "NSString+S2MNotificationHelper.h"

#define CACHE_FOLDER_NAME @"S2M_NOTIFICATION_HELPER_CACHE"

@implementation S2MNotificationHelper

#pragma mark - private API

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+ (BOOL)addSkipBackupAttributeToItemAtFilePath:(NSString*)path
{
    NSURL* url = [NSURL fileURLWithPath:path];
    return [self addSkipBackupAttributeToItemAtURL:url];
}

+ (NSString *)cacheFolderPath
{
    static NSString *documentsPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [documentsPaths objectAtIndex:0];
        
        documentsPath = [documentsPath stringByAppendingPathComponent:CACHE_FOLDER_NAME];
        if (![[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        [self addSkipBackupAttributeToItemAtFilePath:documentsPath];
    });
    return documentsPath;
}

+ (NSString *)cachePathWithKey:(NSString *)key
{
    NSString *cacheHash = [key s2m_hashString];
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@", [self cacheFolderPath], cacheHash];
    return archivePath;
}

+ (BOOL)hasCacheForKey:(NSString *)key
{
    NSString *archivePath = [self cachePathWithKey:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:archivePath]) {
        return YES;
    }
    return NO;
}

+ (void)cacheObject:(id<NSCoding>)obj forKey:(NSString *)key
{
    NSString *archivePath = [self cachePathWithKey:key];
    [NSKeyedArchiver archiveRootObject:obj toFile:archivePath];
}

+ (id<NSCoding>)cacheForKey:(NSString *)key
{
    NSString *archivePath = [self cachePathWithKey:key];
    return !archivePath ? nil : [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
}

+ (NSArray *)allCachePaths
{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSMutableArray *paths = [NSMutableArray array];
    NSString *folderPath = [self cacheFolderPath];
    NSDirectoryEnumerator* enumerator = [fileManager enumeratorAtPath:folderPath];
    NSError* err = nil;
    BOOL res;
    NSString* file;
    
    while (file = [enumerator nextObject]) {
        [paths addObject:[folderPath stringByAppendingPathComponent:file]];
    }
    return paths;
}

+ (void) removeAllCaches
{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSArray *cachePaths = [self allCachePaths];
    NSError* err = nil;
    BOOL res;
    
    for (NSString *path in cachePaths) {
        res = [fileManager removeItemAtPath:path error:&err];
        if (!res && err) {
            NSLog(@"Can't remove Notification: %@", err);
        }
    }
}

+ (NSArray *)allCaches
{
    NSMutableArray *caches = [NSMutableArray array];
    NSArray *cachePaths = [self allCachePaths];
    NSError* err = nil;
    
    for (NSString *path in cachePaths) {
        id cacheObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!cacheObject) {
            NSLog(@"Can't read cache object: %@", err);
        } else {
            [caches addObject:cacheObject];
        }
    }
    return caches;
}

#pragma mark - public API

+ (UILocalNotification *)localNotificationForKey:(NSString *)key userInfo:(NSDictionary *)userInfo
{
    NSNumber *badge = nil;
    NSString *sound = nil;
    NSString *launchImage = nil;
    NSString *actionString = nil;
    
    NSString *alertString = nil;
    NSDictionary *alertDict = nil;
    id alert = [userInfo objectForKey:@"alert"];
    
    if ([alert isKindOfClass:[NSString class]]) {
        alertString = (NSString *)alert;
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        alertDict = (NSDictionary *)alert;
    }
    
    // handle alert dictionary
    if (alertDict) {
        
        NSString *bodyString = [alertDict objectForKey:@"body"];
        if (bodyString == nil) { // with some reason, it may have 0 length string.
            NSString *localizedStringKey = [alertDict objectForKey:@"loc-key"];
            NSArray *arguments = [alertDict objectForKey:@"loc-args"];
            if (arguments && [arguments isKindOfClass:[NSString class]]) {
                arguments = @[arguments];
            }
            
            if (arguments.count && localizedStringKey.length) {
                alertString = [NSString s2m_stringWithFormat:NSLocalizedString(localizedStringKey, nil) array:arguments];
            } else if (localizedStringKey.length) {
                alertString = NSLocalizedString(localizedStringKey, nil);
            }
        } else {
            alertString = bodyString;
        }
        
        NSString *actionStringKey = [alertDict objectForKey:@"action-loc-key"];
        if (actionString.length) {
            actionString = NSLocalizedString(actionStringKey, nil);
        }
        
        badge = [userInfo objectForKey:@"badge"];
        sound = [userInfo objectForKey:@"sound"];
        launchImage = [userInfo objectForKey:@"launch-image"];
    }
    
    // create LocalNotification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];

    if (actionString) {
        localNotification.alertAction = actionString;
    } else {
        localNotification.hasAction = NO;
    }
    
    localNotification.alertBody = alertString;
    localNotification.soundName = sound;
    localNotification.alertLaunchImage = launchImage;
    localNotification.applicationIconBadgeNumber = [badge integerValue];
    localNotification.userInfo = userInfo;
    localNotification.fireDate = [NSDate date];

    [localNotification setS2mKey:key];
    
    return localNotification;
}

+ (BOOL)showNotification:(UILocalNotification *)notification;
{
    return [self showNotification:notification withKey:notification.s2mKey];
}

+ (BOOL)showNotification:(UILocalNotification *)notification withKey:(NSString *)key
{
    if (key.length == 0 || notification == nil) {
        return NO;
    }
    
    [self cacheObject:notification forKey:key];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    return YES;
}

+ (BOOL)removeNotification:(UILocalNotification *)notification
{
    return [self removeNotificationForKey:notification.s2mKey];
}

+ (BOOL)removeNotificationForKey:(NSString *)key
{
    if (key.length == 0) {
        return NO;
    }
    
    NSString *archivePath = [self cachePathWithKey:key];
    
    UILocalNotification *cachedNotification = [self notificationForKey:key];
    if (cachedNotification == nil) {
        return NO;
    }
    
    [[UIApplication sharedApplication] cancelLocalNotification:cachedNotification];
    
    [[NSFileManager defaultManager] removeItemAtPath:archivePath error:nil];
    
    return YES;
}

+ (void)removeAllNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self removeAllCaches];
}

+ (UILocalNotification *)notificationForKey:(NSString *)key
{
    if ([self hasCacheForKey:key] == NO) {
        return nil;
    }
    return (UILocalNotification *)[self cacheForKey:key];
}

+ (NSArray *)allNotifications
{
   return [self allCaches];
}

@end
