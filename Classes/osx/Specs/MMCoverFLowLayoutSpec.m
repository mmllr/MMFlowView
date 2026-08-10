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
//  MMCoverFLowLayoutSpec.m
//
//  Created by Markus Müller on 25.10.13.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayoutAttributes.h"
#import "MMMacros.h"
#import "MMFlowViewTestDoubles.h"

@interface MMCoverFLowLayoutSpec : XCTestCase

@end

@implementation MMCoverFLowLayoutSpec
{
	MMCoverFlowLayout *_sut;
}

static const CGSize visibleSizeFixture = {200, 200};

- (void)setUp
{
	[super setUp];
	_sut = [[MMCoverFlowLayout alloc] init];
}

- (void)tearDown
{
	_sut = nil;
	[super tearDown];
}

- (void)testDesignatedInitializerClampsTooSmallVisibleSize
{
	MMCoverFlowLayout *layout = [[MMCoverFlowLayout alloc] initWithVisibleSize:CGSizeMake(-100, -100)];
	XCTAssertTrue(CGSizeEqualToSize(layout.visibleSize, CGSizeMake(1, 1)));
}

- (void)testDesignatedInitializerSetsVisibleSize
{
	MMCoverFlowLayout *layout = [[MMCoverFlowLayout alloc] initWithVisibleSize:visibleSizeFixture];
	XCTAssertTrue(CGSizeEqualToSize(layout.visibleSize, visibleSizeFixture));
}

- (void)testRespondsToCodingSelectors
{
	XCTAssertTrue([_sut respondsToSelector:@selector(initWithCoder:)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(encodeWithCoder:)]);
}

- (void)testDefaultInterItemSpacing
{
	XCTAssertEqual(_sut.interItemSpacing, (CGFloat)10);
}

- (void)testDefaultStackedAngle
{
	XCTAssertEqual(_sut.stackedAngle, (CGFloat)70);
}

- (void)testDefaultSelectedIndexIsNotFound
{
	XCTAssertEqual(_sut.selectedItemIndex, (NSUInteger)NSNotFound);
}

- (void)testDefaultItemCountIsZero
{
	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)0);
}

- (void)testDefaultVerticalMargin
{
	XCTAssertEqual(_sut.verticalMargin, (CGFloat)10);
}

- (void)testDefaultContentSizeIsZero
{
	XCTAssertTrue(CGSizeEqualToSize(_sut.contentSize, CGSizeZero));
}

- (void)testDefaultVisibleSize
{
	XCTAssertTrue(CGSizeEqualToSize(_sut.visibleSize, CGSizeMake(100, 100)));
}

- (void)testDefaultStackedDistance
{
	XCTAssertEqual(_sut.stackedDistance, (CGFloat)300);
}

- (void)testLayoutAttributesNilWithoutItems
{
	XCTAssertNil([_sut layoutAttributesForItemAtIndex:0]);
}

- (void)testDefaultDelegateIsNil
{
	XCTAssertNil(_sut.delegate);
}

- (void)testItemHeightIsVisibleHeightMinusMargins
{
	CGFloat expectedHeight = _sut.visibleSize.height - 2 * _sut.verticalMargin;
	XCTAssertEqual(_sut.itemSize.height, expectedHeight);
}

- (void)testSquareItemSize
{
	XCTAssertEqual(_sut.itemSize.width, _sut.itemSize.height);
}

- (void)testVisibleSizeClampedToMinimum
{
	_sut.visibleSize = CGSizeZero;
	XCTAssertGreaterThanOrEqual(_sut.visibleSize.height, (CGFloat)1);
	XCTAssertGreaterThanOrEqual(_sut.visibleSize.width, (CGFloat)1);
}

- (void)testVerticalMarginNotBelowZero
{
	_sut.verticalMargin = -10;
	XCTAssertGreaterThanOrEqual(_sut.verticalMargin, (CGFloat)0);
}

