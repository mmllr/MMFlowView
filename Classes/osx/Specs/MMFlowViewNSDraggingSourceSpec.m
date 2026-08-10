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
//  MMFlowViewNSDraggingSourceSpec.m
//
//  Created by Markus Müller on 15.04.14.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowView+NSDraggingSource.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewNSDraggingSourceSpec : XCTestCase

@end

@implementation MMFlowViewNSDraggingSourceSpec
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

- (NSDraggingSession *)dummySession
{
	return [[NSDraggingSession alloc] init];
}

- (void)testReturnsNoneForOutsideApplicationWithoutDelegate
{
	XCTAssertEqual([_sut draggingSession:[self dummySession] sourceOperationMaskForDraggingContext:NSDraggingContextOutsideApplication], NSDragOperationNone);
}

- (void)testReturnsNoneForWithinApplicationWithoutDelegate
{
	XCTAssertEqual([_sut draggingSession:[self dummySession] sourceOperationMaskForDraggingContext:NSDraggingContextWithinApplication], NSDragOperationNone);
}

- (void)testReturnsDelegateValueForOutsideApplication
{
	MMTestFlowViewDelegate *delegate = [[MMTestFlowViewDelegate alloc] init];
	delegate.sourceOperationMask = NSDragOperationEvery;
	_sut.delegate = delegate;

	NSDragOperation result = [_sut draggingSession:[self dummySession] sourceOperationMaskForDraggingContext:NSDraggingContextOutsideApplication];
	XCTAssertEqual(result, NSDragOperationEvery);
	XCTAssertEqual(delegate.sourceOperationMask, NSDragOperationEvery);
}

- (void)testReturnsDelegateValueForWithinApplication
{
	MMTestFlowViewDelegate *delegate = [[MMTestFlowViewDelegate alloc] init];
	delegate.sourceOperationMask = NSDragOperationEvery;
	_sut.delegate = delegate;

	NSDragOperation result = [_sut draggingSession:[self dummySession] sourceOperationMaskForDraggingContext:NSDraggingContextWithinApplication];
	XCTAssertEqual(result, NSDragOperationEvery);
}

- (void)testAsksDataSourceToDeleteSelectedItemOnDeleteOperation
{
	MMTestFlowViewDataSource *dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:@[]];
	_sut.dataSource = dataSource;

	[_sut draggingSession:[self dummySession] endedAtPoint:NSZeroPoint operation:NSDragOperationDelete];

	XCTAssertGreaterThan(dataSource.removeItemAtIndexCallCount, (NSUInteger)0);
}

- (void)testDoesNotAskDataSourceToDeleteForNonDeleteOperation
{
	MMTestFlowViewDataSource *dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:@[]];
	_sut.dataSource = dataSource;

	[_sut draggingSession:[self dummySession] endedAtPoint:NSZeroPoint operation:(NSDragOperationEvery ^ NSDragOperationDelete)];

	XCTAssertEqual(dataSource.removeItemAtIndexCallCount, (NSUInteger)0);
}

- (void)testDoesNotAskNonHandlingDataSourceToDelete
{
	_sut.dataSource = (id<MMFlowViewDataSource>)[NSObject new];

	XCTAssertNoThrow([_sut draggingSession:[self dummySession] endedAtPoint:NSZeroPoint operation:NSDragOperationDelete]);
}

@end
