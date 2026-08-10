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
//  MMNSBitmapImageRepDecoderSpec.m
//
//  Created by Markus Müller on 17.12.13.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMNSBitmapImageRepDecoder.h"
#import "MMMacros.h"

@interface MMNSBitmapImageRepDecoderSpec : XCTestCase

@end

@implementation MMNSBitmapImageRepDecoderSpec
{
	MMNSBitmapImageRepDecoder *_sut;
	CGImageRef _imageRef;
	NSBitmapImageRep *_imageRep;
}

static const NSUInteger expectedImageSize = 100;

- (void)setUp
{
	[super setUp];
	NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
	NSImage *image = [[NSImage alloc] initWithContentsOfURL:testImageURL];
	for (NSImageRep *rep in [image representations]) {
		if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
			_imageRep = [(NSBitmapImageRep *)rep copy];
			break;
		}
	}
}

- (void)tearDown
{
	_sut = nil;
	_imageRef = NULL;
	_imageRep = nil;
	[super tearDown];
}

- (void)testThrowsWhenNotCreatedWithDesignatedInitializer
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMNSBitmapImageRepDecoder alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithNilItem
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:nil maxPixelSize:expectedImageSize]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithZeroMaximumPixelSize
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:_imageRep maxPixelSize:0]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithInvalidItem
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:@"Test" maxPixelSize:expectedImageSize]), NSException, NSInternalInconsistencyException);
}

- (void)testValidInstanceExists
{
	_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:_imageRep maxPixelSize:expectedImageSize];
	XCTAssertNotNil(_sut);
}

- (void)testValidInstanceConformsToDecoderProtocol
{
	_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:_imageRep maxPixelSize:expectedImageSize];
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMImageDecoderProtocol)]);
}

- (void)testValidInstanceRespondsToProtocolSelectors
{
	_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:_imageRep maxPixelSize:expectedImageSize];
	XCTAssertTrue([_sut respondsToSelector:@selector(CGImage)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(image)]);
}

- (void)testCGImageCreatesAnImage
{
	_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:_imageRep maxPixelSize:expectedImageSize];
	_imageRef = _sut.CGImage;
	XCTAssertTrue(_imageRef != NULL);
}

- (void)testCGImageDimensionsAreLimited
{
	_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:_imageRep maxPixelSize:expectedImageSize];
	_imageRef = _sut.CGImage;
	XCTAssertLessThanOrEqual(CGImageGetWidth(_imageRef), (size_t)100);
	XCTAssertLessThanOrEqual(CGImageGetHeight(_imageRef), (size_t)100);
}

- (void)testImageReturnsAnImage
{
	_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:_imageRep maxPixelSize:expectedImageSize];
	XCTAssertNotNil(_sut.image);
}

- (void)testImageReturnsAnNSImage
{
	_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:_imageRep maxPixelSize:expectedImageSize];
	XCTAssertTrue([_sut.image isKindOfClass:[NSImage class]]);
}

- (void)testImageContainsTheBitmapRepInItsRepresentations
{
	_sut = [[MMNSBitmapImageRepDecoder alloc] initWithItem:_imageRep maxPixelSize:expectedImageSize];
	XCTAssertTrue([[_sut.image representations] containsObject:_imageRep]);
}

@end
