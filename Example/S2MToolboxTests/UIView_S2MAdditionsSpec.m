//
//  UIView_S2MAdditionsSpec.m
//  S2MToolbox
//
//  Created by François Benaiteau on 11/12/14.
//  Copyright 2014 Sinnerschrader Mobile. All rights reserved.
//

#import "Kiwi.h"


SPEC_BEGIN(UIView_S2MAdditionsSpec)

__block UIView* view;
beforeAll(^{
    view = [[UIView alloc] init];
});
describe(@"s2m_addView", ^{
    __block id result;
    beforeAll(^{
        view = [[UIView alloc] init];
        result = [view s2m_addView];
    });
    it(@"add a subview to current view", ^{
        [[theValue(view.subviews.count) should] equal:theValue(1)];
        [[view.subviews.firstObject should] beKindOfClass:[UIView class]];
    });
    it(@"returns the subview", ^{
        [[result should] beKindOfClass:[UIView class]];
    });
});

describe(@"s2m_addLabel", ^{
    __block id result;
    beforeAll(^{
        view = [[UIView alloc] init];
        result = [view s2m_addLabel];
    });
    it(@"add a label to current view", ^{
        [[theValue(view.subviews.count) should] equal:theValue(1)];
        [[view.subviews.firstObject should] beKindOfClass:[UILabel class]];
    });
    it(@"returns the label", ^{
        [[result should] beKindOfClass:[UILabel class]];
    });
});

describe(@"s2m_addTextField", ^{
    __block id result;
    beforeAll(^{
        view = [[UIView alloc] init];
        result = [view s2m_addTextField];
    });
    it(@"add a textfield to current view", ^{
        [[theValue(view.subviews.count) should] equal:theValue(1)];
        [[view.subviews.firstObject should] beKindOfClass:[UITextField class]];
    });
    it(@"returns the textfield", ^{
        [[result should] beKindOfClass:[UITextField class]];
    });
});

describe(@"s2m_addSwitch", ^{
    __block id result;
    beforeAll(^{
        view = [[UIView alloc] init];
        result = [view s2m_addSwitch];
    });
    it(@"add a switch to current view", ^{
        [[theValue(view.subviews.count) should] equal:theValue(1)];
        [[view.subviews.firstObject should] beKindOfClass:[UISwitch class]];
    });
    it(@"returns the switch", ^{
        [[result should] beKindOfClass:[UISwitch class]];
    });
});

describe(@"s2m_addButton", ^{
    __block id result;
    beforeAll(^{
        view = [[UIView alloc] init];
        result = [view s2m_addSwitch];
    });
    it(@"add a button to current view", ^{
        [[theValue(view.subviews.count) should] equal:theValue(1)];
        [[view.subviews.firstObject should] beKindOfClass:[UISwitch class]];
    });
    it(@"returns the button", ^{
        [[result should] beKindOfClass:[UISwitch class]];
    });
});

describe(@"s2m_addImage:", ^{
    __block id result;
    beforeAll(^{
        view = [[UIView alloc] init];
        result = [view s2m_addImage:[[UIImage alloc] init]];
    });
    it(@"add a imageView to current view", ^{
        [[theValue(view.subviews.count) should] equal:theValue(1)];
        [[view.subviews.firstObject should] beKindOfClass:[UIImageView class]];
    });
    it(@"returns the imageView", ^{
        [[result should] beKindOfClass:[UIImageView class]];
    });
});

describe(@"s2m_addImageNamed:", ^{
    __block id result;
    beforeAll(^{
        view = [[UIView alloc] init];
        result = [view s2m_addImageNamed:nil];
    });
    it(@"add a imageView to current view", ^{
        [[theValue(view.subviews.count) should] equal:theValue(1)];
        [[view.subviews.firstObject should] beKindOfClass:[UIImageView class]];
    });
    it(@"returns the imageView", ^{
        [[result should] beKindOfClass:[UIImageView class]];
    });
});

describe(@"s2m_addSearchBar", ^{
    __block id result;
    beforeAll(^{
        view = [[UIView alloc] init];
        result = [view s2m_addSearchBar];
    });
    it(@"add a searchBar to current view", ^{
        [[theValue(view.subviews.count) should] equal:theValue(1)];
        [[view.subviews.firstObject should] beKindOfClass:[UISearchBar class]];
    });
    it(@"returns the searchBar", ^{
        [[result should] beKindOfClass:[UISearchBar class]];
    });
});

describe(@"s2m_addTableView", ^{
    __block id result;
    beforeAll(^{
        view = [[UIView alloc] init];
        result = [view s2m_addTableView];
    });
    it(@"add a searchBar to current view", ^{
        [[theValue(view.subviews.count) should] equal:theValue(1)];
        [[view.subviews.firstObject should] beKindOfClass:[UITableView class]];
    });
    it(@"returns the searchBar", ^{
        [[result should] beKindOfClass:[UITableView class]];
    });
});

describe(@"s2m_addActivityIndicatorView", ^{
    __block id result;
    beforeAll(^{
        view = [[UIView alloc] init];
        result = [view s2m_addActivityIndicatorView];
    });
    it(@"add a searchBar to current view", ^{
        [[theValue(view.subviews.count) should] equal:theValue(1)];
        [[view.subviews.firstObject should] beKindOfClass:[UIActivityIndicatorView class]];
    });
    it(@"returns the searchBar", ^{
        [[result should] beKindOfClass:[UIActivityIndicatorView class]];
    });
});
SPEC_END
