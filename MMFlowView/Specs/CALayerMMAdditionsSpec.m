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
