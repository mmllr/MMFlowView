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
//  MMFlowViewQLPreviewPanelDataSourceSpec.m
//
//  Created by Markus Müller on 13.05.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowView+QLPreviewPanelDataSource.h"
#import "MMFlowView_Private.h"
#import "MMTestImageItem.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewQLPreviewPanelDataSourceSpec : XCTestCase

@end

@implementation MMFlowViewQLPreviewPanelDataSourceSpec
{
	MMFlowView *_sut;
	MMTestContentAdapter *_contentAdapter;
	MMTestImageItem *_mockedItem;
	NSURL *_testImageURL;
}

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	_testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
	_mockedItem = [[MMTestImageItem alloc] init];
	_mockedItem.imageItemUID = @"testUID";
	_contentAdapter = [[MMTestContentAdapter alloc] initWithItems:@[_mockedItem]];
	_sut.contentAdapter = _contentAdapter;
	// make the first (and only) item the selected item
	_sut.coverFlowLayout.numberOfItems = 1;
	_sut.coverFlowLayout.selectedItemIndex = 0;
}

- (void)tearDown
{
	_sut = nil;
	_contentAdapter = nil;
	_mockedItem = nil;
	_testImageURL = nil;
	[super tearDown];
}

- (NSArray *)supportedRepresentationTypes
{
	return @[kMMFlowViewURLRepresentationType,
			 kMMFlowViewPathRepresentationType,
			 kMMFlowViewQTMoviePathRepresentationType,
			 kMMFlowViewQCCompositionPathRepresentationType,
			 kMMFlowViewQuickLookPathRepresentationType];
}

- (void)testReturnsPreviewItemForSupportedRepresentationTypes
{
	for (NSString *representationType in [self supportedRepresentationTypes]) {
		_mockedItem.imageItemRepresentationType = representationType;
		_mockedItem.imageItemRepresentation = _testImageURL;
		XCTAssertNotNil([_sut previewPanel:nil previewItemAtIndex:0], @"should return item for %@", representationType);
	}
}

- (void)testNumberOfPreviewItemsForURLRepresentation
{
	_mockedItem.imageItemRepresentationType = kMMFlowViewURLRepresentationType;
	_mockedItem.imageItemRepresentation = _testImageURL;
	XCTAssertEqual([_sut numberOfPreviewItemsInPreviewPanel:nil], (NSInteger)1);
}

- (void)testPreviewItemForURLRepresentationIsNSURL
{
	_mockedItem.imageItemRepresentationType = kMMFlowViewURLRepresentationType;
	_mockedItem.imageItemRepresentation = _testImageURL;
	id previewItem = [_sut previewPanel:nil previewItemAtIndex:0];
	XCTAssertNotNil(previewItem);
	XCTAssertTrue([previewItem isKindOfClass:[NSURL class]]);
}

- (void)testNumberOfPreviewItemsForPathRepresentation
{
	_mockedItem.imageItemRepresentationType = kMMFlowViewPathRepresentationType;
	_mockedItem.imageItemRepresentation = [_testImageURL path];
	XCTAssertEqual([_sut numberOfPreviewItemsInPreviewPanel:nil], (NSInteger)1);
}

- (void)testPreviewItemForPathRepresentationIsNSURL
{
	_mockedItem.imageItemRepresentationType = kMMFlowViewPathRepresentationType;
	_mockedItem.imageItemRepresentation = [_testImageURL path];
	id previewItem = [_sut previewPanel:nil previewItemAtIndex:0];
	XCTAssertNotNil(previewItem);
	XCTAssertTrue([previewItem isKindOfClass:[NSURL class]]);
}

- (void)testNumberOfPreviewItemsIsZeroForNonQuickLookableItem
{
	_mockedItem.imageItemRepresentationType = kMMFlowViewNSImageRepresentationType;
	_mockedItem.imageItemRepresentation = [[NSImage alloc] initWithContentsOfURL:_testImageURL];
	XCTAssertEqual([_sut numberOfPreviewItemsInPreviewPanel:nil], (NSInteger)0);
}

- (void)testPreviewItemIsNilForNonQuickLookableItem
{
	_mockedItem.imageItemRepresentationType = kMMFlowViewNSImageRepresentationType;
	_mockedItem.imageItemRepresentation = [[NSImage alloc] initWithContentsOfURL:_testImageURL];
	XCTAssertNil([_sut previewPanel:nil previewItemAtIndex:0]);
}

- (void)testNumberOfPreviewItemsIsZeroWithoutSelection
{
	_sut.coverFlowLayout.selectedItemIndex = NSNotFound;
	XCTAssertEqual([_sut numberOfPreviewItemsInPreviewPanel:nil], (NSInteger)0);
}

- (void)testPreviewItemIsNilWithoutSelection
{
	_sut.coverFlowLayout.selectedItemIndex = NSNotFound;
	XCTAssertNil([_sut previewPanel:nil previewItemAtIndex:0]);
}

@end
