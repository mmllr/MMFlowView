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
#import "CALayer+NSAccessibility.h"

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
			[[theValue(sut.masksToBounds) should] beNo];
		});
		it(@"should have a default height of 0", ^{
			[[theValue(CGRectGetHeight(sut.bounds)) should] beZero];
		});
		it(@"should have a default width of 0", ^{
			[[theValue(CGRectGetWidth(sut.bounds)) should] beZero];
		});
		it(@"should have empty visible item indexes", ^{
			[[sut.visibleItemIndexes should] equal:[NSIndexSet indexSet]];
		});
		it(@"should have no sublayers", ^{
			[[[sut should] have:0] sublayers];
		});
		it(@"should have a scroll duration of .4 seconds", ^{
			[[theValue(sut.scrollDuration) should] equal:theValue(.4)];
		});
		it(@"should have an anchorPoint of 0.5, 0.5", ^{
			NSValue *expectedPoint = [NSValue valueWithPoint:NSMakePoint(.5, .5)];
			[[[NSValue valueWithPoint:sut.anchorPoint] should] equal:expectedPoint];
		});
		it(@"should have a frame position of 0,0", ^{
			NSValue *expectedPoint = [NSValue valueWithPoint:NSMakePoint(0, 0)];
			[[[NSValue valueWithPoint:sut.frame.origin] should] equal:expectedPoint];
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
		it(@"should not have a datasource set", ^{
			[[(id)sut.dataSource should] beNil];
		});
		it(@"should have a selectedItemIndex of NSNotFound", ^{
			[[theValue(sut.selectedItemIndex) should] equal:theValue(NSNotFound)];
		});
		context(@"observing layout changes", ^{
			it(@"should trigger a reload if layouts numberOfItems changes", ^{
				[[sut should] receive:@selector(reloadContent)];
				sut.layout.numberOfItems = 10;
			});
			it(@"should trigger a relayout if stackedAngle of layout changed", ^{
				[[sut should] receive:@selector(setNeedsLayout)];
				sut.layout.stackedAngle = 20;
			});
			it(@"should trigger a relayout if layout´s interItemSpacing changes", ^{
				[[sut should] receive:@selector(setNeedsLayout)];
				sut.layout.interItemSpacing = 100;
			});
			it(@"should trigger relayout if layout´s selectedItemIndex changes", ^{
				[[sut should] receive:@selector(setNeedsLayout)];
				sut.layout.selectedItemIndex = 0;
			});
			it(@"should trigger relayout if layout´s stackedDistance changes", ^{
				[[sut should] receive:@selector(setNeedsLayout)];
				sut.layout.stackedDistance = 50;
			});
			it(@"should trigger relayout if layout´s verticalMargin changes", ^{
				[[sut should] receive:@selector(setNeedsLayout)];
				sut.layout.verticalMargin = 5;
			});
			it(@"should trigger relayout if layout´s numberOfItems changes", ^{
				[[sut should] receive:@selector(setNeedsLayout)];
				sut.layout.numberOfItems = 5;
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
		context(@"reloadContent", ^{
			it(@"should trigger a relayout", ^{
				[[sut should] receive:@selector(layoutSublayers)];
				[sut reloadContent];
			});
		});
		context(@"NSAccessibility", ^{
			NSArray *expectedDefaultAttributes = @[NSAccessibilityParentAttribute, NSAccessibilitySizeAttribute, NSAccessibilityPositionAttribute, NSAccessibilityWindowAttribute, NSAccessibilityTopLevelUIElementAttribute, NSAccessibilityRoleAttribute, NSAccessibilityRoleDescriptionAttribute, NSAccessibilityEnabledAttribute, NSAccessibilityFocusedAttribute];

			it(@"should not be ax ignored", ^{
				[[theValue([sut accessibilityIsIgnored]) should] beNo];
			});
			it(@"should have the expected default accessibility attributes", ^{
				[[[sut accessibilityAttributeNames] should] containObjectsInArray:expectedDefaultAttributes];
			});
			it(@"should have a list role", ^{
				[[[sut accessibilityAttributeValue:NSAccessibilityRoleAttribute] should] equal:NSAccessibilityListRole];
			});
			it(@"should habe a content list subrole", ^{
				[[[sut accessibilityAttributeValue:NSAccessibilitySubroleAttribute] should] equal:NSAccessibilityContentListSubrole];
			});
			it(@"should have a horizontal orentation", ^{
				[[[sut accessibilityAttributeValue:NSAccessibilityOrientationAttribute] should] equal:NSAccessibilityHorizontalOrientationValue];
			});
			it(@"should have visible children attribute", ^{
				[[[sut accessibilityAttributeValue:NSAccessibilityVisibleChildrenAttribute] shouldNot] beNil];
			});
			it(@"should have a selected children attribute", ^{
				[[[sut accessibilityAttributeValue:NSAccessibilitySelectedChildrenAttribute] shouldNot] beNil];
			});
			it(@"should have a writable selected children attribute", ^{
				[[theValue([sut accessibilityIsAttributeSettable:NSAccessibilitySelectedChildrenAttribute]) should] beYes];
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
				it(@"should have disabled the bounds action", ^{
					[[(id)[sut.delegate actionForLayer:sut forKey:@"bounds"] should] equal:[NSNull null]];
				});
			});
			context(@"not in resizing", ^{
				it(@"should have disabled the bounds action", ^{
					sut.inLiveResize = NO;
					[[(id)[sut.delegate actionForLayer:sut forKey:@"bounds"] should] beNil];
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
				[sublayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
					// make layers accessibility aware
					[layer setReadableAccessibilityAttribute:NSAccessibilityRoleAttribute withBlock:^id{
						return NSAccessibilityImageRole;
					}];
					[[datasourceMock stubAndReturn:layer] coverFlowLayer:sut contentLayerForIndex:idx];
				}];
				sut.bounds = CGRectMake(0, 0, 200, 100);
				sut.dataSource = datasourceMock;
				sut.layout.numberOfItems = [sublayers count];
			});
			afterEach(^{
				datasourceMock =  nil;
				sublayers = nil;
			});
			context(@"visible items", ^{
				it(@"should have nonzero visible items", ^{
					[[theValue([sut.visibleItemIndexes count]) should] beGreaterThan:theValue(0)];
				});
				it(@"should contain the selected index", ^{
					[[theValue([sut.visibleItemIndexes containsIndex:sut.selectedItemIndex]) should] beYes];
				});
			});
			context(@"loading", ^{
				it(@"should load the content", ^{
					[[theValue(sut.numberOfItems) should] equal:theValue([sublayers count])];
				});
				it(@"should change the selectedItemIndex", ^{
					[[theValue(sut.selectedItemIndex) shouldNot] equal:theValue(NSNotFound)];
				});
				it(@"should have the correct count of sublayers", ^{
					[[[sut should] have:[sublayers count]] sublayers];
				});
				it(@"should load the layers", ^{
					[[sut.sublayers should] equal:sublayers];
				});
				it(@"should ask its datasource for the layers", ^{
					[[datasourceMock should] receive:@selector(coverFlowLayer:contentLayerForIndex:) withCount:[sublayers count]];
					[sut reloadContent];
				});
			});
			context(@"selection", ^{
				beforeEach(^{
					sut.selectedItemIndex = sut.numberOfItems / 2;
					[sut layoutSublayers];
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
					[sut layoutSublayers];
				});
				it(@"should invoke coverFlowLayerDidRelayout after finishing relayout", ^{
					[[datasourceMock shouldEventually] receive:@selector(coverFlowLayerDidRelayout:) withCountAtLeast:1];
					[sut layoutSublayers];
				});
				it(@"should set the CoreAnimation transactions", ^{
					[[[CATransaction class] should] receive:@selector(begin)];
					[[[CATransaction class] should] receive:@selector(commit)];
					[[[CATransaction class] should] receive:@selector(setDisableActions:) withArguments:theValue(sut.inLiveResize)];
					[[[CATransaction class] should] receive:@selector(setAnimationDuration:) withArguments:theValue(sut.scrollDuration)];
					[[[CATransaction class] should] receive:@selector(setAnimationTimingFunction:) withArguments:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
					[sut layoutSublayers];
				});
				context(@"attributes", ^{
					__block MMCoverFlowLayoutAttributes *expectedAttributes = nil;
					__block CALayer *layer = nil;

					beforeEach(^{
						sut.selectedItemIndex = sut.numberOfItems / 2;
						[sut layoutSublayers];
					});
					afterEach(^{
						expectedAttributes = nil;
						layer = nil;
					});
					context(@"first item of left stack", ^{
						beforeEach(^{
							expectedAttributes = [layout layoutAttributesForItemAtIndex:0];
							layer = sublayers[0];
						});
						it(@"should have the correct bounds", ^{
							NSValue *expectedBounds = [NSValue valueWithRect:expectedAttributes.bounds];
							[[[NSValue valueWithRect:layer.bounds] should] equal:expectedBounds];
						});
						it(@"should have the correct position", ^{
							NSValue *expectedPosition = [NSValue valueWithPoint:expectedAttributes.position];
							[[[NSValue valueWithPoint:layer.frame.origin] should] equal:expectedPosition];
						});
						it(@"should have the correct anchorPoint", ^{
							NSValue *expectedAnchorPoint = [NSValue valueWithPoint:expectedAttributes.anchorPoint];
							[[[NSValue valueWithPoint:layer.anchorPoint] should] equal:expectedAnchorPoint];
						});
						it(@"should have the correct zPosition", ^{
							[[theValue(expectedAttributes.zPosition) should] equal:theValue(layer.zPosition)];
						});
						it(@"should have the correct transform", ^{
							NSValue *expectedTransform = [NSValue valueWithCATransform3D:expectedAttributes.transform];
							[[[NSValue valueWithCATransform3D:layer.transform] should] equal:expectedTransform];
						});
					});
					context(@"selected item", ^{
						beforeEach(^{
							expectedAttributes = [layout layoutAttributesForItemAtIndex:sut.selectedItemIndex];
							layer = sublayers[sut.selectedItemIndex];
						});
						it(@"should have the correct bounds", ^{
							NSValue *expectedBounds = [NSValue valueWithRect:expectedAttributes.bounds];
							[[[NSValue valueWithRect:layer.bounds] should] equal:expectedBounds];
						});
						it(@"should have the correct position", ^{
							NSValue *expectedPosition = [NSValue valueWithPoint:expectedAttributes.position];
							[[[NSValue valueWithPoint:layer.frame.origin] should] equal:expectedPosition];
						});
						it(@"should have the correct anchorPoint", ^{
							NSValue *expectedAnchorPoint = [NSValue valueWithPoint:expectedAttributes.anchorPoint];
							[[[NSValue valueWithPoint:layer.anchorPoint] should] equal:expectedAnchorPoint];
						});
						it(@"should have the correct zPosition", ^{
							[[theValue(expectedAttributes.zPosition) should] equal:theValue(layer.zPosition)];
						});
						it(@"should have the correct transform", ^{
							NSValue *expectedTransform = [NSValue valueWithCATransform3D:expectedAttributes.transform];
							[[[NSValue valueWithCATransform3D:layer.transform] should] equal:expectedTransform];
						});
						it(@"should be horizontally centered", ^{
							[[theValue(CGRectGetMidX(layer.frame)) should] equal:theValue(CGRectGetMidX(sut.bounds))];
						});
					});
					context(@"last item of right stack", ^{
						beforeEach(^{
							expectedAttributes = [layout layoutAttributesForItemAtIndex:sut.numberOfItems-1];
							layer = [sublayers lastObject];
						});
						it(@"should have the correct bounds", ^{
							NSValue *expectedBounds = [NSValue valueWithRect:expectedAttributes.bounds];
							[[[NSValue valueWithRect:layer.bounds] should] equal:expectedBounds];
						});
						it(@"should have the correct position", ^{
							NSValue *expectedPosition = [NSValue valueWithPoint:expectedAttributes.position];
							[[[NSValue valueWithPoint:layer.frame.origin] should] equal:expectedPosition];
						});
						it(@"should have the correct anchorPoint", ^{
							NSValue *expectedAnchorPoint = [NSValue valueWithPoint:expectedAttributes.anchorPoint];
							[[[NSValue valueWithPoint:layer.anchorPoint] should] equal:expectedAnchorPoint];
						});
						it(@"should have the correct zPosition", ^{
							[[theValue(expectedAttributes.zPosition) should] equal:theValue(layer.zPosition)];
						});
						it(@"should have the correct transform", ^{
							NSValue *expectedTransform = [NSValue valueWithCATransform3D:expectedAttributes.transform];
							[[[NSValue valueWithCATransform3D:layer.transform] should] equal:expectedTransform];
						});
					});
				});
			});
			context(@"NSAccessibility", ^{
				beforeEach(^{
					sut.bounds = CGRectMake(0, 0, 100, 50);
					[sut reloadContent];
				});
				it(@"should return only one selected layer", ^{
					[[[sut accessibilityAttributeValue:NSAccessibilitySelectedChildrenAttribute] should] haveCountOf:1];
				});
				it(@"should return the selected layer", ^{
					[[[sut accessibilityAttributeValue:NSAccessibilitySelectedChildrenAttribute] should] containObjectsInArray:@[sublayers[sut.selectedItemIndex]]];
				});
				context(@"visible children", ^{
					__block NSArray *visibleChildren = nil;
					beforeEach(^{
						visibleChildren = [sut accessibilityAttributeValue:NSAccessibilityVisibleChildrenAttribute];
					});
					afterEach(^{
						visibleChildren = nil;
					});
					it(@"should have visible children", ^{
						[[visibleChildren should] haveCountOfAtLeast:1];
					});
					it(@"should have the selected layer in visible children", ^{
						[[visibleChildren should] contain:sublayers[sut.selectedItemIndex]];
					});
					it(@"should return all layers at visibleItemIndexes for visible children", ^{
						NSArray *expectedChildren = [sublayers subarrayWithRange:NSMakeRange([sut.visibleItemIndexes firstIndex], [sut.visibleItemIndexes count])];
						[[visibleChildren should] containObjectsInArray:expectedChildren];
					});
				});
			});
		});
	});
});

SPEC_END
