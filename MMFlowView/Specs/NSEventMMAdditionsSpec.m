//
//  NSEventMMAdditionsSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 23.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "NSEvent+MMAdditions.h"

SPEC_BEGIN(NSEventMMAdditionsSpec)

describe(@"NSEvent+MMAdditions", ^{
	__block NSEvent *sut = nil;

	beforeEach(^{
		sut = [[NSEvent alloc] init];
	});
	afterEach(^{
		sut = nil;
	});
	context(NSStringFromSelector(@selector(dominantDeltaInXYSpace)), ^{
		context(@"when the events absolute deltaX is greater than deltaY", ^{
			beforeEach(^{
				[sut stub:@selector(deltaX) andReturn:theValue(10)];
				[sut stub:@selector(deltaY) andReturn:theValue(-5)];
			});
			it(@"should return deltaX", ^{
				[[theValue(sut.dominantDeltaInXYSpace) should] equal:10 withDelta:0.0000001];
			});
		});
		context(@"when the events absolute deltaX is equal to deltaY", ^{
			beforeEach(^{
				[sut stub:@selector(deltaX) andReturn:theValue(-5)];
				[sut stub:@selector(deltaY) andReturn:theValue(-5)];
			});
			it(@"should return deltaX", ^{
				[[theValue(sut.dominantDeltaInXYSpace) should] equal:-5 withDelta:0.0000001];
			});
		});
		context(@"when the events absolute deltaX is less than deltaY", ^{
			beforeEach(^{
				[sut stub:@selector(deltaX) andReturn:theValue(-5)];
				[sut stub:@selector(deltaY) andReturn:theValue(-6)];
			});
			it(@"should return deltaY", ^{
				[[theValue(sut.dominantDeltaInXYSpace) should] equal:-6 withDelta:0.0000001];
			});
		});
	});
});

SPEC_END
