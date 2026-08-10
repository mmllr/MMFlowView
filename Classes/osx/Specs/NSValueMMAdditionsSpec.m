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
//  NSValueMMAdditionsSpec.m
//
//  Created by Markus Müller on 21.01.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSValue+MMAdditions.h"

@interface NSValueMMAdditionsSpec : XCTestCase

@end

@implementation NSValueMMAdditionsSpec

- (void)testValueWithCGAffineTransformRespondsToClassMethod
{
	XCTAssertTrue([[NSValue class] respondsToSelector:@selector(valueWithCGAffineTransform:)]);
}

- (void)testValueWithCGAffineTransformCreatesValueFromTransform
{
	XCTAssertNotNil([NSValue valueWithCGAffineTransform:CGAffineTransformIdentity]);
}

- (void)testRespondsToCGAffineTransformValue
{
	NSValue *sut = [NSValue valueWithCGAffineTransform:CGAffineTransformIdentity];
	XCTAssertTrue([sut respondsToSelector:@selector(CGAffineTransformValue)]);
}

- (void)testCGAffineTransformValueReturnsIdentityMatrix
{
	NSValue *sut = [NSValue valueWithCGAffineTransform:CGAffineTransformIdentity];
	XCTAssertTrue(CGAffineTransformEqualToTransform([sut CGAffineTransformValue], CGAffineTransformIdentity));
}

- (void)testCGAffineTransformValueReturnsInitializedTransform
{
	NSValue *sut = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(M_2_PI)];
	XCTAssertTrue(CGAffineTransformEqualToTransform([sut CGAffineTransformValue], CGAffineTransformMakeRotation(M_2_PI)));
}

- (void)testCGAffineTransformValueReturnsIdentityWhenNotCreatedWithTransform
{
	NSValue *sut = @10;
	CGAffineTransform transform = [sut CGAffineTransformValue];
	XCTAssertTrue(CGAffineTransformEqualToTransform(transform, CGAffineTransformIdentity));
}

- (void)testEqualityTreatsIdenticalTransformsAsEqual
{
	NSValue *a = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeScale(30, 70)];
	NSValue *b = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeScale(30, 70)];
	XCTAssertEqualObjects(a, b);
}

- (void)testEqualityTreatsDifferentTransformsAsNotEqual
{
	NSValue *a = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeScale(30, 70)];
	NSValue *b = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(M_1_PI)];
	XCTAssertNotEqualObjects(a, b);
}

@end
