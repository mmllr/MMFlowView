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
//  NSAffineTransformMMAdditionsSpec.m
//
//  Created by Markus Müller on 26.02.14.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSAffineTransform+MMAdditions.h"

#ifndef DEGREES2RADIANS
#define DEGREES2RADIANS(angle) ((angle) * M_PI / 180.)
#endif

@interface NSAffineTransformMMAdditionsSpec : XCTestCase

@end

@implementation NSAffineTransformMMAdditionsSpec

- (void)testAffineTransformWithCGAffineTransformExists
{
	CGAffineTransform testCGTransform = CGAffineTransformMake(10, 20, 30, 40, 10, 10);
	NSAffineTransform *sut = [NSAffineTransform affineTransformWithCGAffineTransform:testCGTransform];
	XCTAssertNotNil(sut);
}

- (void)testAffineTransformWithCGAffineTransformIsKindOfClass
{
	CGAffineTransform testCGTransform = CGAffineTransformMake(10, 20, 30, 40, 10, 10);
	NSAffineTransform *sut = [NSAffineTransform affineTransformWithCGAffineTransform:testCGTransform];
	XCTAssertTrue([sut isKindOfClass:[NSAffineTransform class]]);
}

- (void)testAffineTransformWithCGAffineTransformMatchesTheTransform
{
	CGAffineTransform testCGTransform = CGAffineTransformMake(10, 20, 30, 40, 10, 10);
	NSAffineTransform *sut = [NSAffineTransform affineTransformWithCGAffineTransform:testCGTransform];
	NSAffineTransformStruct transform = [sut transformStruct];

	XCTAssertEqual(transform.m11, testCGTransform.a);
	XCTAssertEqual(transform.m12, testCGTransform.b);
	XCTAssertEqual(transform.m21, testCGTransform.c);
	XCTAssertEqual(transform.m22, testCGTransform.d);
	XCTAssertEqual(transform.tX, testCGTransform.tx);
	XCTAssertEqual(transform.tY, testCGTransform.ty);
}

- (void)testTransformPointMatchesRotation
{
	CGPoint testPoint = {10, 10};
	CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(DEGREES2RADIANS(30));

	NSAffineTransform *sut = [NSAffineTransform affineTransformWithCGAffineTransform:rotationTransform];
	NSValue *expectedPoint = [NSValue valueWithPoint:CGPointApplyAffineTransform(testPoint, rotationTransform)];
	XCTAssertEqualObjects([NSValue valueWithPoint:[sut transformPoint:testPoint]], expectedPoint);
}

- (void)testTransformPointMatchesTranslation
{
	CGPoint testPoint = {10, 10};
	CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(50, 50);

	NSAffineTransform *sut = [NSAffineTransform affineTransformWithCGAffineTransform:translationTransform];
	NSValue *expectedPoint = [NSValue valueWithPoint:CGPointApplyAffineTransform(testPoint, translationTransform)];
	XCTAssertEqualObjects([NSValue valueWithPoint:[sut transformPoint:testPoint]], expectedPoint);
}

- (void)testTransformSizeMatchesScale
{
	CGSize testSize = {150, 150};
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(20, 20);

	NSAffineTransform *sut = [NSAffineTransform affineTransformWithCGAffineTransform:scaleTransform];
	NSValue *expectedSize = [NSValue valueWithSize:CGSizeApplyAffineTransform(testSize, scaleTransform)];
	XCTAssertEqualObjects([NSValue valueWithSize:[sut transformSize:testSize]], expectedSize);
}

- (void)testRespondsToMMCGAffineTransform
{
	NSAffineTransform *sut = [NSAffineTransform transform];
	XCTAssertTrue([sut respondsToSelector:@selector(mm_CGAffineTransform)]);
}

- (void)testMMCGAffineTransformMatchesRotation
{
	NSAffineTransform *sut = [NSAffineTransform transform];
	CGAffineTransform expectedTransform = CGAffineTransformMakeRotation(DEGREES2RADIANS(30));
	[sut rotateByDegrees:30];
	XCTAssertTrue(CGAffineTransformEqualToTransform(sut.mm_CGAffineTransform, expectedTransform));
}

- (void)testMMCGAffineTransformMatchesTranslation
{
	NSAffineTransform *sut = [NSAffineTransform transform];
	CGAffineTransform expectedTransform = CGAffineTransformMakeTranslation(40, 40);
	[sut translateXBy:40 yBy:40];
	XCTAssertTrue(CGAffineTransformEqualToTransform(sut.mm_CGAffineTransform, expectedTransform));
}

- (void)testMMCGAffineTransformMatchesScale
{
	NSAffineTransform *sut = [NSAffineTransform transform];
	CGAffineTransform expectedTransform = CGAffineTransformMakeScale(50, 50);
	[sut scaleXBy:50 yBy:50];
	XCTAssertTrue(CGAffineTransformEqualToTransform(sut.mm_CGAffineTransform, expectedTransform));
}

@end
