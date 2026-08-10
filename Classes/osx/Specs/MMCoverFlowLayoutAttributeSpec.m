/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://codeberg.org/mmllr All rights reserved.
 
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
//  MMCoverFlowLayoutAttributesSpec.m
//
//  Created by Markus Müller on 26.11.13.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <QuartzCore/QuartzCore.h>

#import "MMCoverFlowLayoutAttributes.h"

@interface TestingMMCoverFlowLayoutAttributesSubclass : MMCoverFlowLayoutAttributes
@end

@implementation TestingMMCoverFlowLayoutAttributesSubclass
@end

@interface MMCoverFlowLayoutAttributesSpec : XCTestCase

@end

@implementation MMCoverFlowLayoutAttributesSpec
{
	MMCoverFlowLayoutAttributes *_sut;
}

static const NSUInteger indexFixture = 10;
static const CGPoint positionFixture = {10, 10};
static const CGSize sizeFixture = {50, 50};
static const CGPoint anchorPointFixture = {.5, .5};
static const CATransform3D transformFixture = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
static const CGFloat zPositionFixture = 100;

- (void)setUp
{
	[super setUp];
	_sut = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:indexFixture
													 position:positionFixture
														 size:sizeFixture
												  anchorPoint:anchorPointFixture
													transfrom:transformFixture
													zPosition:zPositionFixture];
}

- (void)tearDown
{
	_sut = nil;
	[super tearDown];
}

- (void)testThrowsWhenCreatedWithDefaultInit
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMCoverFlowLayoutAttributes alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testInstanceExists
{
	XCTAssertNotNil(_sut);
}

- (void)testHasIndexFromInitializer
{
	XCTAssertEqual(_sut.index, (NSUInteger)indexFixture);
}

- (void)testHasIdentityTransformMatrix
{
	XCTAssertEqualObjects([NSValue valueWithCATransform3D:_sut.transform], [NSValue valueWithCATransform3D:transformFixture]);
}

- (void)testHasPositionFromInitializer
{
	XCTAssertEqualObjects([NSValue valueWithPoint:_sut.position], [NSValue valueWithPoint:positionFixture]);
}

- (void)testHasBoundsFromInitializerSize
{
	XCTAssertTrue(CGRectEqualToRect(_sut.bounds, CGRectMake(0, 0, sizeFixture.width, sizeFixture.height)));
}

- (void)testHasAnchorPointFromInitializer
{
	XCTAssertEqualObjects([NSValue valueWithPoint:NSPointFromCGPoint(_sut.anchorPoint)], [NSValue valueWithPoint:NSPointFromCGPoint(anchorPointFixture)]);
}

- (void)testHasZPositionFromInitializer
{
	XCTAssertEqual(_sut.zPosition, zPositionFixture);
}

- (MMCoverFlowLayoutAttributes *)attributeWithSameValues
{
	return [[MMCoverFlowLayoutAttributes alloc] initWithIndex:_sut.index
													 position:_sut.position
														 size:_sut.bounds.size
												  anchorPoint:_sut.anchorPoint
													transfrom:_sut.transform
													zPosition:_sut.zPosition];
}

- (void)testHashSameAsInstanceWithIdenticalValues
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	XCTAssertEqual([_sut hash], [attribute hash]);
}

- (void)testHashDiffersWithDifferingIndex
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:@(20) forKey:NSStringFromSelector(@selector(index))];
	XCTAssertNotEqual([_sut hash], [attribute hash]);
}

- (void)testHashDiffersWithDifferingTransform
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(30, 60, 90)] forKey:NSStringFromSelector(@selector(transform))];
	XCTAssertNotEqual([_sut hash], [attribute hash]);
}

- (void)testHashDiffersWithDifferingBounds
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:[NSValue valueWithRect:CGRectMake(0, 0, 400, 400)] forKey:NSStringFromSelector(@selector(bounds))];
	XCTAssertNotEqual([_sut hash], [attribute hash]);
}

- (void)testHashDiffersWithDifferingZPosition
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:@200 forKey:NSStringFromSelector(@selector(zPosition))];
	XCTAssertNotEqual([_sut hash], [attribute hash]);
}

- (void)testHashDiffersWithDifferingPosition
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:[NSValue valueWithPoint:CGPointMake(50, 50)] forKey:NSStringFromSelector(@selector(position))];
	XCTAssertNotEqual([_sut hash], [attribute hash]);
}

