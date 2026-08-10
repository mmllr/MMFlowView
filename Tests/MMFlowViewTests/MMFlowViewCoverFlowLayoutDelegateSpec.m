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
//  MMFlowViewCoverFlowLayoutDelegateSpec.m
//
//  Created by Markus Müller on 23.10.13.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+MMCoverFlowLayoutDelegate.h"
#import "MMFlowViewImageCache.h"
#import "MMTestImageItem.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewCoverFlowLayoutDelegateSpec : XCTestCase

@end

@implementation MMFlowViewCoverFlowLayoutDelegateSpec
{
	MMFlowView *_sut;
	MMTestContentAdapter *_contentAdapter;
	MMTestImageCache *_imageCache;
	CGImageRef _testImageRef;
}

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];

	MMTestImageItem *item = [[MMTestImageItem alloc] init];
	item.imageItemUID = @"testUID";
	item.imageItemRepresentationType = kMMFlowViewPathRepresentationType;
	_contentAdapter = [[MMTestContentAdapter alloc] initWithItems:@[item]];
	_sut.contentAdapter = _contentAdapter;

	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGContextRef context = CGBitmapContextCreate(NULL, 20, 10, 8, 20 * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
	_testImageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);

	_imageCache = [[MMTestImageCache alloc] init];
	_sut.imageCache = _imageCache;
}

- (void)tearDown
{
	_sut = nil;
	_contentAdapter = nil;
	_imageCache = nil;
	CGImageRelease(_testImageRef);
	_testImageRef = NULL;
	[super tearDown];
}

- (void)testRespondsToAspectRatioSelector
{
	XCTAssertTrue([_sut respondsToSelector:@selector(coverFLowLayout:aspectRatioForItem:)]);
}

- (void)testAsksImageCacheForTheItem
{
	[_imageCache cacheImage:_testImageRef withUUID:@"testUID"];
	[_sut coverFLowLayout:_sut.coverFlowLayout aspectRatioForItem:0];
	XCTAssertNotNil(_imageCache.cachedImages[@"testUID"]);
}

- (void)testReturnsOneWhenNoImageInCache
{
	CGFloat ratio = [_sut coverFLowLayout:_sut.coverFlowLayout aspectRatioForItem:0];
	XCTAssertEqualWithAccuracy(ratio, 1, 0.0000001);
}

- (void)testReturnsAspectRatioOfCachedImage
{
	[_imageCache cacheImage:_testImageRef withUUID:@"testUID"];
	CGFloat expectedAspectRatio = (CGFloat)CGImageGetWidth(_testImageRef) / (CGFloat)CGImageGetHeight(_testImageRef);
	CGFloat ratio = [_sut coverFLowLayout:_sut.coverFlowLayout aspectRatioForItem:0];
	XCTAssertEqualWithAccuracy(ratio, expectedAspectRatio, 0.0000001);
}

@end
