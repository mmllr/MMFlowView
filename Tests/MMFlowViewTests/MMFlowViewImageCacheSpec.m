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
//  MMFlowViewImageCacheSpec.m
//
//  Created by Markus Müller on 02.01.14.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MMTestFixtures.h"

#import <QuickLook/QuickLook.h>

#import "MMFlowViewImageCache.h"
#import "MMFlowView.h"
#import "MMMacros.h"

@interface MMFlowViewImageCacheSpec : XCTestCase

@end

@implementation MMFlowViewImageCacheSpec
{
	MMFlowViewImageCache *_sut;
	CGImageRef _testImageRef;
}

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowViewImageCache alloc] init];
	NSURL *imageURL = MMTestFixtureURL(@"TestImage01", @"jpg");
	NSDictionary *quickLookOptions = @{(id)kQLThumbnailOptionIconModeKey: (id)kCFBooleanFalse};
	_testImageRef = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)(imageURL), CGSizeMake(400, 400), (__bridge CFDictionaryRef)quickLookOptions);
}

- (void)tearDown
{
	_sut = nil;
	SAFE_CGIMAGE_RELEASE(_testImageRef);
	[super tearDown];
}

- (void)testNewInstanceExists
{
	XCTAssertNotNil(_sut);
}

- (void)testConformsToImageCacheProtocol
{
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMFlowViewImageCache)]);
}

- (void)testRespondsToCacheAndRetrieveSelectors
{
	XCTAssertTrue([_sut respondsToSelector:@selector(cacheImage:withUUID:)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(imageForUUID:)]);
}

- (void)testCachedItemsCanBeRetrieved
{
	[_sut cacheImage:_testImageRef withUUID:@"item1"];
	[_sut cacheImage:_testImageRef withUUID:@"item2"];
	[_sut cacheImage:_testImageRef withUUID:@"item3"];

	NSArray *expectedUUIDs = @[@"item1", @"item2", @"item3"];
	for (NSString *itemID in expectedUUIDs) {
		CGImageRef cachedImage = [_sut imageForUUID:itemID];
		XCTAssertTrue(cachedImage != NULL);
	}
}

- (void)testReturnsTheCachedImage
{
	[_sut cacheImage:_testImageRef withUUID:@"item1"];
	XCTAssertTrue([_sut imageForUUID:@"item1"] == _testImageRef);
}

- (void)testReturnsSameImageWhenAskedRepeatedly
{
	[_sut cacheImage:_testImageRef withUUID:@"item1"];
	for (int i = 0; i < 5; ++i) {
		XCTAssertTrue([_sut imageForUUID:@"item1"] == _testImageRef);
	}
}

- (void)testRemovedItemIsNoLongerCached
{
	[_sut cacheImage:_testImageRef withUUID:@"item1"];
	[_sut cacheImage:_testImageRef withUUID:@"item2"];
	[_sut removeImageWithUUID:@"item2"];
	XCTAssertTrue([_sut imageForUUID:@"item2"] == NULL);
}

- (void)testResetEmptiesTheCache
{
	[_sut cacheImage:_testImageRef withUUID:@"item1"];
	[_sut reset];
	XCTAssertTrue([_sut imageForUUID:@"item1"] == NULL);
}

- (void)testReturnsNullForItemNotInCache
{
	XCTAssertTrue([_sut imageForUUID:@"an item not in cache"] == NULL);
}

- (void)testDoesNotThrowWhenAskedForNilUUID
{
	XCTAssertNoThrow([_sut imageForUUID:nil]);
}

@end