- (void)testVerticalMarginNotAboveVisibleHeight
{
	_sut.verticalMargin = _sut.visibleSize.height * 2;
	XCTAssertLessThanOrEqual(_sut.verticalMargin, _sut.visibleSize.height);
}

- (void)testInterItemSpacingRejectsNegativeValues
{
	_sut.interItemSpacing = -10;
	XCTAssertGreaterThan(_sut.interItemSpacing, (CGFloat)0);
}

- (void)testInterItemSpacingMinimumOfOne
{
	_sut.interItemSpacing = 1.f;
	XCTAssertEqual(_sut.interItemSpacing, (CGFloat)1);
}

- (void)testStackedAngleClampsNegativeToZero
{
	_sut.stackedAngle = -10;
	XCTAssertEqual(_sut.stackedAngle, (CGFloat)0);
}

- (void)testStackedAngleAllowsZero
{
	_sut.stackedAngle = 0;
	XCTAssertEqual(_sut.stackedAngle, (CGFloat)0);
}

- (void)testStackedAngleAllowsNinety
{
	_sut.stackedAngle = 90;
	XCTAssertEqual(_sut.stackedAngle, (CGFloat)90);
}

- (void)testStackedAngleClampsAboveNinety
{
	_sut.stackedAngle = 100;
	XCTAssertEqual(_sut.stackedAngle, (CGFloat)90);
}

- (void)testSelectedItemIndexNotSetWithoutItems
{
	_sut.selectedItemIndex = 0;
	XCTAssertEqual(_sut.selectedItemIndex, (NSUInteger)NSNotFound);
}

- (void)testStackedDistanceRejectsNegativeValues
{
	_sut.stackedDistance = -100;
	XCTAssertGreaterThanOrEqual(_sut.stackedDistance, (CGFloat)0);
}

- (void)testSelectsFirstItemWhenAddingItems
{
	_sut.numberOfItems = 10;
	XCTAssertEqual(_sut.selectedItemIndex, (NSUInteger)0);
}

- (void)testSetsNumberOfItems
{
	_sut.numberOfItems = 10;
	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)10);
}

- (void)testSelectsRandomItem
{
	_sut.numberOfItems = 10;
	NSUInteger expectedIndex = arc4random_uniform((u_int32_t)_sut.numberOfItems);
	_sut.selectedItemIndex = expectedIndex;
	XCTAssertEqual(_sut.selectedItemIndex, expectedIndex);
}

- (void)testSelectsLastItem
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = _sut.numberOfItems - 1;
	XCTAssertEqual(_sut.selectedItemIndex, (NSUInteger)9);
}

- (void)testSelectsFirstItem
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = 0;
	XCTAssertEqual(_sut.selectedItemIndex, (NSUInteger)0);
}

- (void)testSelectsLastIndexWhenAskedBeyondItemCount
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = _sut.numberOfItems + 10;
	XCTAssertEqual(_sut.selectedItemIndex, (NSUInteger)9);
}

- (void)testDoesNotSelectNotFound
{
	_sut.numberOfItems = 10;
	NSUInteger previousSelection = _sut.selectedItemIndex;
	_sut.selectedItemIndex = NSNotFound;
	XCTAssertNotEqual(_sut.selectedItemIndex, (NSUInteger)NSNotFound);
	XCTAssertEqual(_sut.selectedItemIndex, previousSelection);
}

- (void)testRemovingAllItemsResetsSelection
{
	_sut.numberOfItems = 10;
	_sut.numberOfItems = 0;
	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)0);
	XCTAssertEqual(_sut.selectedItemIndex, (NSUInteger)NSNotFound);
}

- (void)testNumberOfItemsRejectsNotFound
{
	_sut.numberOfItems = 10;
	NSUInteger expectedSelection = _sut.selectedItemIndex;
	_sut.numberOfItems = NSNotFound;
	XCTAssertNotEqual(_sut.numberOfItems, (NSUInteger)NSNotFound);
	XCTAssertEqual(_sut.selectedItemIndex, expectedSelection);
}

