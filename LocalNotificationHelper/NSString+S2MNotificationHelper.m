//
//  NSString+S2MNotificationHelper.m
//  S2MToolbox
//
//  Created by ParkSanggeon on 21/01/15.
//  Copyright (c) 2015 S2M. All rights reserved.
//

#import "NSString+S2MNotificationHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (S2MNotificationHelper)

+ (instancetype)s2m_stringWithFormat:(NSString *)format arguments:(NSArray*)arguments;
{
    NSRange range = NSMakeRange(0, [arguments count]);
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(id) * [arguments count]];
    [arguments getObjects:(__unsafe_unretained id *)data.mutableBytes range:range];
    NSString* result = [[NSString alloc] initWithFormat:format arguments:data.mutableBytes];
    return result;
}

- (NSString *)s2m_hashString
{
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)(strlen(ptr)), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
