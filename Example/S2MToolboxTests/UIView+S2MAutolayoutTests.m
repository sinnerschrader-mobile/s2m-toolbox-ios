
#import <XCTest/XCTest.h>
#import "UIView+S2MAutolayout.h"

@interface UIView_S2MAutolayoutTests : XCTestCase

@property (nonatomic, weak) UIView *sut;
@property (nonatomic, strong) UIView *superView;
@end

@implementation UIView_S2MAutolayoutTests

- (void)setUp {
    [super setUp];
    self.superView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 640)];
	UILabel *label = [[UILabel alloc] init];
	[self.superView addSubview:label];
	self.sut = label;
}

- (void)tearDown {
	self.sut = nil;
	self.superView = nil;
    [super tearDown];
}



#pragma mark - s2m_addLeadingConstraint Tests

- (void)testAddLeadingConstraint_addsOneConstraintToSuperView {
	[self.sut s2m_addLeadingConstraint:10];
	
	XCTAssertEqual([self.superView.constraints count], 1);
}

- (void)testAddLeadingConstraint_addedConstraintIsReturnedConstraint {
	NSLayoutConstraint *returnedConstraint = [self.sut s2m_addLeadingConstraint:10];
	NSLayoutConstraint *addedConstraint = [self.superView.constraints firstObject];
	
	XCTAssertEqualObjects(returnedConstraint, addedConstraint);
}

- (void)testAddLeadingConstraint_addedConstraintDataIsCorrect {
	NSLayoutConstraint *constraint = [self.sut s2m_addLeadingConstraint:10];
	
	XCTAssertEqualObjects(constraint.firstItem, self.sut);
	XCTAssertEqual(constraint.firstAttribute, NSLayoutAttributeLeading);
	
	XCTAssertEqual(constraint.relation, NSLayoutRelationEqual);
	
	XCTAssertEqualObjects(constraint.secondItem, self.superView);
	XCTAssertEqual(constraint.secondAttribute, NSLayoutAttributeLeading);
	
	XCTAssertEqual(constraint.multiplier, 1.0);
	XCTAssertEqual(constraint.constant, 10);
	
	XCTAssertEqual(constraint.priority, 1000);
}

- (void)testAddLeadingConstraint_addedConstraintIsActive {
	NSLayoutConstraint *constraint = [self.sut s2m_addLeadingConstraint:10];
	
	XCTAssertEqual(constraint.active, YES);
}



#pragma mark - s2m_addTrailingConstraint Tests

- (void)testAddTrailingConstraint_addsOneConstraintToSuperView {
	[self.sut s2m_addTrailingConstraint:10];
	
	XCTAssertEqual([self.superView.constraints count], 1);
}

- (void)testAddTrailingConstraint_addedConstraintIsReturnedConstraint {
	NSLayoutConstraint *returnedConstraint = [self.sut s2m_addTrailingConstraint:10];
	NSLayoutConstraint *addedConstraint = [self.superView.constraints firstObject];
	
	XCTAssertEqualObjects(returnedConstraint, addedConstraint);
}

- (void)testAddTrailingConstraint_addedConstraintDataIsCorrect {
	NSLayoutConstraint *constraint = [self.sut s2m_addTrailingConstraint:10];
	
	XCTAssertEqualObjects(constraint.firstItem, self.sut);
	XCTAssertEqual(constraint.firstAttribute, NSLayoutAttributeTrailing);
	
	XCTAssertEqual(constraint.relation, NSLayoutRelationEqual);
	
	XCTAssertEqualObjects(constraint.secondItem, self.superView);
	XCTAssertEqual(constraint.secondAttribute, NSLayoutAttributeTrailing);
	
	XCTAssertEqual(constraint.multiplier, 1.0);
	XCTAssertEqual(constraint.constant, 10);
	
	XCTAssertEqual(constraint.priority, 1000);
}

- (void)testAddTrailingConstraint_addedConstraintIsActive {
	NSLayoutConstraint *constraint = [self.sut s2m_addTrailingConstraint:10];
	
	XCTAssertEqual(constraint.active, YES);
}


@end