#pragma mark - layout attributes

- (void)testLayoutAttributesForFirstItem
{
	_sut.numberOfItems = 10;
	XCTAssertNotNil([_sut layoutAttributesForItemAtIndex:0]);
}

- (void)testLayoutAttributesForLastItem
{
	_sut.numberOfItems = 10;
	XCTAssertNotNil([_sut layoutAttributesForItemAtIndex:_sut.numberOfItems - 1]);
}

- (void)testLayoutAttributesNilOutOfBounds
{
	_sut.numberOfItems = 10;
	XCTAssertNil([_sut layoutAttributesForItemAtIndex:_sut.numberOfItems + 1]);
}

- (void)testAsksDelegateForAspectRatio
{
	_sut.numberOfItems = 10;
	MMTestCoverFlowLayoutDelegate *delegate = [[MMTestCoverFlowLayoutDelegate alloc] init];
	delegate.aspectRatio = 1;
	_sut.delegate = delegate;
	MMCoverFlowLayoutAttributes *attributes = [_sut layoutAttributesForItemAtIndex:0];
	XCTAssertNotNil(attributes);
}

- (void)testItemSizeHonoursAspectRatioWhenHeightGreaterThanWidth
{
	_sut.numberOfItems = 10;
	MMTestCoverFlowLayoutDelegate *delegate = [[MMTestCoverFlowLayoutDelegate alloc] init];
	CGFloat testAspectRatio = 200.f / 100.f; // width < height
	delegate.aspectRatio = testAspectRatio;
	_sut.delegate = delegate;

	_sut.selectedItemIndex = _sut.numberOfItems / 2;
	CGSize expectedItemSize = CGSizeMake(_sut.visibleSize.height - _sut.verticalMargin * 2, _sut.visibleSize.height - _sut.verticalMargin * 2);
	CGAffineTransform aspectTransform = CGAffineTransformMakeScale(1, 1 / testAspectRatio);
	expectedItemSize = CGSizeApplyAffineTransform(expectedItemSize, aspectTransform);

	MMCoverFlowLayoutAttributes *attributes = [_sut layoutAttributesForItemAtIndex:0];
	XCTAssertTrue(CGSizeEqualToSize(attributes.bounds.size, expectedItemSize));
}

- (void)testItemSizeHonoursAspectRatioWhenWidthGreaterThanHeight
{
	_sut.numberOfItems = 10;
	MMTestCoverFlowLayoutDelegate *delegate = [[MMTestCoverFlowLayoutDelegate alloc] init];
	CGFloat testAspectRatio = 100.f / 200.f; // width > height
	delegate.aspectRatio = testAspectRatio;
	_sut.delegate = delegate;

	_sut.selectedItemIndex = _sut.numberOfItems / 2;
	CGSize expectedItemSize = CGSizeMake(_sut.visibleSize.height - _sut.verticalMargin * 2, _sut.visibleSize.height - _sut.verticalMargin * 2);
	CGAffineTransform aspectTransform = CGAffineTransformMakeScale(testAspectRatio, 1);
	expectedItemSize = CGSizeApplyAffineTransform(expectedItemSize, aspectTransform);

	MMCoverFlowLayoutAttributes *attributes = [_sut layoutAttributesForItemAtIndex:0];
	XCTAssertTrue(CGSizeEqualToSize(attributes.bounds.size, expectedItemSize));
}

- (void)testItemSizeUsesLayoutItemSizeForSquareAspectRatio
{
	_sut.numberOfItems = 10;
	MMTestCoverFlowLayoutDelegate *delegate = [[MMTestCoverFlowLayoutDelegate alloc] init];
	delegate.aspectRatio = 1;
	_sut.delegate = delegate;

	MMCoverFlowLayoutAttributes *attributes = [_sut layoutAttributesForItemAtIndex:0];
	XCTAssertTrue(CGSizeEqualToSize(attributes.bounds.size, _sut.itemSize));
}

