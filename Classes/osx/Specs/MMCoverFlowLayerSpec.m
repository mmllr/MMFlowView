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
//  Created by Markus Müller on 23.10.13.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMCoverFlowLayer.h"
#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayoutAttributes.h"
#import "CALayer+NSAccessibility.h"
#import "MMFlowViewTestDoubles.h"

@interface MMCoverFlowLayerSpec : XCTestCase

@end

@implementation MMCoverFlowLayerSpec
{
	MMCoverFlowLayerRecordingSubclass *_sut;
	MMCoverFlowLayout *_layout;
	MMTestCoverFlowLayerDataSource *_dataSource;
}

- (void)setUp
{
	[super setUp];
	_layout = [[MMCoverFlowLayout alloc] init];
	_sut = [[MMCoverFlowLayerRecordingSubclass alloc] initWithLayout:_layout];
}

- (void)tearDown
{
	_sut = nil;
	_layout = nil;
	_dataSource = nil;
	[super tearDown];
}

#pragma mark - creation

- (void)testThrowsWhenCreatedWithLayer
{
	XCTAssertThrowsSpecificNamed([MMCoverFlowLayer layer], NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithInit
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMCoverFlowLayerRecordingSubclass alloc] init]), NSException, NSInternalInconsistencyException);
}

#pragma mark - defaults

- (void)testInstanceExists
{
	XCTAssertNotNil(_sut);
}

- (void)testIsACALayer
{
	XCTAssertTrue([_sut isKindOfClass:[CALayer class]]);
}

- (void)testHorizontallyResizable
{
	XCTAssertTrue((_sut.autoresizingMask & kCALayerWidthSizable) != 0);
}

- (void)testVerticallyResizable
{
	XCTAssertTrue((_sut.autoresizingMask & kCALayerHeightSizable) != 0);
}

- (void)testZeroItems
{
	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)0);
}

- (void)testDoesNotMaskToBounds
{
	XCTAssertFalse(_sut.masksToBounds);
}

- (void)testDefaultBoundsAreZero
{
	XCTAssertTrue(CGRectEqualToRect(_sut.bounds, CGRectZero));
}

- (void)testEmptyVisibleItemIndexes
{
	XCTAssertEqualObjects(_sut.visibleItemIndexes, [NSIndexSet indexSet]);
}

- (void)testOneSublayer
{
	XCTAssertEqual([_sut.sublayers count], (NSUInteger)1);
}

- (void)testTransformLayerIsCATransformLayer
{
	CALayer *transformLayer = [_sut.sublayers firstObject];
	XCTAssertTrue([transformLayer isKindOfClass:[CATransformLayer class]]);
}

- (void)testTransformLayerSublayerTransform
{
	CALayer *transformLayer = [_sut.sublayers firstObject];
	CATransform3D expectedTransform = CATransform3DIdentity;
	expectedTransform.m34 = 1. / -_sut.eyeDistance;
	XCTAssertTrue(CATransform3DEqualToTransform(transformLayer.sublayerTransform, expectedTransform));
}

- (void)testTransformLayerHasOneSublayer
{
	CALayer *transformLayer = [_sut.sublayers firstObject];
	XCTAssertEqual([transformLayer.sublayers count], (NSUInteger)1);
}

- (void)testTransformLayerResizable
{
	CALayer *transformLayer = [_sut.sublayers firstObject];
	XCTAssertTrue((transformLayer.autoresizingMask & kCALayerWidthSizable) != 0);
	XCTAssertTrue((transformLayer.autoresizingMask & kCALayerHeightSizable) != 0);
}

- (void)testTransformLayerDisabledBoundsAction
{
	CALayer *transformLayer = [_sut.sublayers firstObject];
	XCTAssertEqualObjects(transformLayer.actions[@"bounds"], [NSNull null]);
	XCTAssertEqualObjects(transformLayer.actions[@"position"], [NSNull null]);
}

- (void)testScrollDuration
{
	XCTAssertEqual(_sut.scrollDuration, (CFTimeInterval).4);
}

- (void)testAnchorPoint
{
	XCTAssertTrue(CGPointEqualToPoint(_sut.anchorPoint, CGPointMake(.5, .5)));
}

- (void)testFrameOrigin
{
	XCTAssertTrue(CGPointEqualToPoint(_sut.frame.origin, CGPointZero));
}

- (void)testDefaultEyeDistance
{
	XCTAssertEqual(_sut.eyeDistance, (CGFloat)1500.);
}

