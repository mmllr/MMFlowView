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
//  MMFlowViewMMCoverFlowLayerDataSourceSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 11.03.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView+MMCoverFlowLayerDataSource.h"
#import "MMCoverFlowLayer.h"
#import "MMFlowView_Private.h"
#import "MMFlowViewImageFactory.h"
#import "MMMacros.h"
#import "MMCoverFlowLayout.h"
#import "MMScrollBarLayer.h"

SPEC_BEGIN(MMFlowViewMMCoverFlowLayerDataSourceSpec)

describe(NSStringFromProtocol(@protocol(MMFlowViewDataSource)), ^{
	__block MMFlowView *sut = nil;
	
	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	});
	afterEach(^{
		sut = nil;
	});
	
	it(@"should conform to the MMCoverFlowLayerDataSource protocol", ^{
		[[sut should] conformToProtocol:@protocol(MMCoverFlowLayerDataSource)];
	});
	it(@"should respond to coverFlowLayer:contentLayerForIndex:", ^{
		[[sut should] respondToSelector:@selector(coverFlowLayer:contentLayerForIndex:)];
	});
	it(@"should respond to coverFlowLayerWillRelayout:", ^{
		[[sut should] respondToSelector:@selector(coverFlowLayerWillRelayout:)];
	});
	it(@"should respond to coverFlowLayerDidRelayout:", ^{
		[[sut should] respondToSelector:@selector(coverFlowLayerDidRelayout:)];
	});
	it(@"should respond to coverFlowLayer:willShowLayer:atIndex:", ^{
		[[sut should] respondToSelector:@selector(coverFlowLayer:willShowLayer:atIndex:)];
	});
	it(@"should be the datasource for the coverflow layer", ^{
		[[sut should] equal:sut.coverFlowLayer.dataSource];
	});
	context(NSStringFromSelector(@selector(coverFlowLayerDidRelayout:)), ^{
		__block MMCoverFlowLayer *mockedCoverFlowLayer = nil;
		
		beforeEach(^{
			mockedCoverFlowLayer = [MMCoverFlowLayer nullMock];
		});
		it(@"should set the maxImageSize of the image factory to the layouts itemSite", ^{
			MMFlowViewImageFactory *mockedImageFactory = [MMFlowViewImageFactory nullMock];
			[[mockedImageFactory should] receive:@selector(setMaxImageSize:) withArguments:theValue(sut.layout.itemSize)];
			sut.imageFactory = mockedImageFactory;
			[sut coverFlowLayerDidRelayout:mockedCoverFlowLayer];
		});
		context(@"scroll bar interaction", ^{
			__block MMScrollBarLayer *mockedScrollBarLayer = nil;
			
			beforeEach(^{
				mockedScrollBarLayer = [MMScrollBarLayer nullMock];
				sut.scrollBarLayer = mockedScrollBarLayer;
			});
			afterEach(^{
				mockedScrollBarLayer = nil;
			});
			it(@"should tell the scroll bar layer to relayout", ^{
				[[mockedScrollBarLayer should] receive:@selector(setNeedsLayout)];
				
				[sut coverFlowLayerDidRelayout:mockedCoverFlowLayer];
			});
		});
	});
	context(NSStringFromSelector(@selector(coverFlowLayer:contentLayerForIndex:)), ^{
		__block CALayer *contentLayer = nil;
		
		context(@"when asking for a content layer", ^{
			beforeEach(^{
				contentLayer = [sut coverFlowLayer:sut.coverFlowLayer contentLayerForIndex:0];
			});
			afterEach(^{
				contentLayer = nil;
			});
			it(@"should not return nil when asked for a content layer", ^{
				[[contentLayer shouldNot] beNil];
			});
			it(@"should have set an image", ^{
				[[contentLayer.contents shouldNot] beNil];
			});
			it(@"should have a contentsGravity of kCAGravityResizeAspectFill", ^{
				[[contentLayer.contentsGravity should] equal:kCAGravityResizeAspectFill];
			});
		});
	});
	context(NSStringFromSelector(@selector(coverFlowLayer:willShowLayer:atIndex:)), ^{
		__block MMCoverFlowLayer *mockedCoverFlowLayer = nil;
		__block CALayer *contentLayer = nil;
		__block id mockedImageFactory = nil;
		__block CGImageRef testImageRef = NULL;
		
		beforeAll(^{
			NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
			testImageRef = CGImageRetain([[[NSImage alloc] initWithContentsOfURL:testImageURL] CGImageForProposedRect:NULL context:NULL hints:nil]);
		});
		afterAll(^{
			SAFE_CGIMAGE_RELEASE(testImageRef);
		});
		
		beforeEach(^{
			mockedCoverFlowLayer = [MMCoverFlowLayer nullMock];
			mockedImageFactory = [MMFlowViewImageFactory nullMock];
			contentLayer = [CALayer nullMock];
			sut.coverFlowLayer = mockedCoverFlowLayer;
			sut.imageFactory = mockedImageFactory;
		});
		afterEach(^{
			contentLayer = nil;
			mockedCoverFlowLayer = nil;
			mockedImageFactory = nil;
		});
		it(@"should ask the image factory for the images", ^{
			[[mockedImageFactory should] receive:@selector(createCGImageForItem:completionHandler:)];
			[sut coverFlowLayer:mockedCoverFlowLayer willShowLayer:contentLayer atIndex:0];
		});
		it(@"it should set the image from the image factory to the layer", ^{
			[[contentLayer should] receive:@selector(setContents:) withArguments:(__bridge id)(testImageRef)];
			
			KWCaptureSpy *factorySpy = [mockedImageFactory captureArgument:@selector(createCGImageForItem:completionHandler:) atIndex:1];
			
			[sut coverFlowLayer:mockedCoverFlowLayer willShowLayer:contentLayer atIndex:0];
			void (^completionHandler)(CGImageRef image) = factorySpy.argument;
			completionHandler(testImageRef);
		});
	});
});
		 
SPEC_END