- (void)testDoesNotAskDelegateForAspectRatioWhenDelegateDoesNotRespond
{
	_sut.numberOfItems = 10;
	_sut.delegate = (id<MMCoverFlowLayoutDelegate>)[NSObject new];
	MMCoverFlowLayoutAttributes *attributes = [_sut layoutAttributesForItemAtIndex:0];
	XCTAssertTrue(CGSizeEqualToSize(attributes.bounds.size, _sut.itemSize));
}

- (void)testContentWidthForFirstItemSelected
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = 0;
	CGFloat stackedWidth = cos(DEGREES2RADIANS(_sut.stackedAngle)) * _sut.itemSize.width + _sut.interItemSpacing;
	CGFloat expectedContentWidth = _sut.itemSize.width + stackedWidth * (CGFloat)(_sut.numberOfItems - 1) + _sut.itemSize.width;
	XCTAssertEqual(_sut.contentSize.width, expectedContentWidth);
}

- (void)testContentWidthForLastItemSelected
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = _sut.numberOfItems - 1;
	CGFloat stackedWidth = cos(DEGREES2RADIANS(_sut.stackedAngle)) * _sut.itemSize.width + _sut.interItemSpacing;
	CGFloat expectedContentWidth = _sut.itemSize.width + stackedWidth * (CGFloat)(_sut.numberOfItems - 1) + _sut.itemSize.width;
	XCTAssertEqual(_sut.contentSize.width, expectedContentWidth);
}

- (void)testContentWidthForSelectionInStack
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = _sut.numberOfItems / 2;
	CGFloat stackedWidth = cos(DEGREES2RADIANS(_sut.stackedAngle)) * _sut.itemSize.width + _sut.interItemSpacing;
	CGFloat expectedContentWidth = _sut.itemSize.width + stackedWidth * (CGFloat)(_sut.numberOfItems - 1) + _sut.itemSize.width * 2;
	XCTAssertEqual(_sut.contentSize.width, expectedContentWidth);
}

#pragma mark - attribute geometry

- (MMCoverFlowLayoutAttributes *)expectedAttributesForIndex:(NSUInteger)index
												   position:(CGPoint)position
													   size:(CGSize)size
												  transform:(CATransform3D)transform
												  zPosition:(CGFloat)zPosition
{
	return [[MMCoverFlowLayoutAttributes alloc] initWithIndex:index
													 position:position
														 size:size
												  anchorPoint:CGPointMake(0.5, 0)
													transfrom:transform
													zPosition:zPosition];
}

- (void)testSelectedItemIsCenteredInVisibleArea
{
	_sut.numberOfItems = 10;
	CGFloat itemHeight = _sut.visibleSize.height - _sut.verticalMargin * 2;
	CGSize expectedItemSize = CGSizeMake(itemHeight, itemHeight);
	CGFloat expectedVerticalPosition = _sut.visibleSize.height / 2 - _sut.itemSize.height / 2;

	_sut.selectedItemIndex = _sut.numberOfItems / 2;
	CGRect visibleRect = CGRectMake(0, 0, _sut.visibleSize.width, _sut.visibleSize.height);
	CGFloat selectedItemLeftEdge = CGRectGetMidX(visibleRect) - _sut.itemSize.width / 2;

	MMCoverFlowLayoutAttributes *expectedAttributes = [self expectedAttributesForIndex:_sut.selectedItemIndex
																			 position:CGPointMake(selectedItemLeftEdge, expectedVerticalPosition)
																				 size:expectedItemSize
																			transform:CATransform3DIdentity
																			zPosition:0];
	XCTAssertEqualObjects([_sut layoutAttributesForItemAtIndex:_sut.selectedItemIndex], expectedAttributes);
}

