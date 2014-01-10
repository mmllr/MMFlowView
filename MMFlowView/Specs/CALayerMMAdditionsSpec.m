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
		sut.bounds = CGRectMake(0, 0, 100, 100);
	});
	afterEach(^{
		sut = nil;
	});

	context(@"Implicit bounds and position animations", ^{
		context(@"disable animations", ^{
			beforeEach(^{
				[sut disableImplicitPositionAndBoundsAnimations];
			});
			it(@"should have a position action of NSNull", ^{
				[[sut.actions[@"position"] should] equal:[NSNull null]];
			});
			it(@"should have a bounds action of NSNull", ^{
				[[sut.actions[@"bounds"] should] equal:[NSNull null]];
			});
			context(@"reenabling animations", ^{
				beforeEach(^{
					[sut enableImplicitPositionAndBoundsAnimations];
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
});

SPEC_END
