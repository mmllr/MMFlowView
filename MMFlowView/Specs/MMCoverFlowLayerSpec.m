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
#import "MMCoverFlowLayoutAttributes.h"

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
		__block MMCoverFlowLayout *layout = nil;

		beforeEach(^{
			layout = [[MMCoverFlowLayout alloc] init];
			sut = [MMCoverFlowLayer layerWithLayout:layout];
		});
		afterEach(^{
			sut = nil;
			layout = nil;
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
		it(@"should have a default height of 50", ^{
			[[theValue(CGRectGetHeight(sut.bounds)) should] equal:theValue(50)];
		});
		it(@"should have a default width of 50", ^{
			[[theValue(CGRectGetWidth(sut.bounds)) should] equal:theValue(50)];
		});
		it(@"should have no sublayers", ^{
			[[[sut should] have:0] sublayers];
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
		it(@"should not have a datasource set", ^{
			[[(id)sut.dataSource should] beNil];
		});
		it(@"should respond to layoutSublayersOfLayer:", ^{
			[[sut should] respondToSelector:@selector(layoutSublayersOfLayer:)];
		});
		it(@"should have a selectedItemIndex of NSNotFound", ^{
			[[theValue(sut.selectedItemIndex) should] equal:theValue(NSNotFound)];
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
			__block id datasourceMock = nil;
			__block NSArray *sublayers = nil;

			beforeEach(^{
				datasourceMock = [KWMock mockForProtocol:@protocol(MMCoverFlowLayerDataSource)];
				[datasourceMock stub:@selector(coverFlowLayerWillRelayout:)];
				[datasourceMock stub:@selector(coverFlowLayerDidRelayout:)];
				sublayers = @[[CALayer layer], [CALayer layer], [CALayer layer], [CALayer layer], [CALayer layer], [CALayer layer], [CALayer layer], [CALayer layer]];
				[sublayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					[[datasourceMock stubAndReturn:sublayers[idx]] coverFlowLayer:sut contentLayerForIndex:idx];
				}];
				[datasourceMock stub:@selector(numberOfItemsInCoverFlowLayer:) andReturn:theValue([sublayers count])];
				sut.dataSource = datasourceMock;
			});
			afterEach(^{
				datasourceMock =  nil;
				sublayers = nil;
			});
			context(@"loading", ^{
				it(@"should ask the datasource for the item count", ^{
					[[datasourceMock should] receive:@selector(numberOfItemsInCoverFlowLayer:)];
					[sut reloadContent];
				});
				it(@"should load the content", ^{
					[sut reloadContent];
					[[theValue(sut.numberOfItems) should] equal:theValue([sublayers count])];
				});
				it(@"should trigger a relayout when setting", ^{
					[[sut should] receive:@selector(layoutSublayers)];
					[sut reloadContent];
				});
				it(@"should change the selectedItemIndex", ^{
					[sut reloadContent];
					[[theValue(sut.selectedItemIndex) shouldNot] equal:theValue(NSNotFound)];
				});
				it(@"should have the correct count of sublayers", ^{
					[sut reloadContent];
					[[[sut should] have:[sublayers count]] sublayers];
				});
				it(@"should load the layers", ^{
					[sut reloadContent];
					[[sut.sublayers should] equal:sublayers];
				});
				it(@"should ask its datasource for the layers", ^{
					[[datasourceMock should] receive:@selector(coverFlowLayer:contentLayerForIndex:) withCount:[sublayers count]];
					[sut reloadContent];
				});
			});
			context(@"selection", ^{
				beforeEach(^{
					[sut reloadContent];
					sut.selectedItemIndex = sut.numberOfItems / 2;
					[CATransaction flush];
				});
				it(@"should change the selection", ^{
					NSUInteger expectedSelection = sut.numberOfItems / 2;
					[[theValue(sut.selectedItemIndex) should] equal:theValue(expectedSelection)];
				});
				it(@"should scroll to selected item", ^{
					MMCoverFlowLayoutAttributes *attr = [layout layoutAttributesForItemAtIndex:sut.selectedItemIndex];
					CGPoint expectedPoint = CGPointMake( attr.position.x - (CGRectGetWidth(sut.bounds) / 2.)  + layout.itemSize.width / 2., 0 );
					[[[NSValue valueWithPoint:sut.bounds.origin] should] equal:[NSValue valueWithPoint:expectedPoint]];
				});
			});
			context(@"layout", ^{
				it(@"should invoke coverFlowLayerWillRelayout when triggering relayout", ^{
					[[datasourceMock should] receive:@selector(coverFlowLayerWillRelayout:)];
					[sut layoutSublayersOfLayer:sut];
				});
				it(@"should invoke coverFlowLayerDidRelayout when triggering relayout", ^{
					[[datasourceMock should] receive:@selector(coverFlowLayerDidRelayout:)];
					[sut layoutSublayersOfLayer:sut];
				});
				context(@"attributes", ^{
					__block NSDictionary *expectedAttributes = nil;
					__block NSDictionary *layerAttributes = nil;
					NSArray *attributeKeys = @[@"position", @"bounds", @"transform", @"zPosition", @"anchorPoint"];

					beforeEach(^{
						[sut reloadContent];
						sut.selectedItemIndex = sut.numberOfItems / 2;
						[sut layoutSublayersOfLayer:sut];
					});
					afterEach(^{
						expectedAttributes = nil;
						layerAttributes = nil;
					});
					context(@"first item of left stack", ^{
						beforeEach(^{
							expectedAttributes = [[layout layoutAttributesForItemAtIndex:0] dictionaryWithValuesForKeys:attributeKeys];
							layerAttributes = [sublayers[0] dictionaryWithValuesForKeys:attributeKeys];
						});
						it(@"should have the attributes", ^{
							[[layerAttributes should] equal:expectedAttributes];
						});
					});
					context(@"selected item", ^{
						beforeEach(^{
							expectedAttributes = [[layout layoutAttributesForItemAtIndex:sut.selectedItemIndex] dictionaryWithValuesForKeys:attributeKeys];
							layerAttributes = [sublayers[sut.selectedItemIndex] dictionaryWithValuesForKeys:attributeKeys];
						});
						it(@"should have the attributes", ^{
							[[layerAttributes should] equal:expectedAttributes];
						});
					});
					context(@"last item of right stack", ^{
						beforeEach(^{
							NSUInteger lastIndex = sut.numberOfItems - 1;
							expectedAttributes = [[layout layoutAttributesForItemAtIndex:lastIndex] dictionaryWithValuesForKeys:attributeKeys];
							layerAttributes = [sublayers[lastIndex] dictionaryWithValuesForKeys:attributeKeys];
						});
						it(@"should have the attributes", ^{
							[[layerAttributes should] equal:expectedAttributes];
						});
					});
				});
			});
		});
	});
});

SPEC_END