- (void)testSelectedFirstItemIsCenteredInVisibleArea
{
	_sut.numberOfItems = 10;
	CGFloat itemHeight = _sut.visibleSize.height - _sut.verticalMargin * 2;
	CGSize expectedItemSize = CGSizeMake(itemHeight, itemHeight);
	CGFloat expectedVerticalPosition = _sut.visibleSize.height / 2 - _sut.itemSize.height / 2;

	_sut.selectedItemIndex = 0;
	CGRect visibleRect = CGRectMake(0, 0, _sut.visibleSize.width, _sut.visibleSize.height);
	CGFloat selectedItemLeftEdge = CGRectGetMidX(visibleRect) - _sut.itemSize.width / 2;

	MMCoverFlowLayoutAttributes *expectedAttributes = [self expectedAttributesForIndex:_sut.selectedItemIndex
																			 position:CGPointMake(selectedItemLeftEdge, expectedVerticalPosition)
																				 size:expectedItemSize
																			transform:CATransform3DIdentity
																			zPosition:0];
	XCTAssertEqualObjects([_sut layoutAttributesForItemAtIndex:_sut.selectedItemIndex], expectedAttributes);
}

- (void)testSelectedLastItemIsCenteredInVisibleArea
{
	_sut.numberOfItems = 10;
	CGFloat itemHeight = _sut.visibleSize.height - _sut.verticalMargin * 2;
	CGSize expectedItemSize = CGSizeMake(itemHeight, itemHeight);
	CGFloat expectedVerticalPosition = _sut.visibleSize.height / 2 - _sut.itemSize.height / 2;

	_sut.selectedItemIndex = _sut.numberOfItems - 1;
	CGRect visibleRect = CGRectMake(0, 0, _sut.visibleSize.width, _sut.visibleSize.height);
	CGFloat selectedItemLeftEdge = CGRectGetMidX(visibleRect) - _sut.itemSize.width / 2;

	MMCoverFlowLayoutAttributes *expectedAttributes = [self expectedAttributesForIndex:_sut.selectedItemIndex
																			 position:CGPointMake(selectedItemLeftEdge, expectedVerticalPosition)
																				 size:expectedItemSize
																			transform:CATransform3DIdentity
																			zPosition:0];
	XCTAssertEqualObjects([_sut layoutAttributesForItemAtIndex:_sut.selectedItemIndex], expectedAttributes);
}

- (void)testLeftStackFirstItemAttributes
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = _sut.numberOfItems / 2;

	CGFloat itemHeight = _sut.visibleSize.height - _sut.verticalMargin * 2;
	CGSize expectedItemSize = CGSizeMake(itemHeight, itemHeight);
	CGFloat expectedVerticalPosition = _sut.visibleSize.height / 2 - _sut.itemSize.height / 2;
	CGFloat expectedStackedItemWidth = cos(DEGREES2RADIANS(_sut.stackedAngle)) * _sut.itemSize.width + _sut.interItemSpacing;
	CATransform3D leftTransform = CATransform3DConcat(CATransform3DMakeRotation(DEGREES2RADIANS(_sut.stackedAngle), 0, 1, 0), CATransform3DMakeTranslation(0, 0, -_sut.stackedDistance));

	CGRect visibleRect = CGRectMake(0, 0, _sut.visibleSize.width, _sut.visibleSize.height);
	CGFloat selectedItemLeftEdge = CGRectGetMidX(visibleRect) - _sut.itemSize.width / 2;
	NSUInteger testedItemIndex = 0;
	CGFloat expectedHorizontalPosition = selectedItemLeftEdge - expectedStackedItemWidth * (CGFloat)(_sut.selectedItemIndex - testedItemIndex) - _sut.itemSize.width;

	MMCoverFlowLayoutAttributes *expectedAttributes = [self expectedAttributesForIndex:testedItemIndex
																			 position:CGPointMake(expectedHorizontalPosition, expectedVerticalPosition)
																				 size:expectedItemSize
																			transform:leftTransform
																			zPosition:0];
	XCTAssertEqualObjects([_sut layoutAttributesForItemAtIndex:testedItemIndex], expectedAttributes);
}

