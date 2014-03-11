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
//  MMPDFPageRendererSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 22.01.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMPDFPageRenderer.h"
#import "MMMacros.h"
#import "NSAffineTransform+MMAdditions.h"
#import "NSValue+MMAdditions.h"

SPEC_BEGIN(MMPDFPageRendererSpec)

describe(@"MMPDFPageRenderer", ^{
	__block MMPDFPageRenderer *sut = nil;
	__block CGPDFPageRef testPage = NULL;
	__block CGRect testBoxRect;
	
	beforeAll(^{
		NSURL *resource = [[NSBundle bundleForClass:[self class]] URLForResource:@"Test" withExtension:@"pdf"];
		PDFDocument *document = [[PDFDocument alloc] initWithURL:resource];
		testPage = CGPDFPageRetain([[document pageAtIndex:0] pageRef]);
		testBoxRect = CGPDFPageGetBoxRect(testPage, kCGPDFCropBox);
	});
	afterAll(^{
		if (testPage) {
			CGPDFPageRelease(testPage);
			testPage = NULL;
		}
	});
	it(@"should not be possible to create without its designated initalizer", ^{
		[[theBlock(^{
			sut = [[MMPDFPageRenderer alloc] init];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	context(@"creating with a non CGPDFPageRef", ^{
		it(@"should throw an NSInternalInconsistencyException", ^{
			[[theBlock(^{
				sut = [[MMPDFPageRenderer alloc] initWithPDFPage:(CGPDFPageRef)@"A string"];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
	context(@"a new instance", ^{
		beforeEach(^{
			sut = [[MMPDFPageRenderer alloc] initWithPDFPage:testPage];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should have the pdf page set", ^{
			[[theValue(sut.page != NULL) should] beTrue];
		});
		it(@"should have an imageSize matching the pdf page", ^{
			NSValue *expectedSize = [NSValue valueWithSize:testBoxRect.size];
			[[[NSValue valueWithSize:sut.imageSize] should] equal:expectedSize];
		});
		it(@"should have a white background color", ^{
			[[sut.backgroundColor should] equal:[NSColor whiteColor]];
		});
		context(@"imageSize", ^{
			it(@"should set the imageSize", ^{
				sut.imageSize = CGSizeMake(100, 100);
				NSValue *expectedSize = [NSValue valueWithSize:CGSizeMake(100, 100)];
				[[[NSValue valueWithSize:sut.imageSize] should] equal:expectedSize];
			});
			context(@"setting a zero image size", ^{
				beforeEach(^{
					sut.imageSize = CGSizeZero;
				});
				it(@"should have the size of the pdf page", ^{
					NSValue *expectedSize = [NSValue valueWithSize:testBoxRect.size];
					[[[NSValue valueWithSize:sut.imageSize] should] equal:expectedSize];
				});
			});
			it(@"should return the size of the pdf page when setting a negative size", ^{
				sut.imageSize = CGSizeMake(-100, -100);
				NSValue *expectedSize = [NSValue valueWithSize:testBoxRect.size];
				[[[NSValue valueWithSize:sut.imageSize] should] equal:expectedSize];
			});
		});
		context(@"transform", ^{
			context(@"same imageSize as pdf page", ^{
				it(@"should have the plain core graphics pdf page drawing transform", ^{
					NSAffineTransform *expectedTransform = [NSAffineTransform affineTransformWithCGAffineTransform:CGPDFPageGetDrawingTransform(testPage, kCGPDFCropBox, testBoxRect, 0, true)];
					[[sut.affineTransform should] equal:expectedTransform];
				});
			});
			context(@"when setting a greater imageSize than pdf page", ^{
				beforeEach(^{
					sut.imageSize = CGSizeMake(CGRectGetWidth(testBoxRect)*2, CGRectGetHeight(testBoxRect)*2);
				});
				it(@"should have the imageSize", ^{
					NSValue *expectedSize = [NSValue valueWithSize:CGSizeMake(CGRectGetWidth(testBoxRect)*2, CGRectGetHeight(testBoxRect)*2)];
					[[[NSValue valueWithSize:sut.imageSize] should] equal:expectedSize];
				});
				it(@"should have a width-scaling and box-origin offset transform", ^{
					CGFloat scaleX = sut.imageSize.width / CGRectGetWidth(testBoxRect);
					NSAffineTransform *expectedTransform = [NSAffineTransform affineTransformWithCGAffineTransform:CGAffineTransformScale(CGAffineTransformMakeTranslation(-testBoxRect.origin.x, -testBoxRect.origin.y), scaleX, scaleX)];
					[[sut.affineTransform should] equal:expectedTransform];
					
				});
			});
		});
		context(@"imageRepresentation", ^{
			__block NSBitmapImageRep *representation = nil;

			beforeAll(^{
				representation = sut.imageRepresentation;
			});
			afterAll(^{
				representation = nil;
			});
			it(@"should respond to -imageRepresentation", ^{
				[[sut should] respondToSelector:@selector(imageRepresentation)];
			});
			it(@"should return an imageRepresentation", ^{
				[[representation shouldNot] beNil];
			});
			it(@"should return a NSBitmapImageRepresentation", ^{
				[[representation should] beKindOfClass:[NSBitmapImageRep class]];
			});
			it(@"should match the imageSize", ^{
				NSValue *expectedSize = [NSValue valueWithSize:sut.imageSize];
				[[[NSValue valueWithSize:CGSizeMake([representation pixelsWide], [representation pixelsHigh])] should] equal:expectedSize];
			});
			it(@"should have a calibrated RGB colorspace", ^{
				[[[representation colorSpaceName] should] equal:NSCalibratedRGBColorSpace];
			});
			it(@"should have an alpha channel", ^{
				[[theValue([representation hasAlpha]) should] beYes];
			});
			it(@"should have 8 bits per sample", ^{
				[[theValue([representation bitsPerSample]) should] equal:theValue(8)];
			});
			it(@"should have 4 samples per pixel", ^{
				[[theValue([representation samplesPerPixel]) should] equal:theValue(4)];
			});
			it(@"should not be planar", ^{
				[[theValue([representation isPlanar]) should] beNo];
			});
			context(@"drawing", ^{
				__block id mockedContext = nil;

				beforeEach(^{
					mockedContext = [NSGraphicsContext nullMock];
					[NSGraphicsContext stub:@selector(graphicsContextWithBitmapImageRep:) andReturn:mockedContext];
				});
				it(@"should create a graphics context", ^{
					[[[NSGraphicsContext class] should] receive:@selector(graphicsContextWithBitmapImageRep:)];

					[sut imageRepresentation];
				});
				it(@"should save the context", ^{
					[[[NSGraphicsContext class] should] receive:@selector(saveGraphicsState)];
					[sut imageRepresentation];
				});
				it(@"should restore the context", ^{
					[[[NSGraphicsContext class] should] receive:@selector(restoreGraphicsState)];
					[sut imageRepresentation];
				});
				it(@"should set the graphics context", ^{
					[[NSGraphicsContext should] receive:@selector(setCurrentContext:) withArguments:mockedContext];
					[sut imageRepresentation];
				});
				it(@"should set the transform to the context", ^{
					id mockedTransform = [NSAffineTransform nullMock];
					[sut stub:@selector(affineTransform) andReturn:mockedTransform];
					[[mockedTransform should] receive:@selector(set)];
					[sut imageRepresentation];
				});
				it(@"should ask the context for its CoreGraphics context", ^{
					[[mockedContext should] receive:@selector(graphicsPort) withCountAtLeast:1];
					[sut imageRepresentation];
				});
				context(@"background", ^{
					it(@"should fill the context with the background color", ^{
						[[sut.backgroundColor should] receive:@selector(setFill)];
						[sut imageRepresentation];
					});
					it(@"should fill the imageRect", ^{
						CGSize imageSize = sut.imageSize;
						[[[NSBezierPath class] should] receive:@selector(fillRect:) withArguments:theValue(CGRectMake(0, 0, imageSize.width, imageSize.height))];
						[sut imageRepresentation];
					});
				});
			});
		});
	});
});

SPEC_END
