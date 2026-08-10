/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://codeberg.org/mmllr All rights reserved.
 
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
//
//  Created by Markus Müller on 17.12.13.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Quartz/Quartz.h>

#import "MMPDFPageDecoder.h"
#import "MMMacros.h"

@interface MMPDFPageDecoderSpec : XCTestCase

@end

@implementation MMPDFPageDecoderSpec
{
	MMPDFPageDecoder *_sut;
	CGImageRef _imageRef;
	PDFDocument *_document;
	PDFPage *_pdfPage;
}

static const NSUInteger expectedPixelSize = 100;

- (void)setUp
{
	[super setUp];
	NSURL *resource = [[NSBundle bundleForClass:[self class]] URLForResource:@"Test" withExtension:@"pdf"];
	_document = [[PDFDocument alloc] initWithURL:resource];
	_pdfPage = [_document pageAtIndex:0];
}

- (void)tearDown
{
	_sut = nil;
	_imageRef = NULL;
	_document = nil;
	_pdfPage = nil;
	[super tearDown];
}

- (void)testThrowsWhenNotCreatedWithDesignatedInitializer
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMPDFPageDecoder alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithNilItem
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMPDFPageDecoder alloc] initWithItem:nil maxPixelSize:expectedPixelSize]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithZeroMaximumPixelSize
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMPDFPageDecoder alloc] initWithItem:_pdfPage maxPixelSize:0]), NSException, NSInternalInconsistencyException);
}

- (void)testPDFPageInstanceExists
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:_pdfPage maxPixelSize:expectedPixelSize];
	XCTAssertNotNil(_sut);
}

- (void)testPDFPageInstanceConformsToDecoderProtocol
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:_pdfPage maxPixelSize:expectedPixelSize];
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMImageDecoderProtocol)]);
}

- (void)testPDFPageInstanceRespondsToProtocolSelectors
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:_pdfPage maxPixelSize:expectedPixelSize];
	XCTAssertTrue([_sut respondsToSelector:@selector(initWithItem:maxPixelSize:)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(CGImage)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(image)]);
}

- (void)testPDFPageCGImageReturnsAnImage
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:_pdfPage maxPixelSize:expectedPixelSize];
	_imageRef = _sut.CGImage;
	XCTAssertTrue(_imageRef != NULL);
}

- (void)testPDFPageCGImageDimensionsAreLimited
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:_pdfPage maxPixelSize:expectedPixelSize];
	_imageRef = _sut.CGImage;
	XCTAssertLessThanOrEqual(CGImageGetWidth(_imageRef), (size_t)100);
	XCTAssertLessThanOrEqual(CGImageGetHeight(_imageRef), (size_t)100);
}

- (void)testPDFPageImageReturnsAnImage
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:_pdfPage maxPixelSize:expectedPixelSize];
	XCTAssertNotNil(_sut.image);
}

- (void)testPDFPageImageReturnsAnNSImage
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:_pdfPage maxPixelSize:expectedPixelSize];
	XCTAssertTrue([_sut.image isKindOfClass:[NSImage class]]);
}

- (void)testCGPDFPageRefInstanceCGImageReturnsAnImage
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:(id)[_pdfPage pageRef] maxPixelSize:expectedPixelSize];
	_imageRef = _sut.CGImage;
	XCTAssertTrue(_imageRef != NULL);
}

- (void)testCGPDFPageRefInstanceCGImageDimensionsAreLimited
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:(id)[_pdfPage pageRef] maxPixelSize:expectedPixelSize];
	_imageRef = _sut.CGImage;
	XCTAssertLessThanOrEqual(CGImageGetWidth(_imageRef), (size_t)100);
	XCTAssertLessThanOrEqual(CGImageGetHeight(_imageRef), (size_t)100);
}

- (void)testCGPDFPageRefInstanceImageReturnsAnImage
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:(id)[_pdfPage pageRef] maxPixelSize:expectedPixelSize];
	XCTAssertNotNil(_sut.image);
}

- (void)testCGPDFPageRefInstanceImageReturnsAnNSImage
{
	_sut = [[MMPDFPageDecoder alloc] initWithItem:(id)[_pdfPage pageRef] maxPixelSize:expectedPixelSize];
	XCTAssertTrue([_sut.image isKindOfClass:[NSImage class]]);
}

@end
