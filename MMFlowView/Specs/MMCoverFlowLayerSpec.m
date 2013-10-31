//
//  MMCoverFlowLayerSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 31.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMCoverFlowLayer.h"
#import "MMCoverFlowLayout.h"

SPEC_BEGIN(MMCoverFlowLayerSpec)

describe(@"MMCoverFlowLayer", ^{
	__block MMCoverFlowLayer *sut = nil;

	context(@"creating with CALayer default -init/+layer", ^{
		it(@"should raise if created with +layer", ^{
			[[theBlock(^{
				[MMCoverFlowLayer layer];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		it(@"should raise if created with -init", ^{
			[[theBlock(^{
				sut = [[MMCoverFlowLayer alloc] init];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
	context(@"a new instance created by designated initializer", ^{
		beforeEach(^{
			sut = [MMCoverFlowLayer layerWithLayout:[[MMCoverFlowLayout alloc] init]];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should be a CAScrollLayer", ^{
			[[sut should] beKindOfClass:[CAScrollLayer class]];
		});
		it(@"should have a horizontal scroll mode", ^{
			[[sut.scrollMode should] equal:kCAScrollHorizontally];
		});
		it(@"should be horizontally resizable", ^{
			[[theValue(sut.autoresizingMask & kCALayerWidthSizable) should] beYes];
		});
		it(@"should be vertically resizable", ^{
			[[theValue(sut.autoresizingMask & kCALayerHeightSizable) should] beYes];
		});
		it(@"should have zero items", ^{
			[[theValue(sut.numberOfItems) should] equal:theValue(0)];
		});
		it(@"should not mask to bounds", ^{
			[[theValue(sut.masksToBounds) shouldNot] beYes];
		});
		it(@"should have a default eye distance of 1500", ^{
			[[theValue(sut.eyeDistance) should] equal:theValue(1500.)];
		});
		it(@"should have a sublayerTransform with m34 equal to one divided by -eyeDistance", ^{
			CATransform3D expectedTransform = CATransform3DIdentity;
			expectedTransform.m34 = 1. / -sut.eyeDistance;
			[[[NSValue valueWithCATransform3D:sut.sublayerTransform] should] equal:[NSValue valueWithCATransform3D:expectedTransform]];
		});
		it(@"should not initiallly be in resizing", ^{
			[[theValue(sut.inLiveResize) should] beNo];
		});
		it(@"should be its own delegate", ^{
			[[sut.delegate should] equal:sut];
		});
		it(@"should be its own layout manager", ^{
			[[sut.layoutManager should] equal:sut];
		});
		it(@"should respond to layoutSublayersOfLayer:", ^{
			[[sut should] respondToSelector:@selector(layoutSublayersOfLayer:)];
		});
		context(@"numberOfItems", ^{
			it(@"should set the number of items", ^{
				// given
				sut.numberOfItems = 10;
				// then
				[[theValue(sut.numberOfItems) should] equal:theValue(10)];
			});
			it(@"should trigger a relayut when setting", ^{
				[[sut should] receive:@selector(setNeedsLayout)];
				sut.numberOfItems = 9;
			});
		});
		context(@"eyeDistance", ^{
			beforeEach(^{
				sut.eyeDistance = 1000;
			});
			it(@"should set the eyeDistance", ^{
				[[theValue(sut.eyeDistance) should] equal:theValue(1000)];
			});
			it(@"should have a sublayerTransform with m34 equal to one divided by -eyeDistance", ^{
				CATransform3D expectedTransform = CATransform3DIdentity;
				expectedTransform.m34 = 1. / -sut.eyeDistance;
				[[[NSValue valueWithCATransform3D:sut.sublayerTransform] should] equal:[NSValue valueWithCATransform3D:expectedTransform]];
			});

		});
		context(@"CoreAnimation actions", ^{
			context(@"while live resizing", ^{
				beforeEach(^{
					sut.inLiveResize = YES;
				});
				afterEach(^{
					sut.inLiveResize = NO;
				});
				it(@"should have disabled all actions", ^{
					id action = [sut actionForKey:@"bounds"];
					[[action should] beNil];
				});
			});
		});
		context(@"datasource", ^{
			__block id<MMCoverFlowLayerDatasource> datasourceMock = nil;
		});
	});
});

SPEC_END
