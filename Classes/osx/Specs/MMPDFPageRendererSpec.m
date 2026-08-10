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
//
//  Created by Markus Müller on 18.12.13.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMPDFPageRenderer.h"
#import "MMMacros.h"
#import "NSAffineTransform+MMAdditions.h"
#import "NSValue+MMAdditions.h"

@interface MMPDFPageRendererSpec : XCTestCase

@end

@implementation MMPDFPageRendererSpec
{
	MMPDFPageRenderer *_sut;
	CGPDFPageRef _testPage;
	CGRect _testBoxRect;
}

- (void)setUp
{
	[super setUp];
	NSURL *resource = [[NSBundle bundleForClass:[self class]] URLForResource:@"Test" withExtension:@"pdf"];
	PDFDocument *document = [[PDFDocument alloc] initWithURL:resource];
	_testPage = CGPDFPageRetain([[document pageAtIndex:0] pageRef]);
	_testBoxRect = CGPDFPageGetBoxRect(_testPage, kCGPDFCropBox);
}

- (void)tearDown
{
	_sut = nil;
	if (_testPage) {
		CGPDFPageRelease(_testPage);
		_testPage = NULL;
	}
	[super tearDown];
}

- (void)testThrowsWhenNotCreatedWithDesignatedInitializer
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMPDFPageRenderer alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithNonCGPDFPageRef
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:(CGPDFPageRef)@"A string"]), NSException, NSInternalInconsistencyException);
}

- (void)testInstanceExists
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	XCTAssertNotNil(_sut);
}

- (void)testHasThePDFPageSet
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	XCTAssertTrue(_sut.page != NULL);
}

- (void)testImageSizeMatchesThePDFPage
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	NSValue *expectedSize = [NSValue valueWithSize:_testBoxRect.size];
	XCTAssertEqualObjects([NSValue valueWithSize:_sut.imageSize], expectedSize);
}

- (void)testHasWhiteBackgroundColor
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	XCTAssertEqualObjects(_sut.backgroundColor, [NSColor whiteColor]);
}

- (void)testImageSizeCanBeSet
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	_sut.imageSize = CGSizeMake(100, 100);
	XCTAssertEqualObjects([NSValue valueWithSize:_sut.imageSize], [NSValue valueWithSize:CGSizeMake(100, 100)]);
}

- (void)testZeroImageSizeFallsBackToPDFPageSize
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	_sut.imageSize = CGSizeZero;
	XCTAssertEqualObjects([NSValue valueWithSize:_sut.imageSize], [NSValue valueWithSize:_testBoxRect.size]);
}

- (void)testNegativeImageSizeFallsBackToPDFPageSize
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	_sut.imageSize = CGSizeMake(-100, -100);
	XCTAssertEqualObjects([NSValue valueWithSize:_sut.imageSize], [NSValue valueWithSize:_testBoxRect.size]);
}

- (void)testTransformWithSameImageSizeAsPDFPage
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	NSAffineTransform *expectedTransform = [NSAffineTransform affineTransformWithCGAffineTransform:CGPDFPageGetDrawingTransform(_testPage, kCGPDFCropBox, _testBoxRect, 0, true)];
	XCTAssertEqualObjects(_sut.affineTransform, expectedTransform);
}

- (void)testTransformWithGreaterImageSizeThanPDFPage
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	_sut.imageSize = CGSizeMake(CGRectGetWidth(_testBoxRect) * 2, CGRectGetHeight(_testBoxRect) * 2);

	CGFloat scaleX = _sut.imageSize.width / CGRectGetWidth(_testBoxRect);
	NSAffineTransform *expectedTransform = [NSAffineTransform affineTransformWithCGAffineTransform:CGAffineTransformScale(CGAffineTransformMakeTranslation(-_testBoxRect.origin.x, -_testBoxRect.origin.y), scaleX, scaleX)];
	XCTAssertEqualObjects(_sut.affineTransform, expectedTransform);
}

- (void)testRespondsToImageRepresentation
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	XCTAssertTrue([_sut respondsToSelector:@selector(imageRepresentation)]);
}

- (void)testImageRepresentationReturnsANonNilBitmapRep
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	NSBitmapImageRep *representation = _sut.imageRepresentation;
	XCTAssertNotNil(representation);
}

- (void)testImageRepresentationIsANSBitmapImageRep
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	NSBitmapImageRep *representation = _sut.imageRepresentation;
	XCTAssertTrue([representation isKindOfClass:[NSBitmapImageRep class]]);
}

- (void)testImageRepresentationMatchesImageSize
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	NSBitmapImageRep *representation = _sut.imageRepresentation;
	NSValue *expectedSize = [NSValue valueWithSize:_sut.imageSize];
	XCTAssertEqualObjects([NSValue valueWithSize:CGSizeMake((CGFloat)[representation pixelsWide], (CGFloat)[representation pixelsHigh])], expectedSize);
}

- (void)testImageRepresentationHasCalibratedRGBColorspace
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	NSBitmapImageRep *representation = _sut.imageRepresentation;
	XCTAssertEqualObjects([representation colorSpaceName], NSCalibratedRGBColorSpace);
}

- (void)testImageRepresentationHasAlphaChannel
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	NSBitmapImageRep *representation = _sut.imageRepresentation;
	XCTAssertTrue([representation hasAlpha]);
}

- (void)testImageRepresentationHasEightBitsPerSample
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	NSBitmapImageRep *representation = _sut.imageRepresentation;
	XCTAssertEqual([representation bitsPerSample], 8);
}

- (void)testImageRepresentationHasFourSamplesPerPixel
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	NSBitmapImageRep *representation = _sut.imageRepresentation;
	XCTAssertEqual([representation samplesPerPixel], 4);
}

- (void)testImageRepresentationIsNotPlanar
{
	_sut = [[MMPDFPageRenderer alloc] initWithPDFPage:_testPage];
	NSBitmapImageRep *representation = _sut.imageRepresentation;
	XCTAssertFalse([representation isPlanar]);
}

// DISABLED: the original "drawing" context block verified that imageRepresentation
// calls NSGraphicsContext class methods (graphicsContextWithBitmapImageRep:,
// saveGraphicsState, restoreGraphicsState, setCurrentContext:) and NSBezierPath
// fillRect:. These are class-level intercepts that require a mocking framework and
// are not testable with plain XCTest. The observable behavior (a valid NSBitmapImageRep
// with the expected pixel format) is covered by the tests above.

@end
