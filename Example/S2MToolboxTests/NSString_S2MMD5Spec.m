//
//  NSString_S2MMD5Spec.m
//  S2MToolbox
//
//  Created by François Benaiteau on 11/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kiwi.h"

SPEC_BEGIN(NSString_S2MMD5)
describe(@"s2m_MD5", ^{
    __block NSString* givenString;
    __block NSString* md5OfGivenString;
    context(@"Given an empty string", ^{
        beforeAll(^{
            givenString = @"";
            md5OfGivenString = [givenString s2m_MD5];
        });
        it(@"returns a string representing its md5", ^{
            [[md5OfGivenString should] equal:@"d41d8cd98f00b204e9800998ecf8427e"];
        });
    });
    context(@"Given a valid string", ^{
        beforeAll(^{
            givenString = @"md5";
            md5OfGivenString = [givenString s2m_MD5];
        });
        it(@"returns the md5 representation of that string", ^{
            [[md5OfGivenString should] equal:@"1bc29b36f623ba82aaf6724fd3b16718"];
        });
    });
});
SPEC_END
