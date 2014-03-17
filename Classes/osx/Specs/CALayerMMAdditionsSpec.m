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
//  CALayerMMAdditionsSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 10.01.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "CALayer+MMAdditions.h"

SPEC_BEGIN(CALayerMMAdditionsSpec)

describe(@"CALayer+MMAdditions", ^{
	__block CALayer *sut = nil;

	beforeEach(^{
		sut = [CALayer layer];
		sut.frame = CGRectMake(20, 30, 200, 400);
	});
	afterEach(^{
		sut = nil;
	});

	context(@"Implicit bounds and position animations", ^{
		context(@"disable animations", ^{
			beforeEach(^{
				[sut mm_disableImplicitPositionAndBoundsAnimations];
			});
			it(@"should have a position action of NSNull", ^{
				[[sut.actions[@"position"] should] equal:[NSNull null]];
			});
			it(@"should have a bounds action of NSNull", ^{
				[[sut.actions[@"bounds"] should] equal:[NSNull null]];
			});
			context(@"reenabling animations", ^{
				beforeEach(^{
					[sut mm_enableImplicitPositionAndBoundsAnimations];
				});
				it(@"should not have a nil position value in its action dictionary", ^{
					[[sut.actions[@"position"] should] beNil];
				});
				it(@"should not have a nil bounds value in its action dictionary", ^{
					[[sut.actions[@"bounds"] should] beNil];
				});
			});
		});
	});
	context(NSStringFromSelector(@selector(mm_boundingRect)), ^{
		it(@"should return the frame for a layer without sublayers", ^{
			NSValue *expectedRect = [NSValue valueWithRect:sut.frame];

			[[[NSValue valueWithRect:[sut mm_boundingRect]] should] equal:expectedRect];
		});
		context(@"when having sublayers exceeding the layers frame", ^{
			__block NSValue *expectedRect;

			beforeEach(^{
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
				expectedRect = [NSValue valueWithRect:unionRect];
			});
			afterEach(^{
				expectedRect = nil;
			});
			it(@"should have the bounding rect of its frame and its sublayers frame", ^{
				[[[NSValue valueWithRect:[sut mm_boundingRect]] should] equal:expectedRect];
			});
		});
	});
});

SPEC_END
