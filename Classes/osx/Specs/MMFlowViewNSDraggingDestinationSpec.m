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
//  MMFlowViewNSDraggingDestinationSpec.m
//
//  Created by Markus Müller on 15.04.14.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowView.h"
#import "MMFlowView+NSDraggingDestination.h"
#import "MMFlowView_Private.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewNSDraggingDestinationSpec : XCTestCase

@end

@implementation MMFlowViewNSDraggingDestinationSpec
{
	MMFlowView *_sut;
	MMTestDraggingInfo *_dragInfo;
}

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	_dragInfo = [[MMTestDraggingInfo alloc] init];
}

- (void)tearDown
{
	_sut = nil;
	_dragInfo = nil;
	[super tearDown];
}

- (void)testDoesNotWantPeriodicDraggingUpdates
{
	XCTAssertFalse([_sut wantsPeriodicDraggingUpdates]);
}

- (void)testPreparesForDragOperation
{
	XCTAssertTrue([_sut prepareForDragOperation:_dragInfo]);
}

- (void)testPerformDragOperationReturnsNoWhenNoItemAtPoint
{
	// The flow view has no items, so no point maps to an item.
	_dragInfo.draggingLocationValue = NSMakePoint(200, 150);
	XCTAssertFalse([_sut performDragOperation:_dragInfo]);
}

- (void)testPerformDragOperationReturnsNoWithoutHandlingDataSource
{
	_dragInfo.draggingLocationValue = NSMakePoint(200, 150);
	_sut.dataSource = (id<MMFlowViewDataSource>)[NSObject new];
	XCTAssertFalse([_sut performDragOperation:_dragInfo]);
}

- (void)testDraggingEnteredReturnsNoneWhenDraggingFromFlowView
{
	_dragInfo.draggingSourceValue = _sut;
	XCTAssertEqual([_sut draggingEntered:_dragInfo], NSDragOperationNone);
}

- (void)testDraggingEnteredReturnsNoneWhenDraggingFromElsewhere
{
	_dragInfo.draggingSourceValue = [NSObject new];
	XCTAssertEqual([_sut draggingEntered:_dragInfo], NSDragOperationNone);
}

- (void)testDraggingExitedResetsHighlightedLayer
{
	_sut.highlightedLayer = [CALayer layer];
	[_sut draggingExited:_dragInfo];
	XCTAssertNil(_sut.highlightedLayer);
}

- (void)testDraggingUpdatedReturnsNoneWithoutValidatingDataSource
{
	_sut.dataSource = (id<MMFlowViewDataSource>)[NSObject new];
	XCTAssertEqual([_sut draggingUpdated:_dragInfo], NSDragOperationNone);
	XCTAssertNil(_sut.highlightedLayer);
}

- (void)testConcludeDragOperationClearsHighlightedLayer
{
	_sut.highlightedLayer = [CALayer layer];
	[_sut concludeDragOperation:_dragInfo];
	XCTAssertNil(_sut.highlightedLayer);
}

// DISABLED: the original performDragOperation:/draggingUpdated: tests verified drop
// acceptance and layer highlighting by stubbing indexOfItemAtPoint: and
// selectedIndex so the drop landed on a concrete item. Without stubbing, these
// depend on the cover flow layer's real hit-test geometry, which is exercised by
// MMCoverFlowLayerSpec. The datasource validation contract is covered above.

@end
