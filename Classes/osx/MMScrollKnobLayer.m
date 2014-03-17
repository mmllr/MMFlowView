/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://github.com/mmllr All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this
 software and associated documentation files (the "Software"), to deal in the Software
 without restriction, including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies
 or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
 
 */
//
//  MMScrollKnobLayer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.11.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMScrollKnobLayer.h"
#import "CALayer+NSAccessibility.h"
#import "CALayer+MMAdditions.h"

static NSString * const kLayerName = @"MMScrollKnobLayer";
static const CGFloat kKnobHeight = 16.;
static const CGFloat kMinimumWidth = 40.;
static const CGFloat kCornerRadius = 9.;

@implementation MMScrollKnobLayer

#pragma mark - private methods

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
	[self mm_disableImplicitPositionAndBoundsAnimations];
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
