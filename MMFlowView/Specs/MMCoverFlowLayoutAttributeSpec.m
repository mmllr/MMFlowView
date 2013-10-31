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
	context(@"a new instance", ^{
		__block MMCoverFlowLayoutAttributes *sut = nil;

		beforeEach(^{
			sut = [[MMCoverFlowLayoutAttributes alloc] init];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should exists", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should have an index of NSNotFound", ^{
			[[theValue(sut.index) should] equal:theValue(NSNotFound)];
		});
		it(@"should have an identity transform matrix", ^{
			BOOL isIdentity = CATransform3DIsIdentity(sut.transform);

			[[theValue(isIdentity) should] beYes];
		});
		it(@"should have a zero positon", ^{
			BOOL isZero = CGPointEqualToPoint(sut.position, CGPointZero);
			[[theValue(isZero) should] beYes];
		});
		it(@"should have a zero size", ^{
			BOOL isZeroSize = CGSizeEqualToSize(sut.size, CGSizeZero);
			[[theValue(isZeroSize) should] beYes];
		});
		it(@"should have a {0.5,0.5} anchorpoint", ^{
			NSValue *expectedPoint = [NSValue valueWithPoint:NSPointFromCGPoint(CGPointMake(.5, .5))];
			NSValue *point = [NSValue valueWithPoint:NSPointFromCGPoint(sut.anchorPoint)];

			[[point should] equal:expectedPoint];
		});
		it(@"should have a zero zPosition", ^{
			[[theValue(sut.zPosition) should] equal:theValue(0)];
		});
	});
});

SPEC_END
