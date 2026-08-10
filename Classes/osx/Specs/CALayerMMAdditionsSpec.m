/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://codeberg.org/mmllr All rights reserved.
 
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
//  CALayerMMAdditionsSpec.m
//
//  Created by Markus Müller on 21.01.14.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CALayer+MMAdditions.h"

@interface CALayerMMAdditionsSpec : XCTestCase

@end

@implementation CALayerMMAdditionsSpec

- (CALayer *)makeSut
{
	CALayer *sut = [CALayer layer];
	sut.frame = CGRectMake(20, 30, 200, 400);
	return sut;
}

- (void)testRespondsToMMEnableImplicitAnimationForKey
{
	CALayer *sut = [self makeSut];
	XCTAssertTrue([sut respondsToSelector:@selector(mm_enableImplicitAnimationForKey:)]);
}

- (void)testMMEnableImplicitAnimationForKeyRemovesKeyFromCustomActions
{
	CALayer *sut = [self makeSut];
	NSDictionary *customActions = @{@"position": [NSNull null],
									@"anchorPoint": [NSNull null]};
	sut.actions = customActions;

	[sut mm_enableImplicitAnimationForKey:@"position"];

	XCTAssertNil(sut.actions[@"position"]);
	XCTAssertEqual(sut.actions[@"anchorPoint"], [NSNull null]);
}

- (void)testRespondsToMMDisableImplicitAnimationForKey
{
	CALayer *sut = [self makeSut];
	XCTAssertTrue([sut respondsToSelector:@selector(mm_disableImplicitAnimationForKey:)]);
}

- (void)testMMDisableImplicitAnimationForKeySetsNullWithNoCustomActions
{
	CALayer *sut = [self makeSut];

	[sut mm_disableImplicitAnimationForKey:@"bounds"];

	XCTAssertEqual(sut.actions[@"bounds"], [NSNull null]);
}

- (void)testMMDisableImplicitAnimationForKeySetsNullWithCustomActions
{
	CALayer *sut = [self makeSut];
	NSDictionary *customActions = @{@"position": [NSNull null],
									@"anchorPoint": [NSNull null]};
	sut.actions = customActions;

	[sut mm_disableImplicitAnimationForKey:@"bounds"];

	XCTAssertEqual(sut.actions[@"bounds"], [NSNull null]);
	XCTAssertEqual(sut.actions[@"position"], [NSNull null]);
	XCTAssertEqual(sut.actions[@"anchorPoint"], [NSNull null]);
}

- (void)testMMDisableImplicitPositionAndBoundsAnimations
{
	CALayer *sut = [self makeSut];
	[sut mm_disableImplicitPositionAndBoundsAnimations];

	XCTAssertEqual(sut.actions[@"position"], [NSNull null]);
	XCTAssertEqual(sut.actions[@"bounds"], [NSNull null]);
}

- (void)testMMEnableImplicitPositionAndBoundsAnimations
{
	CALayer *sut = [self makeSut];
	[sut mm_disableImplicitPositionAndBoundsAnimations];
	[sut mm_enableImplicitPositionAndBoundsAnimations];

	XCTAssertNil(sut.actions[@"position"]);
	XCTAssertNil(sut.actions[@"bounds"]);
}

- (void)testMMBoundingRectReturnsFrameWithoutSublayers
{
	CALayer *sut = [self makeSut];
	XCTAssertTrue(CGRectEqualToRect([sut mm_boundingRect], sut.frame));
}

- (void)testMMBoundingRectIncludesSublayersFrames
{
	CALayer *sut = [self makeSut];

	CALayer *sublayerA = [CALayer layer];
	sublayerA.frame = CGRectMake(-100, -100, 1000, 444);
	CALayer *sublayerB = [CALayer layer];
	sublayerB.frame = CGRectMake(0, -200, 1100, 300);
	CALayer *subSubLayerA = [CALayer layer];
	subSubLayerA.frame = CGRectMake(-100, -100, 999, 445);
	[sublayerA addSublayer:subSubLayerA];
	CALayer *subSubLayerB = [CALayer layer];
	subSubLayerB.frame = CGRectMake(0, -200, 1101, 300);
	[sublayerB addSublayer:subSubLayerB];
	[sut addSublayer:sublayerA];
	[sut addSublayer:sublayerB];

	CGRect unionRect = CGRectUnion(sut.frame, sublayerA.frame);
	unionRect = CGRectUnion(unionRect, sublayerB.frame);
	unionRect = CGRectUnion(unionRect, subSubLayerA.frame);
	unionRect = CGRectUnion(unionRect, subSubLayerB.frame);

	XCTAssertTrue(CGRectEqualToRect([sut mm_boundingRect], unionRect));
}

@end