- (void)testNotInitiallyInLiveResize
{
	XCTAssertFalse(_sut.inLiveResize);
}

- (void)testIsItsOwnDelegate
{
	XCTAssertEqualObjects(_sut.delegate, _sut);
}

- (void)testNoDataSource
{
	XCTAssertNil(_sut.dataSource);
}

- (void)testSelectedItemFrameInitiallyZero
{
	XCTAssertTrue(CGRectEqualToRect(_sut.selectedItemFrame, CGRectZero));
}

- (void)testNoReflectionsInitially
{
	XCTAssertFalse(_sut.showsReflection);
}

#pragma mark - replicator layer

- (CAReplicatorLayer *)replicatorLayer
{
	CALayer *transformLayer = [_sut.sublayers firstObject];
	return [transformLayer.sublayers firstObject];
}

- (void)testReplicatorLayerExists
{
	CAReplicatorLayer *replicatorLayer = [self replicatorLayer];
	XCTAssertNotNil(replicatorLayer);
	XCTAssertTrue([replicatorLayer isKindOfClass:[CAReplicatorLayer class]]);
}

- (void)testReplicatorLayerMatchesSutBounds
{
	_sut.bounds = CGRectMake(0, 0, 100, 50);
	CAReplicatorLayer *replicatorLayer = [self replicatorLayer];
	XCTAssertTrue(CGRectEqualToRect(replicatorLayer.frame, _sut.bounds));
}

- (void)testReplicatorLayerResizableAndPreservesDepth
{
	CAReplicatorLayer *replicatorLayer = [self replicatorLayer];
	XCTAssertTrue((replicatorLayer.autoresizingMask & kCALayerWidthSizable) != 0);
	XCTAssertTrue((replicatorLayer.autoresizingMask & kCALayerHeightSizable) != 0);
	XCTAssertTrue(replicatorLayer.preservesDepth);
}

- (void)testReplicatorLayerInstanceCountAndOffsets
{
	CAReplicatorLayer *replicatorLayer = [self replicatorLayer];
	XCTAssertEqual(replicatorLayer.instanceCount, 1);
	XCTAssertEqualWithAccuracy(replicatorLayer.instanceRedOffset, _sut.reflectionOffset, .000001);
	XCTAssertEqualWithAccuracy(replicatorLayer.instanceGreenOffset, _sut.reflectionOffset, .000001);
	XCTAssertEqualWithAccuracy(replicatorLayer.instanceBlueOffset, _sut.reflectionOffset, .000001);
}

- (void)testReplicatorLayerDisabledActions
{
	CAReplicatorLayer *replicatorLayer = [self replicatorLayer];
	XCTAssertEqualObjects(replicatorLayer.actions[NSStringFromSelector(@selector(bounds))], [NSNull null]);
	XCTAssertEqualObjects(replicatorLayer.actions[NSStringFromSelector(@selector(position))], [NSNull null]);
	XCTAssertEqualObjects(replicatorLayer.actions[NSStringFromSelector(@selector(instanceTransform))], [NSNull null]);
}

- (void)testReplicatorLayerInstanceTransform
{
	CAReplicatorLayer *replicatorLayer = [self replicatorLayer];
	[_sut layoutSublayers];
	CATransform3D expectedTransform = CATransform3DConcat(CATransform3DMakeScale(1, -1, 1), CATransform3DMakeTranslation(0, -_sut.layout.itemSize.height, 0));
	XCTAssertTrue(CATransform3DEqualToTransform(replicatorLayer.instanceTransform, expectedTransform));
}

- (void)testReflectionOffsetDefaultAndClamping
{
	XCTAssertEqualWithAccuracy(_sut.reflectionOffset, (CGFloat)-.4, .0000001);
	_sut.reflectionOffset = 0.5;
	XCTAssertEqualWithAccuracy(_sut.reflectionOffset, 0, .0000001);
	_sut.reflectionOffset = -2;
	XCTAssertEqualWithAccuracy(_sut.reflectionOffset, -1, .0000001);
}

- (void)testReflectionOffsetPropagatesToReplicator
{
	CAReplicatorLayer *replicatorLayer = [self replicatorLayer];
	_sut.reflectionOffset = -.2;
	XCTAssertEqualWithAccuracy(replicatorLayer.instanceRedOffset, -.2, .000001);
	XCTAssertEqualWithAccuracy(replicatorLayer.instanceGreenOffset, -.2, .000001);
	XCTAssertEqualWithAccuracy(replicatorLayer.instanceBlueOffset, -.2, .000001);
}

