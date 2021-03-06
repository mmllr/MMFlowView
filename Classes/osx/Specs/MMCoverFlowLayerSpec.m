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
//  MMCoverFlowLayerSpec.m
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
		it(@"should be a CALayer", ^{
			[[sut should] beKindOfClass:[CALayer class]];
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
		it(@"should have default bounds of CGRectZero", ^{
			[[theValue(sut.bounds) should] equal:theValue(CGRectZero)];
		});
		it(@"should have empty visible item indexes", ^{
			[[sut.visibleItemIndexes should] equal:[NSIndexSet indexSet]];
		});
		it(@"should have one sublayer", ^{
			[[[sut should] have:1] sublayers];
		});
		context(@"transformLayer", ^{
			__block CALayer *transformLayer = nil;

			beforeEach(^{
				transformLayer = [sut.sublayers firstObject];
			});
			afterEach(^{
				transformLayer = nil;
			});
			it(@"should have a CATransformLayer as its only sublayer", ^{
				[[transformLayer should] beKindOfClass:[CATransformLayer class]];
			});
			it(@"should have a sublayerTransform with m34 equal to one divided by -eyeDistance", ^{
				CATransform3D expectedTransform = CATransform3DIdentity;
				expectedTransform.m34 = 1. / -sut.eyeDistance;
				[[[NSValue valueWithCATransform3D:transformLayer.sublayerTransform] should] equal:[NSValue valueWithCATransform3D:expectedTransform]];
			});
			it(@"should have one sublayer", ^{
				[[[transformLayer should] have:1] sublayers];
			});
			it(@"should be horizontally resizable", ^{
				[[theValue(transformLayer.autoresizingMask & kCALayerWidthSizable) should] beYes];
			});
			it(@"should be vertically resizable", ^{
				[[theValue(transformLayer.autoresizingMask & kCALayerHeightSizable) should] beYes];
			});
			context(@"core animation actions", ^{
				__block NSDictionary *actions = nil;
				beforeEach(^{
					actions = transformLayer.actions;
				});
				afterEach(^{
					actions = nil;
				});
				it(@"should have disabled the bounds action", ^{
					[[actions[@"bounds"] should] equal:[NSNull null]];
				});
				it(@"should have disabled the position action", ^{
					[[actions[@"position"] should] equal:[NSNull null]];
				});
			});
		});
		it(@"should have a scroll duration of .4 seconds", ^{
			[[theValue(sut.scrollDuration) should] equal:theValue(.4)];
		});
		it(@"should have an anchorPoint of 0.5, 0.5", ^{
			NSValue *expectedPoint = [NSValue valueWithPoint:NSMakePoint(.5, .5)];
			[[[NSValue valueWithPoint:sut.anchorPoint] should] equal:expectedPoint];
		});
		it(@"should have a position of 0,0", ^{
			[[theValue(sut.frame.origin) should] equal:theValue(CGPointZero)];
		});
		it(@"should have a default eye distance of 1500", ^{
			[[theValue(sut.eyeDistance) should] equal:theValue(1500.)];
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
		it(@"should initally have a selectedItemFrame of CGRectZero", ^{
			NSValue *expectedFrame = [NSValue valueWithRect:CGRectZero];
			[[[NSValue valueWithRect:sut.selectedItemFrame] should] equal:expectedFrame];
		});
		it(@"should not initially show reflections", ^{
			[[theValue(sut.showsReflection) should] beNo];
		});
		context(@"replicatorLayer", ^{
			__block CAReplicatorLayer *replicatorLayer = nil;
			beforeEach(^{
				CALayer *transformLayer = [sut.sublayers firstObject];
				replicatorLayer = [transformLayer.sublayers firstObject];
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
			it(@"should match the suts bounds", ^{
				[[theValue(replicatorLayer.frame) should] equal:theValue(sut.bounds)];
			});
			it(@"should have a width sizeable autoResizingMask", ^{
				[[theValue(replicatorLayer.autoresizingMask & kCALayerWidthSizable) should] beYes];
			});
			it(@"should have a height sizeable autoResizingMask", ^{
				[[theValue(replicatorLayer.autoresizingMask & kCALayerHeightSizable) should] beYes];
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
			context(@"core animation actions", ^{
				__block NSDictionary *actions = nil;
				beforeEach(^{
					actions = replicatorLayer.actions;
				});
				afterEach(^{
					actions = nil;
				});
				it(@"should have disabled the bounds action", ^{
					[[actions[NSStringFromSelector(@selector(bounds))] should] equal:[NSNull null]];
				});
				it(@"should have disabled the position action", ^{
					[[actions[NSStringFromSelector(@selector(position))] should] equal:[NSNull null]];
				});
				it(@"should have disabled the instanceTransform action", ^{
					[[actions[NSStringFromSelector(@selector(instanceTransform))] should] equal:[NSNull null]];
				});
			});
			context(NSStringFromSelector(@selector(instanceTransform)), ^{
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
			context(NSStringFromSelector(@selector(reflectionOffset)), ^{
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
			context(NSStringFromSelector(@selector(showsReflection)), ^{
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
		context(NSStringFromSelector(@selector(eyeDistance)), ^{
			beforeEach(^{
				sut.eyeDistance = 1000;
			});
			it(@"should set the eyeDistance", ^{
				[[theValue(sut.eyeDistance) should] equal:theValue(1000)];
			});
			it(@"should set a sublayerTransform with m34 equal to one divided by -eyeDistance to the transformLayer", ^{
				CATransformLayer *mockedTransformLayer = [CATransformLayer nullMock];
				[sut setValue:mockedTransformLayer forKeyPath:@"transformLayer"];

				CGFloat newEyeDistance = 1100;
				CATransform3D expectedTransform = CATransform3DIdentity;
				expectedTransform.m34 = 1. / -newEyeDistance;
				[[mockedTransformLayer should] receive:@selector(setSublayerTransform:) withArguments:theValue(expectedTransform)];

				sut.eyeDistance = newEyeDistance;
			});
		});
		context(NSStringFromSelector(@selector(reloadContent)), ^{
			it(@"should trigger a relayout", ^{
				[[sut should] receive:@selector(layoutSublayers)];
				[sut reloadContent];
			});
		});
		context(NSStringFromSelector(@selector(setInLiveResize:)), ^{
			it(@"should trigger a relayout when set to NO", ^{
				[[sut should] receive:@selector(setNeedsLayout)];
				[sut setInLiveResize:NO];
			});
			it(@"should not trigger a relayout when set to YES", ^{
				[[sut shouldNot] receive:@selector(setNeedsLayout)];
				[sut setInLiveResize:YES];
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
		context(NSStringFromSelector(@selector(visibleItemIndexes)), ^{
			CGRect visibleLayoutRect = CGRectMake(0, 0, 400, 300);
			CGRect visibleContentLayerRect = CGRectInset(visibleLayoutRect, 40, 40);
			__block NSArray *contentLayers = nil;
			__block CALayer *invisibleLayer = nil;
			__block CALayer *visibleLayer = nil;
			__block NSUInteger firstVisibleIndex = 0;
			__block NSUInteger lastVisibleIndex = 0;

			beforeEach(^{
				sut.bounds = visibleLayoutRect;

				visibleLayer = [CALayer nullMock];
				[visibleLayer stub:@selector(frame) andReturn:theValue(visibleContentLayerRect)];
				invisibleLayer = [CALayer nullMock];
				[invisibleLayer stub:@selector(frame) andReturn:theValue(CGRectMake(-80, 0, 40, 40))];
			});
			afterEach(^{
				visibleLayer = nil;
				invisibleLayer = nil;
				contentLayers = nil;
			});

			context(@"when the first and the last layer are not visible", ^{
				beforeEach(^{
					contentLayers = @[invisibleLayer, invisibleLayer, invisibleLayer, visibleLayer, visibleLayer, visibleLayer, invisibleLayer, invisibleLayer, invisibleLayer];
					[sut stub:@selector(contentLayers) andReturn:contentLayers];
					firstVisibleIndex = 3;
					lastVisibleIndex = 5;
				});
				it(@"should have the two invisible layers before the first visible layer as the first visible index", ^{
					[sut layoutSublayers];
					[[theValue([sut.visibleItemIndexes firstIndex]) should] equal:theValue(firstVisibleIndex-2)];
				});
				it(@"should have two invisible layers after the last visible layer as the last visible index", ^{
					[sut layoutSublayers];
					[[theValue([sut.visibleItemIndexes lastIndex]) should] equal:theValue(lastVisibleIndex+2)];
				});
			});
			context(@"when the first layer is visible", ^{
				beforeEach(^{
					contentLayers = @[visibleLayer, visibleLayer, visibleLayer, invisibleLayer, invisibleLayer];
					[sut stub:@selector(contentLayers) andReturn:contentLayers];
				});
				it(@"should have zero as the first visible index", ^{
					[sut layoutSublayers];
					[[theValue([sut.visibleItemIndexes firstIndex]) should] beZero];
				});
			});
			context(@"when the last layer is visible", ^{
				beforeEach(^{
					contentLayers = @[invisibleLayer, invisibleLayer, visibleLayer, visibleLayer, visibleLayer, visibleLayer];
					[sut stub:@selector(contentLayers) andReturn:contentLayers];
					[sut stub:@selector(numberOfItems) andReturn:theValue([contentLayers count])];
				});
				it(@"should have the last layers index as the last visible index", ^{
					[sut layoutSublayers];
					[[theValue([sut.visibleItemIndexes lastIndex]) should] equal:theValue(sut.numberOfItems - 1)];
				});
			});

			context(@"when having one layer which is visible", ^{
				beforeEach(^{
					contentLayers = @[visibleLayer];
					[sut stub:@selector(contentLayers) andReturn:contentLayers];
					[sut stub:@selector(numberOfItems) andReturn:theValue([contentLayers count])];
				});
				it(@"should have zero as the first visible index", ^{
					[sut layoutSublayers];
					[[theValue([sut.visibleItemIndexes firstIndex]) should] beZero];
				});
				it(@"should have zero as the last visible index", ^{
					[sut layoutSublayers];
					[[theValue([sut.visibleItemIndexes lastIndex]) should] beZero];
				});
			});
			context(@"when many layers and only one is visible", ^{
				beforeEach(^{
					contentLayers = @[invisibleLayer, invisibleLayer, visibleLayer, invisibleLayer, invisibleLayer, invisibleLayer];
					[sut stub:@selector(contentLayers) andReturn:contentLayers];
					[sut stub:@selector(numberOfItems) andReturn:theValue([contentLayers count])];
					firstVisibleIndex = lastVisibleIndex = 2;
				});
				it(@"should have the two invisible layers before the first visible layer as the first visible index", ^{
					[sut layoutSublayers];
					[[theValue([sut.visibleItemIndexes firstIndex]) should] equal:theValue(firstVisibleIndex-2)];
				});
				it(@"should have two invisible layers after the last visible layer as the last visible index", ^{
					[sut layoutSublayers];
					[[theValue([sut.visibleItemIndexes lastIndex]) should] equal:theValue(lastVisibleIndex+2)];
				});
			});
			context(@"when all layers are visible", ^{
				beforeEach(^{
					contentLayers = @[visibleLayer, visibleLayer, visibleLayer, visibleLayer];
					[sut stub:@selector(contentLayers) andReturn:contentLayers];
					[sut stub:@selector(numberOfItems) andReturn:theValue([contentLayers count])];
				});
				it(@"should have zero as the first visible index", ^{
					[sut layoutSublayers];
					[[theValue([sut.visibleItemIndexes firstIndex]) should] beZero];
				});
				it(@"should have the last layers index as the last visible index", ^{
					[sut layoutSublayers];
					[[theValue([sut.visibleItemIndexes lastIndex]) should] equal:theValue(sut.numberOfItems - 1)];
				});
			});
		});
		context(@"datasource", ^{
			__block id datasourceMock = nil;
			__block NSArray *sublayers = nil;

			beforeEach(^{
				datasourceMock = [KWMock nullMockForProtocol:@protocol(MMCoverFlowLayerDataSource)];
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
				sut.bounds = CGRectMake(0, 0, 600, 300);
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
					it(@"should return an NSArray", ^{
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
				context(NSStringFromSelector(@selector(visibleItemIndexes)), ^{
					it(@"should have nonzero visible items", ^{
						[[theValue([sut.visibleItemIndexes count]) shouldNot] beZero];
					});
					it(@"should contain the selected index", ^{
						[[theValue([sut.visibleItemIndexes containsIndex:layout.selectedItemIndex]) should] beYes];
					});
				});
			});
			context(NSStringFromSelector(@selector(layoutSublayers)), ^{
				it(@"should invoke coverFlowLayerWillRelayout when triggering relayout", ^{
					[[datasourceMock should] receive:@selector(coverFlowLayerWillRelayout:)];
					[sut layoutSublayers];
				});
				it(@"should invoke coverFlowLayerDidRelayout after finishing relayout", ^{
					[[datasourceMock shouldEventually] receive:@selector(coverFlowLayerDidRelayout:) withCountAtLeast:1];
					[sut layoutSublayers];
				});

				context(NSStringFromSelector(@selector(coverFlowLayer:willShowLayer:atIndex:)), ^{

					it(@"should invoke coverFlowLayer:willShowLayer:atIndex: for every visible layer", ^{

						[sut.visibleItemIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
							[[datasourceMock should] receive:@selector(coverFlowLayer:willShowLayer:atIndex:) withArguments:sut, sublayers[idx], theValue(idx)];
						}];

						[sut layoutSublayers];
					});
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
							expectedPosition = [NSValue valueWithPoint:expectedAttributes.position];
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
					context(NSStringFromSelector(@selector(indexOfLayerAtPoint:)), ^{
						__block CGPoint pointInLayer;
						__block NSUInteger expectedIndex;

						context(@"when point is not over any content layer", ^{
							beforeEach(^{
								pointInLayer =  [sut convertPoint:CGPointMake(-1000, -1000) toLayer:sut.superlayer];
							});
							it(@"should return NSNotFound", ^{
								[[theValue([sut indexOfLayerAtPoint:pointInLayer]) should] equal:theValue(NSNotFound)];
							});
						});
						context(@"when point is over the selected layer", ^{
							beforeEach(^{
								pointInLayer =  [sut convertPoint:CGPointMake(CGRectGetMidX(sut.selectedItemFrame), CGRectGetMidY(sut.selectedItemFrame)) toLayer:sut];
							});
							it(@"should return the index of the selected layer", ^{
								[[theValue([sut indexOfLayerAtPoint:pointInLayer]) should] equal:theValue(sut.layout.selectedItemIndex)];
							});
						});
						context(@"when point is over first visible layer", ^{
							beforeEach(^{
								expectedIndex = sut.visibleItemIndexes.firstIndex;
								layer = sublayers[expectedIndex];
								pointInLayer = [sut convertPoint:CGPointMake(CGRectGetMaxX(layer.frame), CGRectGetMidY(layer.frame))
														 fromLayer:layer.superlayer];
							});
							it(@"should return the index of the first visible layer", ^{
								[[theValue([sut indexOfLayerAtPoint:pointInLayer]) should] equal:theValue(expectedIndex)];
							});
						});
						context(@"when point is over last visible layer", ^{
							beforeEach(^{
								expectedIndex = sut.visibleItemIndexes.lastIndex;
								layer = sublayers[expectedIndex];
								pointInLayer = [sut convertPoint:CGPointMake(CGRectGetMinX(layer.frame), CGRectGetMidY(layer.frame))
														 toLayer:sut];
							});
							it(@"should return the index of the last visible layer", ^{
								[[theValue([sut indexOfLayerAtPoint:pointInLayer]) should] equal:theValue(expectedIndex)];
							});
						});
					});
				});
			});
			context(@"NSAccessibility", ^{
				beforeEach(^{
					sut.bounds = CGRectMake(0, 0, 100, 50);
					[sut reloadContent];
				});
				context(NSAccessibilitySelectedChildrenAttribute, ^{
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
				context(NSAccessibilityVisibleChildrenAttribute, ^{
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
