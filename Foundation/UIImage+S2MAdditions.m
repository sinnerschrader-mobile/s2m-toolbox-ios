//
//  UIImage+S2MQrCodeEncoding.m
//  MoreMobile
//
//  Created by Andreas Buff on 27/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "UIImage+S2MAdditions.h"

@implementation UIImage (S2MAdditions)

+ (instancetype)s2m_imageFromQRCode:(NSString *)stringToEncode scale:(CGFloat)scale
{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [stringToEncode dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1.0
                                   orientation:UIImageOrientationUp];
    // Resize without interpolating
    UIImage *qrCode = [image s2m_imageWithQuality:kCGInterpolationNone scale:scale];
    CGImageRelease(cgImage);
    
    return qrCode;
}

- (UIImage *)s2m_imageWithQuality:(CGInterpolationQuality)quality
                            scale:(CGFloat)scale
{
    UIImage *resized = nil;
    CGFloat width = self.size.width * scale;
    CGFloat height = self.size.height * scale;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [self drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

@end
