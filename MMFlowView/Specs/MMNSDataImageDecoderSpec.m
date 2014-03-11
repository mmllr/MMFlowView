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
//  MMNSDataImageDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 19.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMNSDataImageDecoder.h"
#import "MMMacros.h"

SPEC_BEGIN(MMNSDataImageDecoderSpec)

describe(@"MMNSDataImageDecoder", ^{
	__block NSData *imageData = nil;
	__block MMNSDataImageDecoder *sut = nil;
	__block CGImageRef imageRef = NULL;

	beforeAll(^{
		imageData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"]];
	});
	afterAll(^{
		imageData = nil;
	});
	beforeEach(^{
		sut = [[MMNSDataImageDecoder alloc] init];
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
		context(@"with maxPixelSize of 100", ^{
			beforeEach(^{
				sut.maxPixelSize = 100;
			});
			context(@"when created from NSData", ^{
				beforeAll(^{
					imageRef = [sut newCGImageFromItem:imageData];
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
			context(@"when trying to create an image from non NSData", ^{
				it(@"should return NULL", ^{
					imageRef = [sut newCGImageFromItem:@"a string, not a NSData instance"];
					[[theValue(imageRef==NULL) should] beTrue];
				});
			});
		});
		context(@"when asking for an image with zero image size", ^{
			beforeAll(^{
				sut.maxPixelSize = 0;
				imageRef = [sut newCGImageFromItem:imageData];
			});
			afterAll(^{
				SAFE_CGIMAGE_RELEASE(imageRef)
			});
			it(@"should return an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
		});
	});
	context(@"imageFromItem:", ^{
		__block NSImage *image = nil;

		context(@"loading from an NSData object", ^{
			beforeAll(^{
				image = [sut imageFromItem:imageData];
			});
			afterAll(^{
				image = nil;
			});
			it(@"should load an image", ^{
				[[image shouldNot] beNil];
			});
			it(@"should return an NSImage", ^{
				[[image should] beKindOfClass:[NSImage class]];
			});
		});
		context(@"when asking for an image with an invalid item", ^{
			it(@"should not return an image for nil", ^{
				[[[sut imageFromItem:nil] should] beNil];
			});
			it(@"should not return an image for an item from wrong type", ^{
				[[[sut imageFromItem:@"Test"] should] beNil];
			});
		});
	});
});

SPEC_END
