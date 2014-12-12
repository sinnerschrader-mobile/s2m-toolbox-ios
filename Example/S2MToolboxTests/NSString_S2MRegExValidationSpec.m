//
//  NSString_S2MRegExValidationSpec.m
//  S2MToolbox
//
//  Created by François Benaiteau on 11/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kiwi.h"

SPEC_BEGIN(NSString_S2MRegExValidation)

describe(@"s2m_isValidEmailFormatString", ^{
    __block NSString* givenEmail;
    context(@"Given an empty string", ^{
        beforeAll(^{
            givenEmail = @"";
        });
        it(@"is not valid", ^{
            [[theValue([givenEmail s2m_isValidEmailFormatString]) should] beFalse];
        });
    });
    context(@"Given an string without domain extension", ^{
        beforeAll(^{
            givenEmail = @"email@domain";
        });
        it(@"is not valid", ^{
            [[theValue([givenEmail s2m_isValidEmailFormatString]) should] beFalse];
        });
    });
    context(@"Given an string without @ symbol", ^{
        beforeAll(^{
            givenEmail = @"emaildomain";
        });
        it(@"is not valid", ^{
            [[theValue([givenEmail s2m_isValidEmailFormatString]) should] beFalse];
        });
    });
    context(@"Given an string with @ symbol and domain extension", ^{
        beforeAll(^{
            givenEmail = @"email@domain.com";
        });
        it(@"is valid", ^{
            [[theValue([givenEmail s2m_isValidEmailFormatString]) should] beTrue];
        });
    });

    context(@"Given an string with . symbol", ^{
        beforeAll(^{
            givenEmail = @"first.lastname@domain.com";
        });
        it(@"is valid", ^{
            [[theValue([givenEmail s2m_isValidEmailFormatString]) should] beTrue];
        });
    });

    context(@"Given an string with + symbol", ^{
        beforeAll(^{
            givenEmail = @"first.lastname+spam@domain.com";
        });
        it(@"is valid", ^{
            [[theValue([givenEmail s2m_isValidEmailFormatString]) should] beFalse];
        });
    });

});
SPEC_END
