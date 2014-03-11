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
//  MMNSImageDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMNSImageDecoder.h"
#import "MMMacros.h"

SPEC_BEGIN(MMNSImageDecoderSpec)

describe(@"MMNSImageDecoder", ^{
	__block MMNSImageDecoder *sut = nil;
	__block CGImageRef imageRef = NULL;
	__block NSImage *testImage = nil;

	beforeAll(^{
		NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
		testImage = [[NSImage alloc] initWithContentsOfURL:testImageURL];
	});
	afterAll(^{
		testImage = nil;
	});
	context(@"a new instance", ^{
		beforeEach(^{
			sut = [[MMNSImageDecoder alloc] init];
		});
		afterEach(^{
			sut = nil;
		});
		afterAll(^{
			SAFE_CGIMAGE_RELEASE(imageRef)
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should conform to MMImageDecoderProtocol", ^{
			[[sut should] conformToProtocol:@protocol(MMImageDecoderProtocol)];
		});
		it(@"should respond to newCGImageFromItem:", ^{
			[[sut should] respondToSelector:@selector(newCGImageFromItem:)];
		});
		it(@"should respond to imageFromItem:", ^{
			[[sut should] respondToSelector:@selector(imageFromItem:)];
		});
		context(@"maxPixelSize", ^{
			it(@"should have a maxPixelSize of zero", ^{
				[[theValue(sut.maxPixelSize) should] beZero];
			});
			it(@"should set a size", ^{
				sut.maxPixelSize = 100;
				[[theValue(sut.maxPixelSize) should] equal:theValue(100)];
			});
		});
		context(@"newCGImageFromItem:", ^{
			context(@"when created with an NSImage and non-zero size", ^{
				beforeAll(^{
					sut.maxPixelSize = 100;
					imageRef = [sut newCGImageFromItem:testImage];
				});
				afterAll(^{
					SAFE_CGIMAGE_RELEASE(imageRef)
				});
				it(@"should load an image", ^{
					[[theValue(imageRef != NULL) should] beTrue];
				});
				it(@"should have a width less or equal 100", ^{
					[[theValue(CGImageGetWidth(imageRef)) should] beLessThanOrEqualTo:theValue(100)];
				});
				it(@"should have a height less or equal 100", ^{
					[[theValue(CGImageGetHeight(imageRef)) should] beLessThanOrEqualTo:theValue(100)];
				});
			});
			context(@"when maxPixelSize is zero", ^{
				beforeAll(^{
					sut.maxPixelSize = 0;
					imageRef = [sut newCGImageFromItem:testImage];
				});
				it(@"should load an image", ^{
					[[theValue(imageRef != NULL) should] beTrue];
				});
				it(@"should have a width greater than zero", ^{
					[[theValue(CGImageGetWidth(imageRef)) should] beGreaterThan:theValue(0)];
				});
				it(@"should have a height greater than zero", ^{
					[[theValue(CGImageGetHeight(imageRef)) should] beGreaterThan:theValue(0)];
				});
			});
			context(@"when not invoked with an NSImage", ^{
				beforeAll(^{
					imageRef = [sut newCGImageFromItem:@"Test"];
				});
				afterAll(^{
					SAFE_CGIMAGE_RELEASE(imageRef)
				});
				it(@"should not return an image", ^{
					[[theValue(imageRef == NULL) should] beTrue];
				});
			});
		});
		context(@"imageFromItem:", ^{
			__block NSImage *image = nil;
			
			context(@"when created with an NSImage", ^{
				beforeAll(^{
					image = [sut imageFromItem:testImage];
				});
				afterAll(^{
					image = nil;
				});
				it(@"should load an image", ^{
					[[image should] equal:testImage];
				});
			});
			context(@"when not invoked with an NSImage", ^{
				it(@"should not return an image", ^{
					[[[sut imageFromItem:@"Test"] should] beNil];
				});
			});
		});
	});
});

SPEC_END
