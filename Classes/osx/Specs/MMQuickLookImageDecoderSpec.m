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
//  MMQuickLookImageDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMQuickLookImageDecoder.h"
#import "MMMacros.h"

SPEC_BEGIN(MMQuickLookImageDecoderSpec)

describe(@"MMQuickLookImageDecoder", ^{
	const NSUInteger desiredSize = 50;
	NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
	NSString *testImageString = [testImageURL path];
	__block MMQuickLookImageDecoder *sut = nil;
	__block CGImageRef imageRef = NULL;
	__block NSImage *image = nil;

	beforeEach(^{
		sut = [[MMQuickLookImageDecoder alloc] init];
	});
	afterEach(^{
		sut = nil;
	});
	afterAll(^{
		SAFE_CGIMAGE_RELEASE(imageRef)
		image = nil;
	});
	it(@"should exist", ^{
		[[sut shouldNot] beNil];
	});
	it(@"should conform to MMImageDecoderProtocol", ^{
		[[sut should] conformToProtocol:@protocol(MMImageDecoderProtocol)];
	});
	it(@"should respond to newCGImageFromItem", ^{
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
		it(@"should raise when invoked with nil item", ^{
			[[theBlock(^{
				[sut newCGImageFromItem:nil];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		context(@"when created with NSURL and maxPixelSize of 100", ^{
			beforeAll(^{
				sut.maxPixelSize = desiredSize;
				imageRef = [sut newCGImageFromItem:testImageURL];
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
		context(@"when asking for an image with zero pixel size", ^{
			beforeAll(^{
				sut.maxPixelSize = 0;
				imageRef = [sut newCGImageFromItem:testImageURL];
			});
			afterAll(^{
				SAFE_CGIMAGE_RELEASE(imageRef)
			});
			it(@"should return an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
			it(@"should have a width less or equal than 4000 points", ^{
				[[theValue(CGImageGetWidth(imageRef)) should] beLessThanOrEqualTo:theValue(4000)];
			});
			it(@"should have a height less or equal than 4000 points", ^{
				[[theValue(CGImageGetHeight(imageRef)) should] beLessThanOrEqualTo:theValue(4000)];
			});
		});
		context(@"when asking for an image from a string item", ^{
			beforeEach(^{
				sut.maxPixelSize = desiredSize;
				imageRef = [sut newCGImageFromItem:testImageString];
			});
			it(@"should return an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
		});
	});
	context(@"imageFromItem:", ^{
		context(@"when created with NSURL", ^{
			beforeAll(^{
				image = [sut imageFromItem:testImageURL];
			});
			it(@"should load an image", ^{
				[[image shouldNot] beNil];
			});
			afterAll(^{
				image = nil;
			});
		});
		context(@"when created with NSString", ^{
			beforeAll(^{
				image = [sut imageFromItem:testImageString];
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
	});
});

SPEC_END
