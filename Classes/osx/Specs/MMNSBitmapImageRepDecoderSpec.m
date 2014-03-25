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
//  MMNSBitmapImageRepDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import <Kiwi.h>
#import "MMNSBitmapImageRepDecoder.h"
#import "MMMacros.h"

SPEC_BEGIN(MMNSBitmapImageRepDecoderSpec)

describe(@"MMNSBitmapImageRepDecoder", ^{
	__block MMNSBitmapImageRepDecoder *sut = nil;
	__block CGImageRef imageRef = NULL;
	__block NSBitmapImageRep *imageRep = nil;
	__block CGImageRef testImageRef = NULL;
	const NSUInteger expectedImageSize = 100;

	beforeAll(^{
		NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
		NSImage *image = [[NSImage alloc] initWithContentsOfURL:testImageURL];

		for ( NSImageRep* rep in [image representations] ) {
			if ([rep isKindOfClass:[NSBitmapImageRep class]] ) {
				imageRep = [(NSBitmapImageRep*)rep copy];
				break;
			}
		}
	});
	afterAll(^{
		imageRep = nil;
	});
	it(@"should throw an NSInternalInconsistencyException when not created with designated initalizer", ^{
		[[theBlock(^{
			sut = [[MMNSBitmapImageRepDecoder alloc] init];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	it(@"should throw an NSInternalInconsistencyException when created with designated initializer from a nil item", ^{
		[[theBlock(^{
			sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:nil maxPixelSize:expectedImageSize];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	it(@"should throw an NSInternalInconsistencyException when created with designated initializer from a valid item with a zero maxiumum pixel size", ^{
		[[theBlock(^{
			sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:imageRep maxPixelSize:0];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	it(@"should throw an NSInternalInconsistencyException when created with designated initializer from an invalid item", ^{
		[[theBlock(^{
			sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:@"Test" maxPixelSize:expectedImageSize];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});

	
	context(@"when created with designated initializer from a valid item and image size", ^{
		beforeEach(^{
			sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:imageRep maxPixelSize:expectedImageSize];
		});
		afterEach(^{
			sut = nil;
			SAFE_CGIMAGE_RELEASE(testImageRef)
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should conform to MMImageDecoderProtocol", ^{
			[[sut should] conformToProtocol:@protocol(MMImageDecoderProtocol)];
		});
		it(@"should respond to newCGImageFromItem:", ^{
			[[sut should] respondToSelector:@selector(CGImage)];
		});
		it(@"should respond to imageFromItem:", ^{
			[[sut should] respondToSelector:@selector(image)];
		});
		
		context(NSStringFromSelector(@selector(CGImage)), ^{
			beforeEach(^{
				imageRef = sut.CGImage;
			});
			it(@"should create an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
			it(@"should have a width less or equal 100", ^{
				[[theValue(CGImageGetWidth(imageRef)) should] beLessThanOrEqualTo:theValue(100)];
			});
			it(@"should have a height less or equal 100", ^{
				[[theValue(CGImageGetHeight(imageRef)) should] beLessThanOrEqualTo:theValue(100)];
			});
		});

		context(NSStringFromSelector(@selector(image)), ^{
			it(@"should return an image", ^{
				[[sut.image shouldNot] beNil];
			});
			it(@"should return an NSImage", ^{
				[[sut.image should] beKindOfClass:[NSImage class]];
			});
			it(@"should contain the bitmapRef in its representations", ^{
				[[[sut.image representations] should] contain:imageRep];
			});
		});
	});
});

SPEC_END
