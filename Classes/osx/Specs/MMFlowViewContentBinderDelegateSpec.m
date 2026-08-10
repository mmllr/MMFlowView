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
//  MMFlowViewContentBinderDelegateSpec.m
//
//  Created by Markus Müller on 03.04.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+MMFlowViewContentBinderDelegate.h"
#import "MMFlowViewContentBinder.h"
#import "MMFlowViewImageCache.h"
#import "MMTestImageItem.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewContentBinderDelegateSpec : XCTestCase

@end

@implementation MMFlowViewContentBinderDelegateSpec
{
	MMFlowViewRecordingSubclass *_sut;
	MMFlowViewContentBinder *_contentBinder;
	NSArrayController *_controller;
}

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowViewRecordingSubclass alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];

	NSMutableArray *items = [NSMutableArray array];
	for (NSUInteger i = 0; i < 2; i++) {
		MMTestImageItem *item = [[MMTestImageItem alloc] init];
		item.imageItemUID = [NSString stringWithFormat:@"%lu", (unsigned long)i];
		item.imageItemRepresentationType = kMMFlowViewPathRepresentationType;
		[items addObject:item];
	}
	_controller = [[NSArrayController alloc] init];
	_controller.objectClass = [MMTestImageItem class];
	_controller.content = items;
	_contentBinder = [[MMFlowViewContentBinder alloc] initWithArrayController:_controller withContentArrayKeyPath:@"arrangedObjects"];
	[_contentBinder startObservingContent];
}

- (void)tearDown
{
	[_contentBinder stopObservingContent];
	_contentBinder = nil;
	_controller = nil;
	_sut = nil;
	[super tearDown];
}

- (void)testConformsToContentBinderDelegateProtocol
{
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMFlowViewContentBinderDelegate)]);
}

- (void)testRespondsToContentArrayDidChange
{
	XCTAssertTrue([_sut respondsToSelector:@selector(contentArrayDidChange:)]);
}

- (void)testRespondsToContentBinderItemChanged
{
	XCTAssertTrue([_sut respondsToSelector:@selector(contentBinder:itemChanged:)]);
}

- (void)testContentArrayDidChangeReloadsTheContent
{
	NSUInteger before = _sut.reloadContentCallCount;
	[_sut contentArrayDidChange:_contentBinder];
	XCTAssertGreaterThan(_sut.reloadContentCallCount, before);
}

- (void)testContentArrayDidChangeSetsContentAdapterToObservedItems
{
	[_sut contentArrayDidChange:_contentBinder];
	XCTAssertEqualObjects(_sut.contentAdapter, _contentBinder.observedItems);
}

- (void)testContentBinderItemChangedRemovesImageFromCache
{
	MMTestImageItem *item = [[MMTestImageItem alloc] init];
	item.imageItemUID = @"testUID";

	MMTestImageCache *imageCache = [[MMTestImageCache alloc] init];
	CGImageRef testImageRef = NULL;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGContextRef context = CGBitmapContextCreate(NULL, 10, 10, 8, 10 * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
	testImageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);

	[imageCache cacheImage:testImageRef withUUID:@"testUID"];
	_sut.imageCache = imageCache;

	MMCoverFlowLayerRecordingSubclass *coverFlowLayer = [[MMCoverFlowLayerRecordingSubclass alloc] initWithLayout:[[MMCoverFlowLayout alloc] init]];
	_sut.coverFlowLayer = coverFlowLayer;

	[_sut contentBinder:_contentBinder itemChanged:item];

	XCTAssertTrue([imageCache imageForUUID:@"testUID"] == NULL);
	XCTAssertGreaterThan(coverFlowLayer.setNeedsLayoutCallCount, (NSUInteger)0);
	CGImageRelease(testImageRef);
}

@end
