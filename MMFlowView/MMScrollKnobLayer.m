//
//  MMScrollKnobLayer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.11.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMScrollKnobLayer.h"
#import "CALayer+NSAccessibility.h"

static NSString * const kLayerName = @"MMScrollKnobLayer";
static const CGFloat kKnobHeight = 16.;
static const CGFloat kMinimumWidth = 10.;
static const CGFloat kCornerRadius = 9.;

@implementation MMScrollKnobLayer

#pragma mark - private methods

- (void)setupActions
{
	// disable animation for position
	NSMutableDictionary *customActions = [NSMutableDictionary dictionaryWithDictionary:[self actions]];
	// add the new action for sublayers
	customActions[@"position"] = [NSNull null];
	customActions[@"bounds"] = [NSNull null];
	// set theLayer actions to the updated dictionary
	self.actions = customActions;
}

- (void)setupAccessibility
{
	// NSAccessibility
	[self setReadableAccessibilityAttribute:NSAccessibilityRoleAttribute withBlock:^id{
		return NSAccessibilityValueIndicatorRole;
	}];
}

- (void)setupInitialValues
{
	self.name = kLayerName;
	self.frame = CGRectMake(5, 2, kMinimumWidth, kKnobHeight);
	self.needsDisplayOnBoundsChange = YES;
	self.borderColor = [ [ NSColor grayColor ] CGColor ];
	self.borderWidth = 1.;
	self.cornerRadius = kCornerRadius;
	self.startPoint = CGPointMake(.5, 1);
	self.endPoint = CGPointMake(.5, 0);
	self.colors = @[(__bridge id)[ [ NSColor colorWithCalibratedRed:64.f / 255.f green:64.f / 255.f blue:74.f / 255.f alpha:1 ] CGColor ],
					(__bridge id)[[ NSColor colorWithCalibratedRed:46.f / 255.f green:46.f / 255.f blue:58.f / 255.f alpha:1.f ] CGColor ],
					(__bridge id)[[ NSColor colorWithCalibratedRed:37.f / 255.f green:37.f / 255.f blue:50.f / 255.f alpha:1.f ] CGColor ],
					(__bridge id)[[ NSColor colorWithCalibratedRed:51.f / 255.f green:52.f / 255.f blue:66.f / 255.f alpha:1.f ] CGColor ]];
	self.locations = @[@0., @.5, @.51, @1.];
	self.type = kCAGradientLayerAxial;
	[self setupActions];
	[self setupAccessibility];
}

#pragma mark - init/cleanup

- (id)init
{
    self = [super init];
    if (self) {
        [self setupInitialValues];
    }
    return self;
}

@end
