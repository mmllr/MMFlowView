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
		it(@"should have one sublayer", ^{
			[[[sut should] have:1] sublayers];
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
		it(@"should have a selectedItemFrame property", ^{
			[[theValue(CGRectEqualToRect(CGRectZero, sut.selectedItemFrame) == true) should] beTrue];
		});
		it(@"should not initially show reflections", ^{
			[[theValue(sut.showsReflection) should] beNo];
		});
		context(@"replicatorLayer", ^{
			__block CAReplicatorLayer *replicatorLayer = nil;
			beforeEach(^{
				replicatorLayer = [sut.sublayers firstObject];
			});
			afterEach(^{
				replicatorLayer = nil;
			});
			it(@"should exist", ^{
				[[replicatorLayer shouldNot] beNil];
			});
			it(@"should be from kind CAReplicatorLayer", ^{
				[[replicatorLayer should] beKindOfClass:[CAReplicatorLayer class]];
			});
			it(@"should preserve depth", ^{
				[[theValue(replicatorLayer.preservesDepth) should] beYes];
			});
			it(@"should have an instanceCount of 1", ^{
				[[theValue(replicatorLayer.instanceCount) should] equal:theValue(1)];
			});
			it(@"should have an instanceRedOffset equal to reflectionOffset", ^{
				[[theValue(replicatorLayer.instanceRedOffset) should] equal:sut.reflectionOffset withDelta:.000001];
			});
			it(@"should have an instanceGreenOffset equal to reflectionOffset", ^{
				[[theValue(replicatorLayer.instanceGreenOffset) should] equal:sut.reflectionOffset withDelta:.000001];
			});
			it(@"should have an instanceBlueOffset equal to reflectionOffset", ^{
				[[theValue(replicatorLayer.instanceBlueOffset) should] equal:sut.reflectionOffset withDelta:.000001];
			});
			context(@"instanceTransform", ^{
				__block NSValue *expectedTransform = nil;
				beforeEach(^{
					[sut layoutSublayers];
					expectedTransform = [NSValue valueWithCATransform3D:CATransform3DConcat( CATransform3DMakeScale(1, -1, 1), CATransform3DMakeTranslation(0, -sut.layout.itemSize.height, 0))];
				});
				afterEach(^{
					expectedTransform = nil;
				});
				it(@"should have the expected transform", ^{
					[[[NSValue valueWithCATransform3D:replicatorLayer.instanceTransform] should] equal:expectedTransform];
				});
			});
			context(@"reflectionOffset", ^{
				it(@"should have a reflectionOffset of -.4", ^{
					const CGFloat expectedOffset = -.4;

					[[theValue(sut.reflectionOffset) should] equal:expectedOffset withDelta:.0000001];
				});
				context(@"setting values", ^{
					beforeEach(^{
						sut.reflectionOffset = -.2;
					});
					it(@"should be set", ^{
						[[theValue(sut.reflectionOffset) should] equal:-.2 withDelta:.0000001];
					});
					context(@"replicatorLayer", ^{
						it(@"should have an instanceRedOffset equal to reflectionOffset", ^{
							[[theValue(replicatorLayer.instanceRedOffset) should] equal:-.2 withDelta:.000001];
						});
						it(@"should have an instanceGreenOffset equal to reflectionOffset", ^{
							[[theValue(replicatorLayer.instanceGreenOffset) should] equal:-.2 withDelta:.000001];
						});
						it(@"should have an instanceBlueOffset equal to reflectionOffset", ^{
							[[theValue(replicatorLayer.instanceBlueOffset) should] equal:-.2 withDelta:.000001];
						});
					});
					context(@"setting illegal values", ^{
						it(@"should not be greater than zero", ^{
							sut.reflectionOffset = 0.5;
							[[theValue(sut.reflectionOffset) should] beZero];
						});
						it(@"should not be smaller than -1", ^{
							sut.reflectionOffset = -2;
							[[theValue(sut.reflectionOffset) should] equal:-1 withDelta:0.0000001];
						});
					});
				});
				
			});
			context(@"showsReflection", ^{
				context(@"enabling reflections", ^{
					beforeEach(^{
						sut.showsReflection = YES;
					});
					it(@"should be YES", ^{
						[[theValue(sut.showsReflection) should] beYes];
					});
					it(@"should have change the replicatorLayers instanceCount to 2", ^{
						[[theValue(replicatorLayer.instanceCount) should] equal:theValue(2)];
					});
					context(@"disabling reflections", ^{
						beforeEach(^{
							sut.showsReflection = NO;
						});
						it(@"should be NO", ^{
							[[theValue(sut.showsReflection) should] beNo];
						});
						it(@"should set the replicator layers instanceCount to 1", ^{
							[[theValue(replicatorLayer.instanceCount) should] equal:theValue(1)];
						});
					});
				});
			});
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
			context(@"loading", ^{
				it(@"should load the content", ^{
					[[theValue(sut.numberOfItems) should] equal:theValue([sublayers count])];
				});
				context(@"contentLayers", ^{
					it(@"should not be nil", ^{
						[[sut.contentLayers shouldNot] beNil];
					});
					it(@"should return a NSArray", ^{
						[[sut.contentLayers should] beKindOfClass:[NSArray class]];
					});
					it(@"should have the correct count of sublayers", ^{
						[[sut.contentLayers should] haveCountOf:[sublayers count]];
					});
					it(@"should load the layers", ^{
						[[sut.contentLayers should] equal:sublayers];
					});
				});
				it(@"should ask its datasource for the layers", ^{
					[[datasourceMock should] receive:@selector(coverFlowLayer:contentLayerForIndex:) withCount:[sublayers count]];
					[sut reloadContent];
				});
			});
			context(@"selection", ^{
				beforeEach(^{
					sut.layout.selectedItemIndex = sut.numberOfItems / 2;
					[sut layoutSublayers];
				});
				it(@"should change the selection", ^{
					NSUInteger expectedSelection = sut.numberOfItems / 2;
					[[theValue(sut.layout.selectedItemIndex) should] equal:theValue(expectedSelection)];
				});
				it(@"should scroll to selected item", ^{
					MMCoverFlowLayoutAttributes *attr = [layout layoutAttributesForItemAtIndex:sut.layout.selectedItemIndex];
					CGPoint expectedPoint = CGPointMake( attr.position.x - (CGRectGetWidth(sut.bounds) / 2.)  + layout.itemSize.width / 2., 0 );
					[[[NSValue valueWithPoint:sut.bounds.origin] should] equal:[NSValue valueWithPoint:expectedPoint]];
				});
				context(@"visibleItemIndexes", ^{
					it(@"should have nonzero visible items", ^{
						[[theValue([sut.visibleItemIndexes count]) should] beGreaterThan:theValue(0)];
					});
					it(@"should contain the selected index", ^{
						[[theValue([sut.visibleItemIndexes containsIndex:layout.selectedItemIndex]) should] beYes];
					});
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
					__block NSValue *expectedPosition = nil;
					__block CALayer *layer = nil;

					beforeEach(^{
						sut.layout.selectedItemIndex = sut.numberOfItems / 2;
						[sut layoutSublayers];
					});
					afterEach(^{
						expectedAttributes = nil;
						layer = nil;
					});
					context(@"first item of left stack", ^{
						beforeEach(^{
							expectedAttributes = [layout layoutAttributesForItemAtIndex:0];
							CGAffineTransform anchorTransform = CGAffineTransformMakeTranslation(expectedAttributes.anchorPoint.x*CGRectGetWidth(expectedAttributes.bounds), expectedAttributes.anchorPoint.y*CGRectGetHeight(expectedAttributes.bounds));
							
							expectedPosition = [NSValue valueWithPoint:CGPointApplyAffineTransform(expectedAttributes.position, anchorTransform)];
							layer = sublayers[0];
							
						});
						it(@"should have the correct bounds", ^{
							NSValue *expectedBounds = [NSValue valueWithRect:expectedAttributes.bounds];
							[[[NSValue valueWithRect:layer.bounds] should] equal:expectedBounds];
						});
						it(@"should have the correct position", ^{
							[[[NSValue valueWithPoint:layer.position] should] equal:expectedPosition];
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
						it(@"should have an index of zero", ^{
							[[[layer valueForKey:@"mmCoverFlowLayerIndex"] should] equal:theValue(0)];
						});
					});
					context(@"last item of left stack", ^{
						beforeEach(^{
							expectedAttributes = [layout layoutAttributesForItemAtIndex:sut.layout.selectedItemIndex-1];
							layer = sublayers[sut.layout.selectedItemIndex-1];
							CGAffineTransform anchorTransform = CGAffineTransformMakeTranslation(expectedAttributes.anchorPoint.x*CGRectGetWidth(expectedAttributes.bounds), expectedAttributes.anchorPoint.y*CGRectGetHeight(expectedAttributes.bounds));
							
							expectedPosition = [NSValue valueWithPoint:CGPointApplyAffineTransform(expectedAttributes.position, anchorTransform)];
						});
						it(@"should have the correct bounds", ^{
							NSValue *expectedBounds = [NSValue valueWithRect:expectedAttributes.bounds];
							[[[NSValue valueWithRect:layer.bounds] should] equal:expectedBounds];
						});
						it(@"should have the correct position", ^{
							[[[NSValue valueWithPoint:layer.position] should] equal:expectedPosition];
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
						it(@"should have an index of zero", ^{
							[[[layer valueForKey:@"mmCoverFlowLayerIndex"] should] equal:theValue(expectedAttributes.index)];
						});
					});
					context(@"selected item", ^{
						beforeEach(^{
							expectedAttributes = [layout layoutAttributesForItemAtIndex:layout.selectedItemIndex];
							layer = sublayers[layout.selectedItemIndex];
							CGAffineTransform anchorTransform = CGAffineTransformMakeTranslation(expectedAttributes.anchorPoint.x*CGRectGetWidth(expectedAttributes.bounds), expectedAttributes.anchorPoint.y*CGRectGetHeight(expectedAttributes.bounds));
							
							expectedPosition = [NSValue valueWithPoint:CGPointApplyAffineTransform(expectedAttributes.position, anchorTransform)];
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
						it(@"should have a selectedItemFrame of the selected layer in the flow view coordinates", ^{
							NSValue *expectedRect = [NSValue valueWithRect:[sut convertRect:layer.visibleRect fromLayer:layer]];
							[[[NSValue valueWithRect:sut.selectedItemFrame] should] equal:expectedRect];
						});
						it(@"should have an index of zero", ^{
							[[[layer valueForKey:@"mmCoverFlowLayerIndex"] should] equal:theValue(expectedAttributes.index)];
						});
					});
					context(@"first item of right stack", ^{
						beforeEach(^{
							expectedAttributes = [layout layoutAttributesForItemAtIndex:layout.selectedItemIndex+1];
							layer = sublayers[layout.selectedItemIndex+1];
							CGAffineTransform anchorTransform = CGAffineTransformMakeTranslation(expectedAttributes.anchorPoint.x*CGRectGetWidth(expectedAttributes.bounds), expectedAttributes.anchorPoint.y*CGRectGetHeight(expectedAttributes.bounds));
							
							expectedPosition = [NSValue valueWithPoint:CGPointApplyAffineTransform(expectedAttributes.position, anchorTransform)];
						});
						it(@"should have the correct bounds", ^{
							NSValue *expectedBounds = [NSValue valueWithRect:expectedAttributes.bounds];
							[[[NSValue valueWithRect:layer.bounds] should] equal:expectedBounds];
						});
						it(@"should have the correct position", ^{
							[[[NSValue valueWithPoint:layer.position] should] equal:expectedPosition];
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
						it(@"should have an index of zero", ^{
							[[[layer valueForKey:@"mmCoverFlowLayerIndex"] should] equal:theValue(expectedAttributes.index)];
						});
					});
					context(@"last item of right stack", ^{
						beforeEach(^{
							expectedAttributes = [layout layoutAttributesForItemAtIndex:sut.numberOfItems-1];
							layer = [sublayers lastObject];
							CGAffineTransform anchorTransform = CGAffineTransformMakeTranslation(expectedAttributes.anchorPoint.x*CGRectGetWidth(expectedAttributes.bounds), expectedAttributes.anchorPoint.y*CGRectGetHeight(expectedAttributes.bounds));
							
							expectedPosition = [NSValue valueWithPoint:CGPointApplyAffineTransform(expectedAttributes.position, anchorTransform)];
						});
						it(@"should have the correct bounds", ^{
							NSValue *expectedBounds = [NSValue valueWithRect:expectedAttributes.bounds];
							[[[NSValue valueWithRect:layer.bounds] should] equal:expectedBounds];
						});
						it(@"should have the correct position", ^{
							[[[NSValue valueWithPoint:layer.position] should] equal:expectedPosition];
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
						it(@"should have an index of zero", ^{
							[[[layer valueForKey:@"mmCoverFlowLayerIndex"] should] equal:theValue(expectedAttributes.index)];
						});
					});
				});
			});
			context(@"NSAccessibility", ^{
				beforeEach(^{
					sut.bounds = CGRectMake(0, 0, 100, 50);
					[sut reloadContent];
				});
				context(@"NSAccessibilitySelectedChildrenAttribute", ^{
					it(@"should return only one selected layer", ^{
						[[[sut accessibilityAttributeValue:NSAccessibilitySelectedChildrenAttribute] should] haveCountOf:1];
					});
					it(@"should return the selected layer", ^{
						[[[sut accessibilityAttributeValue:NSAccessibilitySelectedChildrenAttribute] should] containObjectsInArray:@[sublayers[layout.selectedItemIndex]]];
					});
					it(@"should have a writable selected children attribute", ^{
						[[theValue([sut accessibilityIsAttributeSettable:NSAccessibilitySelectedChildrenAttribute]) should] beYes];
					});
					it(@"should set the selected children", ^{
						NSArray *nextLayer = [sublayers objectsAtIndexes:[NSIndexSet indexSetWithIndex:layout.selectedItemIndex+1]];
						[sut accessibilitySetValue:nextLayer forAttribute:NSAccessibilitySelectedChildrenAttribute];
						
						[[[sut accessibilityAttributeValue:NSAccessibilitySelectedChildrenAttribute] should] containObjectsInArray:nextLayer];
					});
				});
				context(@"NSAccessibilityVisibleChildrenAttribute", ^{
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
						[[visibleChildren should] contain:sublayers[layout.selectedItemIndex]];
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
