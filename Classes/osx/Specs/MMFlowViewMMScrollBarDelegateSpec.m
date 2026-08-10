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
//  MMFlowViewMMScrollBarDelegateSpec.m
//
//  Created by Markus Müller on 04.03.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+MMScrollBarDelegate.h"
#import "MMScrollBarLayer.h"
#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayer.h"

@interface MMFlowViewMMScrollBarDelegateSpec : XCTestCase

@end

@implementation MMFlowViewMMScrollBarDelegateSpec
{
	MMFlowView *_sut;
}

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
}

- (void)tearDown
{
	_sut = nil;
	[super tearDown];
}

- (void)testConformsToScrollBarDelegateProtocol
{
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMScrollBarDelegate)]);
}

- (void)testRespondsToDelegateSelectors
{
	XCTAssertTrue([_sut respondsToSelector:@selector(scrollBarLayer:knobDraggedToPosition:)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(decrementClickedInScrollBarLayer:)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(incrementClickedInScrollBarLayer:)]);
}

- (void)testIsTheScrollBarDelegate
{
	XCTAssertEqualObjects(_sut, _sut.scrollBarLayer.scrollBarDelegate);
}

- (void)testKnobDraggedToLeftmostPositionSelectsFirstItem
{
	_sut.coverFlowLayout.numberOfItems = 11;
	[_sut scrollBarLayer:_sut.scrollBarLayer knobDraggedToPosition:0];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)0);
}

- (void)testKnobDraggedToRightmostPositionSelectsLastItem
{
	_sut.coverFlowLayout.numberOfItems = 11;
	[_sut scrollBarLayer:_sut.scrollBarLayer knobDraggedToPosition:1];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)10);
}

- (void)testKnobDraggedToMidPositionSelectsMiddleItem
{
	_sut.coverFlowLayout.numberOfItems = 11;
	[_sut scrollBarLayer:_sut.scrollBarLayer knobDraggedToPosition:.5];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)5);
}

- (void)testKnobDraggedOnForeignScrollBarDoesNotChangeSelection
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 3;
	MMScrollBarLayer *foreignScrollBar = [[MMScrollBarLayer alloc] init];
	[_sut scrollBarLayer:foreignScrollBar knobDraggedToPosition:.3];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)3);
}

- (void)testDecrementMovesSelectionOneItemLeft
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 5;
	[_sut decrementClickedInScrollBarLayer:_sut.scrollBarLayer];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)4);
}

- (void)testDecrementOnForeignScrollBarDoesNotChangeSelection
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 5;
	MMScrollBarLayer *foreignScrollBar = [[MMScrollBarLayer alloc] init];
	[_sut decrementClickedInScrollBarLayer:foreignScrollBar];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)5);
}

- (void)testIncrementMovesSelectionOneItemRight
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 5;
	[_sut incrementClickedInScrollBarLayer:_sut.scrollBarLayer];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)6);
}

- (void)testIncrementOnForeignScrollBarDoesNotChangeSelection
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 5;
	MMScrollBarLayer *foreignScrollBar = [[MMScrollBarLayer alloc] init];
	[_sut incrementClickedInScrollBarLayer:foreignScrollBar];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)5);
}

- (void)testRespondsToContentSizeForScrollBarLayer
{
	XCTAssertTrue([_sut respondsToSelector:@selector(contentSizeForScrollBarLayer:)]);
}

- (void)testContentSizeMatchesLayoutContentSize
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 5;
	CGFloat expectedSize = _sut.coverFlowLayout.contentSize.width;
	XCTAssertEqual([_sut contentSizeForScrollBarLayer:_sut.scrollBarLayer], expectedSize);
}

- (void)testRespondsToVisibleSizeForScrollBarLayer
{
	XCTAssertTrue([_sut respondsToSelector:@selector(visibleSizeForScrollBarLayer:)]);
}

- (void)testRespondsToCurrentKnobPositionInScrollBarLayer
{
	XCTAssertTrue([_sut respondsToSelector:@selector(currentKnobPositionInScrollBarLayer:)]);
}

- (void)testKnobPositionZeroForFirstSelectedIndex
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 0;
	XCTAssertEqual([_sut currentKnobPositionInScrollBarLayer:_sut.scrollBarLayer], (CGFloat)0);
}

- (void)testKnobPositionOneForLastSelectedIndex
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 10;
	XCTAssertEqual([_sut currentKnobPositionInScrollBarLayer:_sut.scrollBarLayer], (CGFloat)1);
}

- (void)testKnobPositionHalfForMidSelectedIndex
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 5;
	XCTAssertEqual([_sut currentKnobPositionInScrollBarLayer:_sut.scrollBarLayer], (CGFloat).5);
}

- (void)testKnobPositionZeroForInvalidSelection
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = NSNotFound;
	XCTAssertEqual([_sut currentKnobPositionInScrollBarLayer:_sut.scrollBarLayer], (CGFloat)0);
}

- (void)testKnobPositionZeroWithoutItems
{
	XCTAssertEqual([_sut currentKnobPositionInScrollBarLayer:_sut.scrollBarLayer], (CGFloat)0);
}

- (void)testKnobPositionZeroForSingleItem
{
	_sut.coverFlowLayout.numberOfItems = 1;
	_sut.coverFlowLayout.selectedItemIndex = 0;
	XCTAssertEqual([_sut currentKnobPositionInScrollBarLayer:_sut.scrollBarLayer], (CGFloat)0);
}

// DISABLED: visibleSizeForScrollBarLayer: depends on the live geometry of the
// cover flow layer (visibleRect), which is not meaningful for layers outside a
// displayed window hierarchy.

@end
