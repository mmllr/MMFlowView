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
#import "MMFlowViewImageCache.h"

SPEC_BEGIN(MMFlowViewMMCoverFlowLayerDataSourceSpec)

describe(NSStringFromProtocol(@protocol(MMFlowViewDataSource)), ^{
	__block MMFlowView *sut = nil;
	__block MMCoverFlowLayer *mockedCoverFlowLayer = nil;
	__block id mockedImageFactory = nil;

	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];

		mockedCoverFlowLayer = [MMCoverFlowLayer nullMock];
		mockedImageFactory = [MMFlowViewImageFactory nullMock];
	});
	afterEach(^{
		mockedCoverFlowLayer = nil;
		mockedImageFactory = nil;
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
	context(NSStringFromSelector(@selector(coverFlowLayerWillRelayout:)), ^{
		beforeEach(^{
			sut.imageFactory = mockedImageFactory;
		});
		it(@"should cancel all pending operations on the image factory", ^{
			[[mockedImageFactory should] receive:@selector(cancelPendingDecodings)];

			[sut coverFlowLayerWillRelayout:mockedCoverFlowLayer];
		});
	});
	context(NSStringFromSelector(@selector(coverFlowLayerDidRelayout:)), ^{
		beforeEach(^{
			sut.coverFlowLayer = mockedCoverFlowLayer;
			sut.imageFactory = mockedImageFactory;
		});
		it(@"should set the maxImageSize of the image factory to the layouts itemSite", ^{
			[[mockedImageFactory should] receive:@selector(setMaxImageSize:) withArguments:theValue(sut.coverFlowLayout.itemSize)];

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
				sut.coverFlowLayer = mockedCoverFlowLayer;
				sut.imageFactory = mockedImageFactory;

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
		__block CALayer *contentLayer = nil;
		__block NSImage *testImage = nil;
		__block CGImageRef testImageRef = NULL;
		__block KWCaptureSpy *factorySpy = nil;
		__block void (^completionHandler)(CGImageRef image);
		__block id itemMock = nil;
		NSString *testRepresentationType = @"testRepresentationType";
		NSString *testUID = @"testUID";

		beforeAll(^{
			NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
			testImage = [[NSImage alloc] initWithContentsOfURL:testImageURL];
			testImageRef = CGImageRetain([testImage CGImageForProposedRect:NULL
																   context:NULL
																	 hints:nil]);
		});
		afterAll(^{
			testImage = nil;
			SAFE_CGIMAGE_RELEASE(testImageRef);
		});

		beforeEach(^{
			contentLayer = [CALayer nullMock];
			sut.imageFactory = mockedImageFactory;
			factorySpy = [mockedImageFactory captureArgument:@selector(createCGImageFromRepresentation:withType:completionHandler:) atIndex:2];
			itemMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewItem)];
			[itemMock stub:@selector(imageItemUID) andReturn:testUID];
			[itemMock stub:@selector(imageItemRepresentationType) andReturn:testRepresentationType];
			[itemMock stub:@selector(imageItemRepresentation) andReturn:testImage];
			[sut stub:@selector(imageItemForIndex:) andReturn:itemMock];

		});
		afterEach(^{
			contentLayer = nil;
			factorySpy = nil;
			completionHandler = nil;
			itemMock = nil;
		});
		context(@"image cache", ^{
			__block MMFlowViewImageCache *cacheMock = nil;

			beforeEach(^{
				cacheMock = [MMFlowViewImageCache nullMock];
				sut.imageCache = cacheMock;
			});
			afterEach(^{
				cacheMock = nil;
			});
			context(@"when the image is not in the cache", ^{
				beforeEach(^{
					[cacheMock stub:@selector(imageForUUID:) andReturn:(__bridge id)NULL withArguments:testUID];
				});
				it(@"should ask the image factory for the images", ^{
					[[mockedImageFactory should] receive:@selector(createCGImageFromRepresentation:withType:completionHandler:)];
					[sut coverFlowLayer:mockedCoverFlowLayer willShowLayer:contentLayer atIndex:0];
				});
			});
			context(@"when the image is in the cache", ^{
				beforeEach(^{
					[cacheMock stub:@selector(imageForUUID:) andReturn:(__bridge id)testImageRef withArguments:testUID];
				});
				it(@"should not ask the image factory for the images", ^{
					[[mockedImageFactory shouldNot] receive:@selector(createCGImageFromRepresentation:withType:completionHandler:)];

					[sut coverFlowLayer:mockedCoverFlowLayer willShowLayer:contentLayer atIndex:0];
				});
			});
		});

		context(@"setting the content on the layer with the image factories completion block", ^{
			beforeEach(^{
				[sut stub:@selector(selectedIndex) andReturn:theValue(0)];
				[sut coverFlowLayer:sut.coverFlowLayer willShowLayer:contentLayer atIndex:0];
				completionHandler = factorySpy.argument;
			});
			it(@"it should set the image from the image factory to the layer", ^{
				[[contentLayer should] receive:@selector(setContents:) withArguments:(__bridge id)(testImageRef)];

				completionHandler(testImageRef);
			});
			it(@"should set the image's aspect ratio to the content layer", ^{
				CGFloat width = CGImageGetWidth(testImageRef);
				CGFloat height = CGImageGetHeight(testImageRef);
				CGFloat aspectRatio = width / height;

				CGFloat scaleX = aspectRatio > 1 ? 1 : aspectRatio;
				CGFloat scaleY = aspectRatio > 1 ? 1 / aspectRatio : 1;
				CGAffineTransform aspectTransform = CGAffineTransformMakeScale(scaleX, scaleY);
				CGSize imageSize = CGSizeApplyAffineTransform(sut.coverFlowLayout.itemSize, aspectTransform);
				[[contentLayer should] receive:@selector(setBounds:) withArguments:theValue(CGRectMake(0, 0, imageSize.width, imageSize.height))];

				completionHandler(testImageRef);
			});
		});
		context(@"tracking areas", ^{
			context(@"when invoking the completion block for the selected index", ^{
				beforeEach(^{
					[sut coverFlowLayer:sut.coverFlowLayer willShowLayer:contentLayer atIndex:sut.selectedIndex];
					completionHandler = factorySpy.argument;
					
				});
				it(@"should reset the tracking area for the selected item", ^{
					[[sut should] receive:@selector(setupTrackingAreas)];
					
					completionHandler(testImageRef);
				});
			});
			
			context(@"when invoking the completion block for an unselected index", ^{
				beforeEach(^{
					[sut coverFlowLayer:sut.coverFlowLayer willShowLayer:contentLayer atIndex:sut.selectedIndex+1];
					completionHandler = factorySpy.argument;
					
				});
				it(@"should not reset the tracking area for an unselected item", ^{
					[[sut shouldNot] receive:@selector(setupTrackingAreas)];
					
					completionHandler(testImageRef);
				});
			});
			
		});
	});
});

SPEC_END