- (void)testShowsReflectionTogglesReplicatorInstanceCount
{
	CAReplicatorLayer *replicatorLayer = [self replicatorLayer];
	_sut.showsReflection = YES;
	XCTAssertTrue(_sut.showsReflection);
	XCTAssertEqual(replicatorLayer.instanceCount, 2);
	_sut.showsReflection = NO;
	XCTAssertFalse(_sut.showsReflection);
	XCTAssertEqual(replicatorLayer.instanceCount, 1);
}

#pragma mark - observing layout changes

- (void)testNumberOfItemsChangeTriggersReload
{
	NSUInteger before = _sut.reloadContentCallCount;
	_sut.layout.numberOfItems = 10;
	XCTAssertGreaterThan(_sut.reloadContentCallCount, before);
}

- (void)testLayoutChangesTriggerRelayout
{
	NSUInteger before = _sut.setNeedsLayoutCallCount;
	_sut.layout.stackedAngle = 20;
	XCTAssertGreaterThan(_sut.setNeedsLayoutCallCount, before);

	before = _sut.setNeedsLayoutCallCount;
	_sut.layout.interItemSpacing = 100;
	XCTAssertGreaterThan(_sut.setNeedsLayoutCallCount, before);

	before = _sut.setNeedsLayoutCallCount;
	_sut.layout.stackedDistance = 50;
	XCTAssertGreaterThan(_sut.setNeedsLayoutCallCount, before);

	before = _sut.setNeedsLayoutCallCount;
	_sut.layout.verticalMargin = 5;
	XCTAssertGreaterThan(_sut.setNeedsLayoutCallCount, before);
}

#pragma mark - eyeDistance

- (void)testEyeDistanceSetsSublayerTransform
{
	CATransformLayer *transformLayer = [_sut.sublayers firstObject];
	_sut.eyeDistance = 1100;
	CATransform3D expectedTransform = CATransform3DIdentity;
	expectedTransform.m34 = 1. / -1100;
	XCTAssertTrue(CATransform3DEqualToTransform(transformLayer.sublayerTransform, expectedTransform));
}

#pragma mark - reload / live resize

- (void)testReloadContentTriggersRelayout
{
	NSUInteger before = _sut.layoutSublayersCallCount;
	[_sut reloadContent];
	XCTAssertGreaterThan(_sut.layoutSublayersCallCount, before);
}

- (void)testSetInLiveResizeNoTriggersRelayout
{
	NSUInteger before = _sut.setNeedsLayoutCallCount;
	[_sut setInLiveResize:NO];
	XCTAssertGreaterThan(_sut.setNeedsLayoutCallCount, before);
}

- (void)testSetInLiveResizeYesDoesNotTriggerRelayout
{
	NSUInteger before = _sut.setNeedsLayoutCallCount;
	[_sut setInLiveResize:YES];
	XCTAssertEqual(_sut.setNeedsLayoutCallCount, before);
}

#pragma mark - NSAccessibility defaults

- (void)testAccessibilityNotIgnored
{
	XCTAssertFalse([_sut accessibilityIsIgnored]);
}

- (void)testAccessibilityRoleIsList
{
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityRoleAttribute], NSAccessibilityListRole);
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilitySubroleAttribute], NSAccessibilityContentListSubrole);
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityOrientationAttribute], NSAccessibilityHorizontalOrientationValue);
}

- (void)testAccessibilitySelectedChildrenSettable
{
	XCTAssertTrue([_sut accessibilityIsAttributeSettable:NSAccessibilitySelectedChildrenAttribute]);
}

#pragma mark - CoreAnimation actions

- (void)testBoundsActionDisabledWhileLiveResizing
{
	_sut.inLiveResize = YES;
	XCTAssertEqualObjects([_sut.delegate actionForLayer:_sut forKey:@"bounds"], [NSNull null]);
}

- (void)testNoBoundsActionWhenNotLiveResizing
{
	_sut.inLiveResize = NO;
	XCTAssertNil([_sut.delegate actionForLayer:_sut forKey:@"bounds"]);
}

#pragma mark - datasource and content

- (NSArray *)makeContentLayers
{
	NSMutableArray *sublayers = [NSMutableArray array];
	for (NSUInteger i = 0; i < 8; i++) {
		[sublayers addObject:[CALayer layer]];
	}
	return sublayers;
}

