//
//  NSBundle+S2MAdditions.h
//  S2MToolbox
//
//  Created by Andreas Buff on 28/05/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (S2MAdditions)

/**
 *  Convenience methode to get the first UIView of the content of a nib (xib) file.
 *
 *  @param xibName Name of the xib file without extension
 *  @param owner   The object to assign as the nib’s File's Owner object.
 *
 *  @return First view in the xib file
 */
+ (UIView *)s2m_loadXibNamed:(NSString *)xibName
                       owner:(id)owner;

@end
