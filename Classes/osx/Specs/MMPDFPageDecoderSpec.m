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
//  MMPDFPageDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import <Quartz/Quartz.h>

#import <Kiwi.h>
#import "MMPDFPageDecoder.h"
#import "MMMacros.h"

SPEC_BEGIN(MMPDFPageDecoderSpec)

describe(@"MMPDFPageDecoder", ^{
	__block MMPDFPageDecoder *sut = nil;
	__block CGImageRef imageRef = NULL;
	__block PDFDocument *document = nil;
	__block PDFPage *pdfPage = nil;
	const NSUInteger expectedPixelSize = 100;

	beforeAll(^{
		NSURL *resource = [[NSBundle bundleForClass:[self class]] URLForResource:@"Test" withExtension:@"pdf"];
		document = [[PDFDocument alloc] initWithURL:resource];
		pdfPage = [document pageAtIndex:0];
	});
	afterAll(^{
		document = nil;
		pdfPage = nil;
	});
	context(@"when not creating with designated initializer", ^{
		it(@"should throw an NSInternalInconsistencyException", ^{
			[[theBlock(^{
				sut = [[MMPDFPageDecoder alloc] init];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
	context(@"when created with designated initializer from a PDFPage", ^{
		beforeEach(^{
			sut = [[MMPDFPageDecoder alloc] initWithItem:pdfPage maxPixelSize:expectedPixelSize];
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
			beforeEach(^{
				imageRef = sut.CGImage;
			});
			it(@"should return an image", ^{
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
			__block NSImage *image = nil;
			
			context(@"creating an image from a PDFPage", ^{
				beforeAll(^{
					image = sut.image;
				});
				afterAll(^{
					image = nil;
				});
				it(@"should return an image", ^{
					[[image shouldNot] beNil];
				});
				it(@"should return an NSImage", ^{
					[[image should] beKindOfClass:[NSImage class]];
				});
			});
		});
	});
	context(@"when created with designated initializer from a CGPDFPageRef", ^{
		beforeEach(^{
			sut = [[MMPDFPageDecoder alloc] initWithItem:(id)[pdfPage pageRef] maxPixelSize:expectedPixelSize];
		});
		afterEach(^{
			sut = nil;
		});
		context(NSStringFromSelector(@selector(CGImage)), ^{
			beforeEach(^{
				imageRef = sut.CGImage;
			});
			it(@"should return an image", ^{
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
			__block NSImage *image = nil;
			
			context(@"creating an image from a PDFPage", ^{
				beforeAll(^{
					image = sut.image;
				});
				afterAll(^{
					image = nil;
				});
				it(@"should return an image", ^{
					[[image shouldNot] beNil];
				});
				it(@"should return an NSImage", ^{
					[[image should] beKindOfClass:[NSImage class]];
				});
			});
		});

		
	});
	context(@"when created with designated initializer with a nil item", ^{
		it(@"should raise an NSInternalInconsistencyException", ^{
			[[theBlock(^{
				sut = [[MMPDFPageDecoder alloc] initWithItem:nil maxPixelSize:expectedPixelSize];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
	context(@"when created with designated initializer with a zero maxImageSize", ^{
		it(@"should raise an NSInternalInconsistencyException", ^{
			[[theBlock(^{
				sut = [[MMPDFPageDecoder alloc] initWithItem:pdfPage maxPixelSize:0];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
});

SPEC_END