- (void)setUpDatasourceWithLayers:(NSArray *)sublayers
{
	_dataSource = [[MMTestCoverFlowLayerDataSource alloc] init];
	_dataSource.contentLayerForAllItems = nil;
	_dataSource.requestedLayers = sublayers;
	_sut.bounds = CGRectMake(0, 0, 600, 300);
	_sut.dataSource = _dataSource;
	_sut.layout.numberOfItems = [sublayers count];
	[_sut reloadContent];
}

- (void)testLoadingContent
{
	NSArray *sublayers = [self makeContentLayers];
	[self setUpDatasourceWithLayers:sublayers];

	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)[sublayers count]);
	XCTAssertNotNil(_sut.contentLayers);
	XCTAssertTrue([_sut.contentLayers isKindOfClass:[NSArray class]]);
	XCTAssertEqual([_sut.contentLayers count], [sublayers count]);
	XCTAssertEqualObjects(_sut.contentLayers, sublayers);
}

- (void)testSelectionAndVisibleItemIndexes
{
	NSArray *sublayers = [self makeContentLayers];
	[self setUpDatasourceWithLayers:sublayers];

	_sut.layout.selectedItemIndex = _sut.numberOfItems / 2;
	[_sut layoutSublayers];

	XCTAssertEqual(_sut.layout.selectedItemIndex, _sut.numberOfItems / 2);
	XCTAssertGreaterThan([_sut.visibleItemIndexes count], (NSUInteger)0);
	XCTAssertTrue([_sut.visibleItemIndexes containsIndex:_sut.layout.selectedItemIndex]);
}

- (void)testScrollsToSelectedItem
{
	NSArray *sublayers = [self makeContentLayers];
	[self setUpDatasourceWithLayers:sublayers];

	_sut.layout.selectedItemIndex = _sut.numberOfItems / 2;
	[_sut layoutSublayers];

	MMCoverFlowLayoutAttributes *attr = [_layout layoutAttributesForItemAtIndex:_sut.layout.selectedItemIndex];
	CGPoint expectedPoint = CGPointMake(attr.position.x - (CGRectGetWidth(_sut.bounds) / 2.) + _layout.itemSize.width / 2., 0);
	XCTAssertTrue(CGPointEqualToPoint(_sut.bounds.origin, expectedPoint));
}

- (void)testLayerAttributesApplied
{
	NSArray *sublayers = [self makeContentLayers];
	[self setUpDatasourceWithLayers:sublayers];

	_sut.layout.selectedItemIndex = _sut.numberOfItems / 2;
	[_sut layoutSublayers];

	NSArray *indexesToCheck = @[@0,
								@(_sut.layout.selectedItemIndex - 1),
								@(_sut.layout.selectedItemIndex),
								@(_sut.layout.selectedItemIndex + 1),
								@(_sut.numberOfItems - 1)];
	for (NSNumber *indexNumber in indexesToCheck) {
		NSUInteger idx = [indexNumber unsignedIntegerValue];
		CALayer *layer = _sut.contentLayers[idx];
		MMCoverFlowLayoutAttributes *expectedAttributes = [_layout layoutAttributesForItemAtIndex:idx];
		CGAffineTransform anchorTransform = CGAffineTransformMakeTranslation(expectedAttributes.anchorPoint.x * CGRectGetWidth(expectedAttributes.bounds), expectedAttributes.anchorPoint.y * CGRectGetHeight(expectedAttributes.bounds));
		CGPoint expectedPosition = CGPointApplyAffineTransform(expectedAttributes.position, anchorTransform);

		XCTAssertTrue(CGRectEqualToRect(layer.bounds, expectedAttributes.bounds));
		if (idx == _sut.layout.selectedItemIndex) {
			XCTAssertTrue(CGPointEqualToPoint(layer.frame.origin, expectedAttributes.position));
			XCTAssertEqual(CGRectGetMidX(layer.frame), CGRectGetMidX(_sut.bounds));
		} else {
			XCTAssertTrue(CGPointEqualToPoint(layer.position, expectedPosition));
		}
		XCTAssertTrue(CGPointEqualToPoint(layer.anchorPoint, expectedAttributes.anchorPoint));
		XCTAssertEqual(layer.zPosition, expectedAttributes.zPosition);
		XCTAssertTrue(CATransform3DEqualToTransform(layer.transform, expectedAttributes.transform));
		XCTAssertEqualObjects([layer valueForKey:@"mmCoverFlowLayerIndex"], @(expectedAttributes.index));
	}
}

