//
//  TURAnnotationView.m
//  Example
//
//  Created by Joern Ehmann on 06/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "TURAnnotationView.h"


const CGFloat kRightArrowWidth = 30;
const CGFloat kHeight = 60;
const CGFloat kWidth = 200;
const CGFloat kBottomArrowInset = 6;

@interface TURAnnotationView()

@property (nonatomic, strong) UIImageView *left;
@property (nonatomic, strong) UIButton *right;

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *bottomLabel;

@property (nonatomic, weak) MKMapView *mapView;

@end

@implementation TURAnnotationView

-(CGSize)intrinsicContentSize{
    return CGSizeMake(kWidth,kHeight);
}


-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    }];
    
}

-(void)callOutTapped:(id)sender
{
    if([self.mapView.delegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]){
        [self.mapView.delegate mapView:self.mapView annotationView:self calloutAccessoryControlTapped:sender];
    }
}

-(void)addLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_left, _right, _topLabel, _bottomLabel);
    for (UIView* view in views.allValues){
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_left]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_right]-(6)-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_left][_right(30)]|" options:0 metrics:nil views:views]];

    [self.left addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_topLabel][_bottomLabel(==_topLabel)]-(14)-|" options:0 metrics:nil views:views]];
    [self.left addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topLabel]|" options:0 metrics:nil views:views]];
    [self.left addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomLabel]|" options:0 metrics:nil views:views]];

    
}

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier mapView:(MKMapView *)mapView{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self){
        self.mapView = mapView;
        self.centerOffset = CGPointMake(kRightArrowWidth/2.0f, -kHeight);
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [[UIColor redColor] CGColor];
        self.frame = CGRectMake(0, 0, kWidth, kHeight);
        self.alpha = 0;
        
        self.left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_pin_bg"]];
        [self addSubview:self.left];
        
        
        
        self.right = [UIButton buttonWithType:UIButtonTypeCustom];
        self.right.frame = CGRectMake(0, 0, 30, 54);
        self.right.backgroundColor = [UIColor blueColor];
        [self.right addTarget:self action:@selector(callOutTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.right setImage:[UIImage imageNamed:@"icn_arrow_link_white"] forState:UIControlStateNormal];
        [self addSubview:self.right];
        
        
        self.topLabel = [[UILabel alloc] init];
        self.topLabel.text = @"Top";
        self.bottomLabel = [[UILabel alloc] init];
        self.bottomLabel.text = @"Bottom";
        
        [self.left addSubview:self.topLabel];
        [self.left addSubview:self.bottomLabel];
        
        [self addLayout];
    }
    return self;
}


@end
