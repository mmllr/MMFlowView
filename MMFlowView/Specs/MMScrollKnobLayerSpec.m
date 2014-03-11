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
//  MMScrollKnobLayerSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.11.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMScrollKnobLayer.h"

SPEC_BEGIN(MMScrollKnobLayerSpec)

describe(@"MMScrollKnobLayer", ^{
	context(@"a new instance", ^{
		__block MMScrollKnobLayer *sut = nil;

		beforeEach(^{
			sut = [MMScrollKnobLayer layer];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should be a CAGradientLayer class", ^{
			[[sut should] beKindOfClass:[CAGradientLayer class]];
		});
		it(@"should have a name of MMScrollKnobLayer", ^{
			[[sut.name should] equal:@"MMScrollKnobLayer"];
		});
		it(@"should have a height of 16", ^{
			[[theValue(CGRectGetHeight(sut.frame)) should] equal:theValue(16.)];
		});
		it(@"should have a width of 40", ^{
			[[theValue(CGRectGetWidth(sut.frame)) should] equal:theValue(40.)];
		});
		it(@"should display on bounds change", ^{
			[[theValue(sut.needsDisplayOnBoundsChange) should] beYes];
		});
		it(@"should have a gray border color", ^{
			[[[NSColor colorWithCGColor:sut.borderColor] should] equal:[NSColor grayColor]];
		});
		it(@"should have a border width of 1", ^{
			[[theValue(sut.borderWidth) should] equal:theValue(1.)];
		});
		it(@"should have corner radius of 9", ^{
			[[theValue(sut.cornerRadius) should] equal:theValue(9.)];
		});
		it(@"should have an anchorPoint of (0.5, 0.5)", ^{
			NSValue *expectedPoint = [NSValue valueWithPoint:CGPointMake(.5, .5)];
			[[[NSValue valueWithPoint:sut.anchorPoint] should] equal:expectedPoint];
		});
		it(@"should have a startPoint of (0.5, 1)", ^{
			NSValue *expectedPoint = [NSValue valueWithPoint:CGPointMake(0.5, 1.)];
			[[[NSValue valueWithPoint:sut.startPoint] should] equal:expectedPoint];
		});
		it(@"should have a startPoint of (0.5, 0)", ^{
			NSValue *expectedPoint = [NSValue valueWithPoint:CGPointMake(0.5, 0)];
			[[[NSValue valueWithPoint:sut.endPoint] should] equal:expectedPoint];
		});
		it(@"should have the gradient colors", ^{
			NSArray *expectedColors = @[(__bridge id)[ [ NSColor colorWithCalibratedRed:64.f / 255.f green:64.f / 255.f blue:74.f / 255.f alpha:1 ] CGColor ],
			  (__bridge id)[[ NSColor colorWithCalibratedRed:46.f / 255.f green:46.f / 255.f blue:58.f / 255.f alpha:1.f ] CGColor ],
			  (__bridge id)[[ NSColor colorWithCalibratedRed:37.f / 255.f green:37.f / 255.f blue:50.f / 255.f alpha:1.f ] CGColor ],
			  (__bridge id)[[ NSColor colorWithCalibratedRed:51.f / 255.f green:52.f / 255.f blue:66.f / 255.f alpha:1.f ] CGColor ]];
			[[sut.colors should] equal:expectedColors];
		});
		it(@"should have the gradient locations", ^{
			NSArray * expectedLocations = @[@0., @.5, @.51, @1.];
			[[sut.locations should] equal:expectedLocations];
		});
		it(@"should have an axial gradient type", ^{
			[[sut.type should] equal:kCAGradientLayerAxial];
		});
		context(@"CoreAnimation actions", ^{
			__block NSDictionary *actions = nil;
			beforeEach(^{
				actions = sut.actions;
			});
			afterEach(^{
				actions = nil;
			});
			it(@"should have disabled the implicit position action", ^{
				[[actions[@"position"] should] equal:[NSNull null]];
			});
			it(@"should have disabled the implicit bounds action", ^{
				[[actions[@"bounds"] should] equal:[NSNull null]];
			});
		});
		context(@"NSAccessibility", ^{
			it(@"should not be ignored", ^{
				[[theValue([sut accessibilityIsIgnored]) should] beNo];
			});
			it(@"should have a value indicator role", ^{
				[[[sut accessibilityAttributeValue:NSAccessibilityRoleAttribute] should] equal:NSAccessibilityValueIndicatorRole];
			});
			it(@"should be enabled", ^{
				[[[sut accessibilityAttributeValue:NSAccessibilityEnabledAttribute] should] beYes];
			});
		});
	});
});

SPEC_END
