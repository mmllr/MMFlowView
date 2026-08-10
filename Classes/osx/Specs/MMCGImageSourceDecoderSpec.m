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
//  MMCGImageSourceDecoderSpec.m
//
//  Created by Markus Müller on 17.12.13.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMCGImageSourceDecoder.h"
#import "MMMacros.h"

@interface MMCGImageSourceDecoderSpec : XCTestCase

@end

@implementation MMCGImageSourceDecoderSpec
{
	MMCGImageSourceDecoder *_sut;
	CGImageSourceRef _imageSource;
	CGImageRef _imageRef;
}

static const NSUInteger expectedPixelSize = 100;

- (void)setUp
{
	[super setUp];
	NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
	_imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)(imageURL), NULL);
}

- (void)tearDown
{
	_sut = nil;
	_imageRef = NULL;
	if (_imageSource) {
		CFRelease(_imageSource);
		_imageSource = NULL;
	}
	[super tearDown];
}

- (void)testThrowsWhenNotCreatedWithDesignatedInitializer
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMCGImageSourceDecoder alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithNilItem
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMCGImageSourceDecoder alloc] initWithItem:nil maxPixelSize:expectedPixelSize]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithInvalidItem
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMCGImageSourceDecoder alloc] initWithItem:@"test" maxPixelSize:expectedPixelSize]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithZeroMaximumPixelSize
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMCGImageSourceDecoder alloc] initWithItem:(__bridge id)_imageSource maxPixelSize:0]), NSException, NSInternalInconsistencyException);
}

- (void)testValidInstanceExists
{
	_sut = [[MMCGImageSourceDecoder alloc] initWithItem:(__bridge id)_imageSource maxPixelSize:expectedPixelSize];
	XCTAssertNotNil(_sut);
}

- (void)testValidInstanceConformsToDecoderProtocol
{
	_sut = [[MMCGImageSourceDecoder alloc] initWithItem:(__bridge id)_imageSource maxPixelSize:expectedPixelSize];
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMImageDecoderProtocol)]);
}

- (void)testValidInstanceRespondsToProtocolSelectors
{
	_sut = [[MMCGImageSourceDecoder alloc] initWithItem:(__bridge id)_imageSource maxPixelSize:expectedPixelSize];
	XCTAssertTrue([_sut respondsToSelector:@selector(initWithItem:maxPixelSize:)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(CGImage)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(image)]);
}

- (void)testCGImageLoadsAnImage
{
	_sut = [[MMCGImageSourceDecoder alloc] initWithItem:(__bridge id)_imageSource maxPixelSize:expectedPixelSize];
	_imageRef = _sut.CGImage;
	XCTAssertTrue(_imageRef != NULL);
}

- (void)testCGImageDimensionsAreLimited
{
	_sut = [[MMCGImageSourceDecoder alloc] initWithItem:(__bridge id)_imageSource maxPixelSize:expectedPixelSize];
	_imageRef = _sut.CGImage;
	XCTAssertLessThanOrEqual(CGImageGetWidth(_imageRef), (size_t)100);
	XCTAssertLessThanOrEqual(CGImageGetHeight(_imageRef), (size_t)100);
}

- (void)testImageReturnsAnImage
{
	_sut = [[MMCGImageSourceDecoder alloc] initWithItem:(__bridge id)_imageSource maxPixelSize:expectedPixelSize];
	XCTAssertNotNil(_sut.image);
}

- (void)testImageReturnsAnNSImage
{
	_sut = [[MMCGImageSourceDecoder alloc] initWithItem:(__bridge id)_imageSource maxPixelSize:expectedPixelSize];
	XCTAssertTrue([_sut.image isKindOfClass:[NSImage class]]);
}

@end
