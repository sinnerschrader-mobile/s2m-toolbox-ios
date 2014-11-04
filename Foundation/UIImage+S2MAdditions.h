//
//  UIImage+S2MQrCodeEncoding.h
//  MoreMobile
//
//  Created by Andreas Buff on 27/06/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (S2MAdditions)

/**
 *  Transform QRCode string to image
 *
 *  @param qrCode QR code to encode to image
 *  @param scale   scale to apply to the image
 *
 *  @return image representing a QR Code
 */
+ (instancetype)s2m_imageFromQRCode:(NSString *)stringToEncode scale:(CGFloat)scale;

/**
 *  Resize image with a given quality
 *
 *  @param quality image quality to use
 *  @param scale   scale to apply to the image
 *
 *  @return resized image
 */
- (UIImage *)s2m_imageWithQuality:(CGInterpolationQuality)quality
                            scale:(CGFloat)scale;

@end