- (void)testLeftStackDistanceToNeighbor
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = _sut.numberOfItems / 2;

	CGFloat expectedStackedItemWidth = cos(DEGREES2RADIANS(_sut.stackedAngle)) * _sut.itemSize.width + _sut.interItemSpacing;
	NSUInteger testedItemIndex = 0;
	MMCoverFlowLayoutAttributes *attributes = [_sut layoutAttributesForItemAtIndex:testedItemIndex];
	MMCoverFlowLayoutAttributes *nextItemAttributes = [_sut layoutAttributesForItemAtIndex:testedItemIndex + 1];
	CGFloat distance = nextItemAttributes.position.x - attributes.position.x;
	XCTAssertEqualWithAccuracy(distance, expectedStackedItemWidth, 0.000001);
}

- (void)testLeftStackItemBeforeSelectedItemAttributes
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = _sut.numberOfItems / 2;

	CGFloat itemHeight = _sut.visibleSize.height - _sut.verticalMargin * 2;
	CGSize expectedItemSize = CGSizeMake(itemHeight, itemHeight);
	CGFloat expectedVerticalPosition = _sut.visibleSize.height / 2 - _sut.itemSize.height / 2;
	CGFloat expectedStackedItemWidth = cos(DEGREES2RADIANS(_sut.stackedAngle)) * _sut.itemSize.width + _sut.interItemSpacing;
	CATransform3D leftTransform = CATransform3DConcat(CATransform3DMakeRotation(DEGREES2RADIANS(_sut.stackedAngle), 0, 1, 0), CATransform3DMakeTranslation(0, 0, -_sut.stackedDistance));

	CGRect visibleRect = CGRectMake(0, 0, _sut.visibleSize.width, _sut.visibleSize.height);
	CGFloat selectedItemLeftEdge = CGRectGetMidX(visibleRect) - _sut.itemSize.width / 2;
	NSUInteger testedItemIndex = _sut.selectedItemIndex - 1;
	CGFloat expectedHorizontalPosition = selectedItemLeftEdge - expectedStackedItemWidth * (CGFloat)(_sut.selectedItemIndex - testedItemIndex) - _sut.itemSize.width;

	MMCoverFlowLayoutAttributes *expectedAttributes = [self expectedAttributesForIndex:testedItemIndex
																			 position:CGPointMake(expectedHorizontalPosition, expectedVerticalPosition)
																				 size:expectedItemSize
																			transform:leftTransform
																			zPosition:0];
	XCTAssertEqualObjects([_sut layoutAttributesForItemAtIndex:testedItemIndex], expectedAttributes);
}

- (void)testRightStackItemAfterSelectedItemAttributes
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = _sut.numberOfItems / 2;

	CGFloat itemHeight = _sut.visibleSize.height - _sut.verticalMargin * 2;
	CGSize expectedItemSize = CGSizeMake(itemHeight, itemHeight);
	CGFloat expectedVerticalPosition = _sut.visibleSize.height / 2 - _sut.itemSize.height / 2;
	CGFloat expectedStackedItemWidth = cos(DEGREES2RADIANS(_sut.stackedAngle)) * _sut.itemSize.width + _sut.interItemSpacing;
	CATransform3D rightTransform = CATransform3DConcat(CATransform3DMakeRotation(-DEGREES2RADIANS(_sut.stackedAngle), 0, 1, 0), CATransform3DMakeTranslation(0, 0, -_sut.stackedDistance));

	CGRect visibleRect = CGRectMake(0, 0, _sut.visibleSize.width, _sut.visibleSize.height);
	CGFloat selectedItemRightEdge = CGRectGetMidX(visibleRect) + _sut.itemSize.width / 2;
	NSUInteger testedItemIndex = _sut.selectedItemIndex + 1;
	CGFloat expectedHorizontalPosition = selectedItemRightEdge + expectedStackedItemWidth * (CGFloat)(testedItemIndex - _sut.selectedItemIndex);

	MMCoverFlowLayoutAttributes *expectedAttributes = [self expectedAttributesForIndex:testedItemIndex
																			 position:CGPointMake(expectedHorizontalPosition, expectedVerticalPosition)
																				 size:expectedItemSize
																			transform:rightTransform
																			zPosition:0];
	XCTAssertEqualObjects([_sut layoutAttributesForItemAtIndex:testedItemIndex], expectedAttributes);
}

