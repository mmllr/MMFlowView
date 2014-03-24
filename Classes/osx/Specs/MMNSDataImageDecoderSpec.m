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
	const NSUInteger expectedImageSize = 100;

	beforeAll(^{
		imageData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"]];
	});
	afterAll(^{
		imageData = nil;
	});
	
	it(@"should throw an NSInternalInconsistencyException when not created with designated initalizer", ^{
		[[theBlock(^{
			sut = [[MMNSDataImageDecoder alloc] init];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	it(@"should throw an NSInternalInconsistencyException when created with designated initializer from a nil item", ^{
		[[theBlock(^{
			sut = [[MMNSDataImageDecoder alloc] initWithItem:nil maxPixelSize:expectedImageSize];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	it(@"should throw an NSInternalInconsistencyException when created with designated initializer from a valid item with a zero maxiumum pixel size", ^{
		[[theBlock(^{
			sut = [[MMNSDataImageDecoder alloc] initWithItem:imageData maxPixelSize:0];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	it(@"should throw an NSInternalInconsistencyException when created with designated initializer from an invalid item", ^{
		[[theBlock(^{
			sut = [[MMNSDataImageDecoder alloc] initWithItem:@"Test" maxPixelSize:expectedImageSize];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});

	context(@"when created with designated initializer from a valid item and image size", ^{
		beforeEach(^{
			sut = [[MMNSDataImageDecoder alloc] initWithItem:imageData maxPixelSize:expectedImageSize];
		});
		afterEach(^{
			sut = nil;
		});

		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should conform to MMImageDecoderProtocol", ^{
			[[sut should] conformToProtocol:@protocol(MMImageDecoderProtocol)];
		});
		it(@"should respond to initWithItem:maxPixelSize:", ^{
			[[sut should] respondToSelector:@selector(initWithItem:maxPixelSize:)];
		});
		it(@"should respond to CGImage", ^{
			[[sut should] respondToSelector:@selector(CGImage)];
		});
		it(@"should respond to image", ^{
			[[sut should] respondToSelector:@selector(image)];
		});

		context(NSStringFromSelector(@selector(CGImage)), ^{
			beforeAll(^{
				imageRef = sut.CGImage;
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

		context(NSStringFromSelector(@selector(image)), ^{
			it(@"should load an image", ^{
				[[sut.image shouldNot] beNil];
			});
			it(@"should return an NSImage", ^{
				[[sut.image should] beKindOfClass:[NSImage class]];
			});
		});
	});

});

SPEC_END
