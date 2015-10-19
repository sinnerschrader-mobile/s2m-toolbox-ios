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
    context(@"Given email Format accepting only numbers", ^{
        beforeAll(^{
            [NSString s2m_setEmailFormat:@"^\\d{3}$"];

        });
        it(@"123 is valid", ^{
            [[theValue([@"123" s2m_isValidEmailFormatString]) should] beTrue];
        });
        it(@"email@domain.com is not valid", ^{
            [[theValue([@"email@domain.com" s2m_isValidEmailFormatString]) should] beFalse];
        });

        afterAll(^{
            // reset to default value
            [NSString s2m_setEmailFormat:@"^[_a-z0-9-]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9-]+)*(\\.[a-z]{2,4})$"];
        });
    });
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