- (void)testRightStackLastItemAttributes
{
	_sut.numberOfItems = 10;
	_sut.selectedItemIndex = _sut.numberOfItems / 2;

	CGFloat itemHeight = _sut.visibleSize.height - _sut.verticalMargin * 2;
	CGSize expectedItemSize = CGSizeMake(itemHeight, itemHeight);
	CGFloat expectedVerticalPosition = _sut.visibleSize.height / 2 - _sut.itemSize.height / 2;
	CGFloat expectedStackedItemWidth = cos(DEGREES2RADIANS(_sut.stackedAngle)) * _sut.itemSize.width + _sut.interItemSpacing;
	CATransform3D rightTransform = CATransform3DConcat(CATransform3DMakeRotation(-DEGREES2RADIANS(_sut.stackedAngle), 0, 1, 0), CATransform3DMakeTranslation(0, 0, -_sut.stackedDistance));

	CGRect visibleRect = CGRectMake(0, 0, _sut.visibleSize.width, _sut.visibleSize.height);
	CGFloat selectedItemRightEdge = CGRectGetMidX(visibleRect) + _sut.itemSize.width / 2;
	NSUInteger testedItemIndex = _sut.numberOfItems - 1;
	CGFloat expectedHorizontalPosition = selectedItemRightEdge + expectedStackedItemWidth * (CGFloat)(testedItemIndex - _sut.selectedItemIndex);

	MMCoverFlowLayoutAttributes *expectedAttributes = [self expectedAttributesForIndex:testedItemIndex
																			 position:CGPointMake(expectedHorizontalPosition, expectedVerticalPosition)
																				 size:expectedItemSize
																			transform:rightTransform
																			zPosition:0];
	XCTAssertEqualObjects([_sut layoutAttributesForItemAtIndex:testedItemIndex], expectedAttributes);
}

#pragma mark - NSCoding

- (void)testNonKeyedArchiverRaises
{
	_sut.numberOfItems = 10;
	XCTAssertThrowsSpecificNamed([NSArchiver archivedDataWithRootObject:_sut], NSException, NSInvalidArchiveOperationException);
}

- (void)testKeyedArchiveRoundTrip
{
	_sut.numberOfItems = 10;
	NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:_sut];
	MMCoverFlowLayout *unarchivedLayout = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];

	XCTAssertNotNil(archivedData);
	XCTAssertNotNil(unarchivedLayout);
	XCTAssertTrue([unarchivedLayout isKindOfClass:[_sut class]]);
	XCTAssertTrue(CGSizeEqualToSize(unarchivedLayout.visibleSize, _sut.visibleSize));
	XCTAssertEqual(unarchivedLayout.interItemSpacing, _sut.interItemSpacing);
	XCTAssertEqual(unarchivedLayout.stackedAngle, _sut.stackedAngle);
	XCTAssertEqual(unarchivedLayout.selectedItemIndex, _sut.selectedItemIndex);
	XCTAssertEqual(unarchivedLayout.numberOfItems, _sut.numberOfItems);
	XCTAssertEqual(unarchivedLayout.stackedDistance, _sut.stackedDistance);
	XCTAssertEqual(unarchivedLayout.verticalMargin, _sut.verticalMargin);
}

@end