- (void)testHashDiffersWithDifferingAnchorPoint
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:[NSValue valueWithPoint:CGPointMake(50, 50)] forKey:NSStringFromSelector(@selector(anchorPoint))];
	XCTAssertNotEqual([_sut hash], [attribute hash]);
}

- (void)testIsEqualToItself
{
	XCTAssertTrue([_sut isEqual:_sut]);
}

- (void)testIsEqualToInstanceWithSameValues
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	XCTAssertEqualObjects(_sut, attribute);
}

- (void)testNotEqualWithDifferingIndex
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:@(20) forKey:NSStringFromSelector(@selector(index))];
	XCTAssertNotEqualObjects(_sut, attribute);
}

- (void)testNotEqualWithDifferingTransform
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(30, 60, 90)] forKey:NSStringFromSelector(@selector(transform))];
	XCTAssertNotEqualObjects(_sut, attribute);
}

- (void)testNotEqualWithDifferingBounds
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:[NSValue valueWithRect:CGRectMake(0, 0, 400, 400)] forKey:NSStringFromSelector(@selector(bounds))];
	XCTAssertNotEqualObjects(_sut, attribute);
}

- (void)testNotEqualWithDifferingZPosition
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:@200 forKey:NSStringFromSelector(@selector(zPosition))];
	XCTAssertNotEqualObjects(_sut, attribute);
}

- (void)testNotEqualWithDifferingPosition
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:[NSValue valueWithPoint:CGPointMake(50, 50)] forKey:NSStringFromSelector(@selector(position))];
	XCTAssertNotEqualObjects(_sut, attribute);
}

- (void)testNotEqualWithDifferingAnchorPoint
{
	MMCoverFlowLayoutAttributes *attribute = [self attributeWithSameValues];
	[attribute setValue:[NSValue valueWithPoint:CGPointMake(50, 50)] forKey:NSStringFromSelector(@selector(anchorPoint))];
	XCTAssertNotEqualObjects(_sut, attribute);
}

- (void)testEqualToSubclass
{
	TestingMMCoverFlowLayoutAttributesSubclass *subclass = [[TestingMMCoverFlowLayoutAttributesSubclass alloc] initWithIndex:_sut.index
																												  position:_sut.position
																													  size:_sut.bounds.size
																											   anchorPoint:_sut.anchorPoint
																												 transfrom:_sut.transform
																												 zPosition:_sut.zPosition];
	XCTAssertEqualObjects(_sut, subclass);
}

- (void)testNotEqualToKVCDictionary
{
	NSDictionary *attributesDict = [_sut dictionaryWithValuesForKeys:@[@"index", @"transform", @"bounds", @"position", @"anchorPoint", @"zPosition"]];
	XCTAssertNotEqualObjects(_sut, attributesDict);
}

- (void)testRespondsToApplyToLayer
{
	XCTAssertTrue([_sut respondsToSelector:@selector(applyToLayer:)]);
}

- (void)testApplyToLayerSetsPropertiesOnRealLayer
{
	CALayer *layer = [CALayer layer];
	[_sut applyToLayer:layer];

	XCTAssertTrue(CGPointEqualToPoint(layer.anchorPoint, _sut.anchorPoint));
	XCTAssertEqual(layer.zPosition, _sut.zPosition);
	XCTAssertTrue(CATransform3DEqualToTransform(layer.transform, _sut.transform));
	XCTAssertTrue(CGRectEqualToRect(layer.bounds, _sut.bounds));

	CGAffineTransform anchorTransform = CGAffineTransformMakeTranslation(_sut.anchorPoint.x * CGRectGetWidth(_sut.bounds), _sut.anchorPoint.y * CGRectGetHeight(_sut.bounds));
	CGPoint expectedPosition = CGPointApplyAffineTransform(_sut.position, anchorTransform);
	XCTAssertTrue(CGPointEqualToPoint(layer.position, expectedPosition));

	XCTAssertEqualObjects([layer valueForKey:kMMCoverFlowLayoutAttributesIndexAttributeKey], @(indexFixture));
}

- (void)testDescriptionMatchesExpectedString
{
	NSString *expectedDescription = [NSString stringWithFormat:@"MMCoverFlowLayoutAttributes: %p, index: %@, position: %@, anchorPoint: %@, bounds: %@, zPosition: %@, transform: %@", _sut, @(_sut.index), [NSValue valueWithPoint:_sut.position], [NSValue valueWithPoint:_sut.anchorPoint], [NSValue valueWithRect:_sut.bounds], @(_sut.zPosition), [NSValue valueWithCATransform3D:_sut.transform]];
	XCTAssertEqualObjects([_sut description], expectedDescription);
}

@end
