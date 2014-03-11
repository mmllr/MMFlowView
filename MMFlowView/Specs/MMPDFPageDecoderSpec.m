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

#import "Kiwi.h"
#import "MMPDFPageDecoder.h"
#import "MMMacros.h"

SPEC_BEGIN(MMPDFPageDecoderSpec)

describe(@"MMPDFPageDecoder", ^{
	__block MMPDFPageDecoder *sut = nil;
	__block CGImageRef imageRef = NULL;
	__block PDFDocument *document = nil;
	__block PDFPage *pdfPage = nil;

	beforeAll(^{
		NSURL *resource = [[NSBundle bundleForClass:[self class]] URLForResource:@"Test" withExtension:@"pdf"];
		document = [[PDFDocument alloc] initWithURL:resource];
		pdfPage = [document pageAtIndex:0];
	});
	afterAll(^{
		document = nil;
		pdfPage = nil;
	});
	context(@"a new instance", ^{
		beforeEach(^{
			sut = [[MMPDFPageDecoder alloc] init];
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
		context(@"setting the maxPixelSize to 100", ^{
			beforeEach(^{
				sut.maxPixelSize = 100;
			});
			it(@"should have a maxPixelSize of 100", ^{
				[[theValue(sut.maxPixelSize) should] equal:theValue(100)];
			});
			context(@"newCGImageFromItem:", ^{
				context(@"creating an image from a PDFPage", ^{
					beforeAll(^{
						imageRef = [sut newCGImageFromItem:pdfPage];
					});
					afterAll(^{
						SAFE_CGIMAGE_RELEASE(imageRef)
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
				context(@"creating an image from a CGPDFPageRef", ^{
					beforeAll(^{
						imageRef = [sut newCGImageFromItem:(id)[pdfPage pageRef]];
					});
					afterAll(^{
						SAFE_CGIMAGE_RELEASE(imageRef)
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
				context(@"invoking with a non pdf item", ^{
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
				
				context(@"creating an image from a PDFPage", ^{
					beforeAll(^{
						image = [sut imageFromItem:pdfPage];
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
				context(@"creating an image from a CGPDFPageRef", ^{
					beforeAll(^{
						image = [sut imageFromItem:(id)[pdfPage pageRef]];
					});
					afterAll(^{
						image = nil;
					});
					it(@"should return an image", ^{
						[[image shouldNot] beNil];
					});
				});
				context(@"invoking with a non pdf item", ^{
					it(@"should not return an image", ^{
						[[[sut imageFromItem:@"Test"] should] beNil];
					});
				});
			});
		});
		
	});
});

SPEC_END
