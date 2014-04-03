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
//  Created by Markus Müller on 16.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView+QLPreviewPanelDataSource.h"
#import "MMFlowView_Private.h"

SPEC_BEGIN(MMFlowViewQLPreviewPanelDataSourceSpec)

describe(@"MMFlowView+QLPreviewPanelDataSource", ^{
	__block MMFlowView *sut = nil;
	__block NSURL *testImageURL = nil;
	__block id mockedItem = nil;
	__block id contentAdapterMock = nil;

	beforeAll(^{
		testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
		mockedItem = [KWMock nullMockForProtocol:@protocol(MMFlowViewItem)];
	});
	afterAll(^{
		mockedItem = [KWMock nullMockForProtocol:@protocol(MMFlowViewItem)];
		testImageURL = nil;
	});
	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
		contentAdapterMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewContentAdapter)];
		[contentAdapterMock stub:@selector(objectAtIndexedSubscript:) andReturn:mockedItem];
		sut.contentAdapter = contentAdapterMock;
	});
	afterEach(^{
		sut = nil;
		contentAdapterMock = nil;
	});
	context(@"when having a selected item", ^{
		beforeEach(^{
			[sut stub:@selector(selectedIndex) andReturn:theValue(0)];
		});
		context(@"when a quick-lookable presentation item is selected", ^{
			__block id previewItem = nil;

			context(@"when asking for item in supported representation types", ^{
				__block NSArray *supportedRepresentationTypes = nil;
  
				beforeEach(^{
					supportedRepresentationTypes = @[kMMFlowViewURLRepresentationType,
													 kMMFlowViewPathRepresentationType,
													 kMMFlowViewQTMoviePathRepresentationType,
													 kMMFlowViewQCCompositionPathRepresentationType,
													 kMMFlowViewQuickLookPathRepresentationType];
					[mockedItem stub:@selector(imageItemRepresentation) andReturn:testImageURL];
				});
 
				it(@"should return a previewItem", ^{
					for ( NSString *representationType in supportedRepresentationTypes ) {
						[mockedItem stub:@selector(imageItemRepresentationType) andReturn:representationType];
						[[(id)[sut previewPanel:[QLPreviewPanel nullMock] previewItemAtIndex:0] shouldNot] beNil];
					}
				});
			});
			context(@"when asking for a NSURL based representation", ^{
				beforeEach(^{
					[mockedItem stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewURLRepresentationType];
					[mockedItem stub:@selector(imageItemRepresentation) andReturn:testImageURL];
					previewItem = [sut previewPanel:[QLPreviewPanel nullMock] previewItemAtIndex:0];
				});
				it(@"it should return one for numberOfPreviewItemsInPreviewPanel", ^{
					[[theValue([sut numberOfPreviewItemsInPreviewPanel:[QLPreviewPanel nullMock]]) should] equal:theValue(1)];
				});
				it(@"should not return nil", ^{
					[[previewItem shouldNot] beNil];
				});
				it(@"should return a NSURL", ^{
					[[previewItem should] beKindOfClass:[NSURL class]];
				});
			});
			context(@"when asking for a string based path representation", ^{
				beforeEach(^{
					[mockedItem stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewPathRepresentationType];
					[mockedItem stub:@selector(imageItemRepresentation) andReturn:[testImageURL path]];
					previewItem = [sut previewPanel:[QLPreviewPanel nullMock] previewItemAtIndex:0];
				});
				it(@"it should return one for numberOfPreviewItemsInPreviewPanel", ^{
					[[theValue([sut numberOfPreviewItemsInPreviewPanel:[QLPreviewPanel nullMock]]) should] equal:theValue(1)];
				});
				it(@"should not return nil", ^{
					[[previewItem shouldNot] beNil];
				});
				it(@"should return a NSURL", ^{
					[[previewItem should] beKindOfClass:[NSURL class]];
				});
			});
		});
		context(@"when no quick-lookable presentation item is selected", ^{
			beforeEach(^{
				[mockedItem stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewNSImageRepresentationType];
				[mockedItem stub:@selector(imageItemRepresentation) andReturn:[NSImage nullMock]];
			});
			it(@"it should return zero for numberOfPreviewItemsInPreviewPanel:", ^{
				[[theValue([sut numberOfPreviewItemsInPreviewPanel:[QLPreviewPanel nullMock]]) should] beZero];
			});
			it(@"should return nil when asking for the preview item", ^{
				[[(id)[sut previewPanel:[QLPreviewPanel nullMock] previewItemAtIndex:0] should] beNil];
			});
		});
	});
	context(@"when no item is selected", ^{
		it(@"should return zero for numberOfPreviewItemsInPreviewPanel:", ^{
			[[theValue([sut numberOfPreviewItemsInPreviewPanel:[QLPreviewPanel nullMock]]) should] beZero];
		});
		it(@"should return nil when asking for the preview item", ^{
			[[(id)[sut previewPanel:[QLPreviewPanel nullMock] previewItemAtIndex:0] should] beNil];
		});
	});
});

SPEC_END
