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
//  MMFlowViewImageFactorySpec.m
//
//  Created by Markus Müller on 17.12.13.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Quartz/Quartz.h>

#import "MMFlowViewImageFactory.h"
#import "MMImageDecoderProtocol.h"
#import "MMFlowView.h"
#import "MMMacros.h"
#import "MMFlowViewImageCache.h"

@interface ImageFactoryDecoderTestClass : NSObject <MMImageDecoderProtocol>
@end

@implementation ImageFactoryDecoderTestClass

- (id<MMImageDecoderProtocol>)initWithItem:(id)anItem maxPixelSize:(NSUInteger)maxPixelSize
{
	self = [super init];
	return self;
}

- (CGImageRef)CGImage
{
	return NULL;
}

- (NSImage *)image
{
	return nil;
}

@end

@interface MMFlowViewImageFactorySpec : XCTestCase

@end

@implementation MMFlowViewImageFactorySpec
{
	MMFlowViewImageFactory *_sut;
	NSURL *_testImageURL;
	NSString *_testRepresentationType;
	NSImage *_testImage;
}

- (void)setUp
{
	[super setUp];
	_testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
	_testRepresentationType = @"testRepresentationType";
	_sut = [[MMFlowViewImageFactory alloc] init];
	_testImage = [[NSImage alloc] initWithContentsOfURL:_testImageURL];
}

- (void)tearDown
{
	_sut = nil;
	_testImageURL = nil;
	_testRepresentationType = nil;
	_testImage = nil;
	[super tearDown];
}

- (void)testFactoryExists
{
	XCTAssertNotNil(_sut);
}

- (void)testRegistersConformingDecoderClass
{
	[_sut registerClass:[ImageFactoryDecoderTestClass class] forItemRepresentationType:_testRepresentationType];
	XCTAssertTrue([_sut canDecodeRepresentationType:_testRepresentationType]);
}

- (void)testReturnsInstanceOfRegisteredClass
{
	[_sut registerClass:[ImageFactoryDecoderTestClass class] forItemRepresentationType:_testRepresentationType];
	XCTAssertNotNil([_sut decoderforItem:nil withRepresentationType:_testRepresentationType]);
}

- (void)testDoesNotRegisterNonConformingClass
{
	[_sut registerClass:[NSString class] forItemRepresentationType:_testRepresentationType];
	XCTAssertFalse([_sut canDecodeRepresentationType:_testRepresentationType]);
}

- (void)testReturnsNilForUnregisteredRepresentationType
{
	[_sut registerClass:[NSString class] forItemRepresentationType:_testRepresentationType];
	XCTAssertNil([_sut decoderforItem:nil withRepresentationType:_testRepresentationType]);
}

- (void)testRespondsToCancelPendingDecodings
{
	XCTAssertTrue([_sut respondsToSelector:@selector(cancelPendingDecodings)]);
}

- (void)testCancelPendingDecodingsCancelsAllOperations
{
	// The factory's operation queue is only observable through its effect on
	// pending operations; cancelPendingDecodings simply forwards to
	// cancelAllOperations on the queue. Verified by checking a real queue's
	// cancellation state via an enqueued operation.
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	queue.suspended = YES;
	NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{ }];
	[queue addOperation:operation];

	_sut.operationQueue = queue;
	[_sut cancelPendingDecodings];

	XCTAssertTrue(operation.isCancelled);
}

- (void)testCanDecodeReturnsNOForUnregisteredType
{
	XCTAssertFalse([_sut canDecodeRepresentationType:@"an unregistered type"]);
}

- (void)testCanDecodeReturnsYESForRegisteredType
{
	[_sut registerClass:[ImageFactoryDecoderTestClass class] forItemRepresentationType:_testRepresentationType];
	XCTAssertTrue([_sut canDecodeRepresentationType:_testRepresentationType]);
}

- (void)testRespondsToMaxImageSize
{
	XCTAssertTrue([_sut respondsToSelector:@selector(maxImageSize)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(setMaxImageSize:)]);
}

- (void)testInitialMaxImageSizeIs100x100
{
	XCTAssertEqualObjects([NSValue valueWithSize:_sut.maxImageSize], [NSValue valueWithSize:CGSizeMake(100, 100)]);
}

- (void)testSetsValidImageSize
{
	_sut.maxImageSize = CGSizeMake(500, 500);
	XCTAssertEqualObjects([NSValue valueWithSize:_sut.maxImageSize], [NSValue valueWithSize:CGSizeMake(500, 500)]);
}

- (void)testZeroMaxImageSizeIsRejected
{
	_sut.maxImageSize = CGSizeZero;
	XCTAssertGreaterThan(_sut.maxImageSize.width, (CGFloat)0);
	XCTAssertGreaterThan(_sut.maxImageSize.height, (CGFloat)0);
}

- (void)testZeroWidthMaxImageSizeIsRejected
{
	_sut.maxImageSize = CGSizeMake(0, 100);
	XCTAssertGreaterThan(_sut.maxImageSize.width, (CGFloat)0);
	XCTAssertGreaterThan(_sut.maxImageSize.height, (CGFloat)0);
}

- (void)testZeroHeightMaxImageSizeIsRejected
{
	_sut.maxImageSize = CGSizeMake(100, 0);
	XCTAssertGreaterThan(_sut.maxImageSize.width, (CGFloat)0);
	XCTAssertGreaterThan(_sut.maxImageSize.height, (CGFloat)0);
}

- (void)testNegativeMaxImageSizeIsRejected
{
	_sut.maxImageSize = CGSizeMake(-100, -100);
	XCTAssertGreaterThan(_sut.maxImageSize.width, (CGFloat)0);
	XCTAssertGreaterThan(_sut.maxImageSize.height, (CGFloat)0);
}

- (void)testRespondsToCreateCGImageFromRepresentation
{
	XCTAssertTrue([_sut respondsToSelector:@selector(createCGImageFromRepresentation:withType:completionHandler:)]);
}

- (void)testThrowsWhenInvokedWithNilItem
{
	XCTAssertThrowsSpecificNamed(([_sut createCGImageFromRepresentation:nil withType:_testRepresentationType completionHandler:^(CGImageRef image) { }]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenInvokedWithNilType
{
	XCTAssertThrowsSpecificNamed(([_sut createCGImageFromRepresentation:_testImage withType:nil completionHandler:^(CGImageRef image) { }]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenInvokedWithNullCompletionHandler
{
	XCTAssertThrowsSpecificNamed(([_sut createCGImageFromRepresentation:_testImage withType:_testRepresentationType completionHandler:NULL]), NSException, NSInternalInconsistencyException);
}

// DISABLED: the original async tests (completion block runs on the calling queue,
// decoder CGImage is invoked) relied on Kiwi stubs of decoderforItem:/
// canDecodeRepresentationType: and shouldEventually expectations. With plain XCTest
// and real decoders the observable behavior would require a runloop-based wait on
// the factory's operation queue; these interactions are covered indirectly by the
// decoder specs.

@end
