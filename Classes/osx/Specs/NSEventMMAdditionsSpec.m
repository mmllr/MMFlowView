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
//  NSEventMMAdditionsSpec.m
//
//  Created by Markus Müller on 23.01.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSEvent+MMAdditions.h"

@interface NSEventMMAdditionsSpec : XCTestCase

@end

@implementation NSEventMMAdditionsSpec

// Creates a real scroll wheel event with the given line-based deltas.
// CGEventCreateScrollWheelEvent: wheel1 == deltaY (axis 1), wheel2 == deltaX (axis 2).
- (NSEvent *)scrollEventWithDeltaX:(CGFloat)deltaX deltaY:(CGFloat)deltaY
{
	CGEventRef cgEvent = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitLine, 2, (int32_t)deltaY, (int32_t)deltaX);
	NSEvent *event = [NSEvent eventWithCGEvent:cgEvent];
	CFRelease(cgEvent);
	return event;
}

- (void)testDominantDeltaWhenAbsoluteDeltaXGreaterThanDeltaY
{
	NSEvent *sut = [self scrollEventWithDeltaX:10 deltaY:-5];
	XCTAssertEqualWithAccuracy(sut.dominantDeltaInXYSpace, 10, 0.0000001);
}

- (void)testDominantDeltaWhenAbsoluteDeltaXEqualToDeltaY
{
	NSEvent *sut = [self scrollEventWithDeltaX:-5 deltaY:-5];
	XCTAssertEqualWithAccuracy(sut.dominantDeltaInXYSpace, -5, 0.0000001);
}

- (void)testDominantDeltaWhenAbsoluteDeltaXLessThanDeltaY
{
	NSEvent *sut = [self scrollEventWithDeltaX:-5 deltaY:-6];
	XCTAssertEqualWithAccuracy(sut.dominantDeltaInXYSpace, -6, 0.0000001);
}

@end
