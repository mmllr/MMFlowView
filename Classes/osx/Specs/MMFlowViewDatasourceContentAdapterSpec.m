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
//  MMFlowViewDatasourceContentAdapterSpec.m
//
//  Created by Markus Müller on 02.04.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowViewDatasourceContentAdapter.h"
#import "MMFlowView.h"
#import "MMTestImageItem.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewDatasourceContentAdapterSpec : XCTestCase

@end

@implementation MMFlowViewDatasourceContentAdapterSpec
{
	MMFlowViewDatasourceContentAdapter *_sut;
	MMFlowView *_flowView;
	MMTestFlowViewDataSource *_dataSource;
}

- (void)setUp
{
	[super setUp];
	_flowView = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
}

- (void)tearDown
{
	_sut = nil;
	_flowView = nil;
	_dataSource = nil;
	[super tearDown];
}

- (void)testThrowsWhenCreatedWithDefaultInit
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMFlowViewDatasourceContentAdapter alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithNilFlowView
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:nil]), NSException, NSInternalInconsistencyException);
}

- (NSArray *)makeItems
{
	NSMutableArray *items = [NSMutableArray array];
	for (NSUInteger i = 0; i < 10; i++) {
		MMTestImageItem *item = [[MMTestImageItem alloc] init];
		item.imageItemUID = [NSString stringWithFormat:@"%lu", (unsigned long)i];
		item.imageItemRepresentationType = kMMFlowViewPathRepresentationType;
		[items addObject:item];
	}
	return items;
}

- (void)testInstanceExists
{
	_dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:[self makeItems]];
	_flowView.dataSource = _dataSource;
	_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:_flowView];
	XCTAssertNotNil(_sut);
}

- (void)testConformsToContentAdapterProtocol
{
	_dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:[self makeItems]];
	_flowView.dataSource = _dataSource;
	_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:_flowView];
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMFlowViewContentAdapter)]);
}

- (void)testRespondsToCount
{
	_dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:[self makeItems]];
	_flowView.dataSource = _dataSource;
	_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:_flowView];
	XCTAssertTrue([_sut respondsToSelector:@selector(count)]);
}

- (void)testCountAsksTheDataSource
{
	_dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:[self makeItems]];
	_flowView.dataSource = _dataSource;
	_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:_flowView];

	NSUInteger before = _dataSource.numberOfItemsCallCount;
	[_sut count];
	XCTAssertGreaterThan(_dataSource.numberOfItemsCallCount, before);
}

- (void)testCountReturnsNumberOfItemsInDataSource
{
	_dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:[self makeItems]];
	_flowView.dataSource = _dataSource;
	_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:_flowView];
	XCTAssertEqual([_sut count], (NSUInteger)10);
}

- (void)testRespondsToObjectAtIndexedSubscript
{
	_dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:[self makeItems]];
	_flowView.dataSource = _dataSource;
	_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:_flowView];
	XCTAssertTrue([_sut respondsToSelector:@selector(objectAtIndexedSubscript:)]);
}

- (void)testObjectAtIndexedSubscriptAsksTheDataSource
{
	_dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:[self makeItems]];
	_flowView.dataSource = _dataSource;
	_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:_flowView];

	id<MMFlowViewItem> item = [_sut objectAtIndexedSubscript:0];
	XCTAssertNotNil(item);
}

- (void)testObjectAtIndexedSubscriptRaisesOutOfBounds
{
	_dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:[self makeItems]];
	_flowView.dataSource = _dataSource;
	_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:_flowView];
	XCTAssertThrowsSpecificNamed([_sut objectAtIndexedSubscript:10], NSException, NSRangeException);
}

- (void)testIncompleteDataSourceCountIsZero
{
	_flowView.dataSource = (id<MMFlowViewDataSource>)[NSObject new];
	_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:_flowView];
	XCTAssertEqual([_sut count], (NSUInteger)0);
}

- (void)testIncompleteDataSourceObjectAtIndexedSubscriptReturnsNil
{
	_flowView.dataSource = (id<MMFlowViewDataSource>)[NSObject new];
	_sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:_flowView];
	XCTAssertNil([_sut objectAtIndexedSubscript:0]);
}

@end
