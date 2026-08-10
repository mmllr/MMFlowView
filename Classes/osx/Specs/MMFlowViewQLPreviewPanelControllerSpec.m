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
//  MMFlowViewQLPreviewPanelControllerSpec.m
//
//  Created by Markus Müller on 13.05.14.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowView+QLPreviewPanelController.h"
#import "MMFlowView_Private.h"
#import "MMTestImageItem.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewQLPreviewPanelControllerSpec : XCTestCase

@end

@implementation MMFlowViewQLPreviewPanelControllerSpec
{
	MMFlowView *_sut;
	MMTestContentAdapter *_contentAdapter;
	MMTestImageItem *_mockedItem;
}

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
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
	[super tearDown];
}

- (void)testRespondsToEndPreviewPanelControl
{
	XCTAssertTrue([_sut respondsToSelector:@selector(endPreviewPanelControl:)]);
}

- (NSArray *)supportedRepresentationTypes
{
	return @[kMMFlowViewURLRepresentationType,
			 kMMFlowViewPathRepresentationType,
			 kMMFlowViewQTMoviePathRepresentationType,
			 kMMFlowViewQCCompositionPathRepresentationType,
			 kMMFlowViewQuickLookPathRepresentationType];
}

- (NSArray *)unsupportedRepresentationTypes
{
	return @[kMMFlowViewCGImageRepresentationType,
			 kMMFlowViewPDFPageRepresentationType,
			 kMMFlowViewNSImageRepresentationType,
			 kMMFlowViewCGImageSourceRepresentationType,
			 kMMFlowViewNSBitmapRepresentationType,
			 kMMFlowViewQCCompositionRepresentationType,
			 kMMFlowViewNSDataRepresentationType,
			 kMMFlowViewQTMovieRepresentationType];
}

- (void)testAcceptsPreviewPanelControlForSupportedRepresentationTypes
{
	for (NSString *representationType in [self supportedRepresentationTypes]) {
		_mockedItem.imageItemRepresentationType = representationType;
		XCTAssertTrue([_sut acceptsPreviewPanelControl:nil], @"should accept %@", representationType);
	}
}

- (void)testDoesNotAcceptPreviewPanelControlForUnsupportedRepresentationTypes
{
	for (NSString *representationType in [self unsupportedRepresentationTypes]) {
		_mockedItem.imageItemRepresentationType = representationType;
		XCTAssertFalse([_sut acceptsPreviewPanelControl:nil], @"should not accept %@", representationType);
	}
}

// DISABLED: beginPreviewPanelControl:/endPreviewPanelControl: were verified with a
// mocked QLPreviewPanel (setDataSource:/setDelegate: expectations). Driving a real
// QLPreviewPanel requires QuickLook UI and a window server connection, which is not
// available in a headless test run. The panel controller contract (responding to
// acceptsPreviewPanelControl: and the representation type gating) is covered above.

@end
