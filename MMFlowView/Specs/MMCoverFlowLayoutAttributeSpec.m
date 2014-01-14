//
//  MMCoverFlowLayoutAttributeSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMCoverFLowLayoutAttributes.h"

SPEC_BEGIN(MMCoverFlowLayoutAttributesSpec)

describe(@"MMCoverFlowLayoutAttributes", ^{
	__block MMCoverFlowLayoutAttributes *sut = nil;

	context(@"creating with default -init", ^{
		it(@"should raise if created with -init", ^{
			[[theBlock(^{
				sut = [[MMCoverFlowLayoutAttributes alloc] init];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
	context(@"a new instance created with designated initializer", ^{
		beforeEach(^{
			sut = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:10
															position:CGPointMake(10, 10)
																size:CGSizeMake(50, 50)
														 anchorPoint:CGPointMake(.5,.5)
														   transfrom:CATransform3DIdentity
														   zPosition:100];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should exists", ^{
			[[sut shouldNot] beNil];
		});
		context(@"values from designated initializer", ^{
			it(@"should have an index of 10", ^{
				[[theValue(sut.index) should] equal:@10];
			});
			it(@"should have an identity transform matrix", ^{
				NSValue *expectedTransform = [NSValue valueWithCATransform3D:CATransform3DIdentity];
				[[[NSValue valueWithCATransform3D:sut.transform] should] equal:expectedTransform];
			});
			it(@"should have a positon of {10,10}", ^{
				NSValue *expectedPosition = [NSValue valueWithPoint:CGPointMake(10, 10)];
				[[[NSValue valueWithPoint:sut.position] should] equal:expectedPosition];
			});
			it(@"should have the bounds passed by the designated initalizer", ^{
				NSValue *expectedBounds = [NSValue valueWithRect:CGRectMake(0, 0, 50, 50)];
				[[[NSValue valueWithRect:sut.bounds] should] equal:expectedBounds];
			});
			it(@"should have a {0.5,0.5} anchorpoint", ^{
				NSValue *expectedPoint = [NSValue valueWithPoint:NSPointFromCGPoint(CGPointMake(.5, .5))];
				[[[NSValue valueWithPoint:NSPointFromCGPoint(sut.anchorPoint)] should] equal:expectedPoint];
			});
			it(@"should have a zPosition of 100", ^{
				[[theValue(sut.zPosition) should] equal:theValue(100)];
			});
		});
		
	});
});

SPEC_END