- (void)testSelectedItemFrame
{
	NSArray *sublayers = [self makeContentLayers];
	[self setUpDatasourceWithLayers:sublayers];

	_sut.layout.selectedItemIndex = _sut.numberOfItems / 2;
	[_sut layoutSublayers];

	CALayer *selectedLayer = _sut.contentLayers[_sut.layout.selectedItemIndex];
	NSValue *expectedRect = [NSValue valueWithRect:[_sut convertRect:selectedLayer.visibleRect fromLayer:selectedLayer]];
	XCTAssertEqualObjects([NSValue valueWithRect:_sut.selectedItemFrame], expectedRect);
}

#pragma mark - indexOfLayerAtPoint

- (void)testIndexOfLayerAtPointNotOverContentReturnsNotFound
{
	NSArray *sublayers = [self makeContentLayers];
	[self setUpDatasourceWithLayers:sublayers];
	_sut.layout.selectedItemIndex = _sut.numberOfItems / 2;
	[_sut layoutSublayers];

	CGPoint pointInLayer = [_sut convertPoint:CGPointMake(-1000, -1000) toLayer:_sut.superlayer];
	XCTAssertEqual([_sut indexOfLayerAtPoint:pointInLayer], (NSUInteger)NSNotFound);
}

- (void)testIndexOfLayerAtPointOverSelectedLayer
{
	NSArray *sublayers = [self makeContentLayers];
	[self setUpDatasourceWithLayers:sublayers];
	_sut.layout.selectedItemIndex = _sut.numberOfItems / 2;
	[_sut layoutSublayers];

	CGPoint pointInLayer = [_sut convertPoint:CGPointMake(CGRectGetMidX(_sut.selectedItemFrame), CGRectGetMidY(_sut.selectedItemFrame)) toLayer:_sut];
	XCTAssertEqual([_sut indexOfLayerAtPoint:pointInLayer], _sut.layout.selectedItemIndex);
}

- (void)testIndexOfLayerAtPointOverFirstVisibleLayer
{
	NSArray *sublayers = [self makeContentLayers];
	[self setUpDatasourceWithLayers:sublayers];
	_sut.layout.selectedItemIndex = _sut.numberOfItems / 2;
	[_sut layoutSublayers];

	NSUInteger expectedIndex = _sut.visibleItemIndexes.firstIndex;
	CALayer *layer = _sut.contentLayers[expectedIndex];
	CGPoint pointInLayer = [_sut convertPoint:CGPointMake(CGRectGetMaxX(layer.frame), CGRectGetMidY(layer.frame)) fromLayer:layer.superlayer];
	XCTAssertEqual([_sut indexOfLayerAtPoint:pointInLayer], expectedIndex);
}

#pragma mark - accessibility with content

- (void)testAccessibilityVisibleAndSelectedChildrenWithContent
{
	NSArray *sublayers = [self makeContentLayers];
	for (CALayer *layer in sublayers) {
		[layer setReadableAccessibilityAttribute:NSAccessibilityRoleAttribute withBlock:^id {
			return NSAccessibilityImageRole;
		}];
	}
	[self setUpDatasourceWithLayers:sublayers];
	_sut.bounds = CGRectMake(0, 0, 100, 50);
	[_sut reloadContent];
	_sut.layout.selectedItemIndex = _sut.numberOfItems / 2;
	[_sut layoutSublayers];

	NSArray *selectedChildren = [_sut accessibilityAttributeValue:NSAccessibilitySelectedChildrenAttribute];
	XCTAssertEqual([selectedChildren count], (NSUInteger)1);
	XCTAssertTrue([selectedChildren containsObject:sublayers[_sut.layout.selectedItemIndex]]);

	NSArray *visibleChildren = [_sut accessibilityAttributeValue:NSAccessibilityVisibleChildrenAttribute];
	XCTAssertGreaterThanOrEqual([visibleChildren count], (NSUInteger)1);
	XCTAssertTrue([visibleChildren containsObject:sublayers[_sut.layout.selectedItemIndex]]);
}

// DISABLED: the original spec additionally verified that layoutSublayers wraps its
// work in CATransaction class calls (begin/commit/setDisableActions:/
// setAnimationDuration:/setAnimationTimingFunction:) and that visibleItemIndexes
// extends by exactly two indexes beyond visible layers with hand-set layer frames.
// The first requires class-level CATransaction interception; the second requires
// stubbing contentLayers with custom frames, both of which need a mocking
// framework. The real layout behavior is covered above.

@end
