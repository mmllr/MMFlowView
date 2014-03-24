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
//  MMFlowViewImageFactorySpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 19.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"

#import <Quartz/Quartz.h>

#import "MMFlowViewImageFactory.h"
#import "MMImageDecoderProtocol.h"
#import "MMFlowView.h"
#import "MMMacros.h"
#import "MMFlowViewImageCache.h"


@interface ImageFactoreyDecoderTestClass : NSObject<MMImageDecoderProtocol>

@end

@implementation ImageFactoreyDecoderTestClass

- (id<MMImageDecoderProtocol>)initWithItem:(id)anItem maxPixelSize:(NSUInteger)maxPixelSize
{
	self = [super init];
	return self;
}

- (CGImageRef)CGImage
{
	return NULL;
}

- (NSImage*)image
{
	return nil;
}

@end

SPEC_BEGIN(MMFlowViewImageFactorySpec)

describe(@"MMFlowViewImageFactory", ^{
	NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
	NSString *testRepresentationType = @"testRepresentationType";
	__block MMFlowViewImageFactory *sut = nil;
	__block NSImage *testImage = nil;
	__block id itemMock = nil;
	__block CGImageRef testImageRef = NULL;
	__block id decoderMock = nil;

	beforeAll(^{
		testImage = [[NSImage alloc] initWithContentsOfURL:testImageURL];
		testImageRef = CGImageRetain([testImage CGImageForProposedRect:NULL
															   context:NULL
																 hints:nil]);
	});
	afterAll(^{
		testImage = nil;
		itemMock = nil;
	});

	beforeEach(^{
		sut = [[MMFlowViewImageFactory alloc] init];
		itemMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewItem)];
		[itemMock stub:@selector(imageItemRepresentationType) andReturn:testRepresentationType];
		[itemMock stub:@selector(imageItemRepresentation) andReturn:testImage];
		decoderMock = [KWMock nullMockForProtocol:@protocol(MMImageDecoderProtocol)];
	});
	afterEach(^{
		sut = nil;
		itemMock = nil;
		decoderMock = nil;
	});

	it(@"should exist", ^{
		[[sut shouldNot] beNil];
	});

	context(NSStringFromSelector(@selector(registerClass:forItemRepresentationType:)), ^{
		context(@"when registering a class which conforms to MMImageDecoderProtocol", ^{
			beforeEach(^{
				[sut registerClass:[ImageFactoreyDecoderTestClass class]
		 forItemRepresentationType:testRepresentationType];
			});
			it(@"should register a MMIageDecoderProtocol conforming class", ^{
				[[theValue([sut canDecodeRepresentationType:@"testRepresentationType"]) should] beYes];
			});
			it(@"should return an instance of the registered class", ^{
				[[(id)[sut decoderforItem:[KWNull null] withRepresentationType:testRepresentationType] shouldNot] beNil];
			});
		});

		context(@"when registering a class which does not conform to MMImageDecoderProtocol", ^{
			beforeEach(^{
				[sut registerClass:[NSString class] forItemRepresentationType:testRepresentationType];
			});
			it(@"should not register a class which does not conform to the MMImageDecoderProtocol protocol", ^{
				[[theValue([sut canDecodeRepresentationType:testRepresentationType]) should] beNo];
			});
			it(@"should return nil when asking for the decoder", ^{
				[[(id)[sut decoderforItem:[KWNull null] withRepresentationType:testRepresentationType] should] beNil];
			});
		});
		
	});

	context(NSStringFromSelector(@selector(cancelPendingDecodings)), ^{
		it(@"should respond to the stop selector", ^{
			[[sut should] respondToSelector:@selector(cancelPendingDecodings)];
		});
		it(@"should cancel all operations on its operation queue when stop is invoked", ^{
			NSOperationQueue *mockedOperationQueue = [NSOperationQueue nullMock];
			sut.operationQueue = mockedOperationQueue;

			[[mockedOperationQueue should] receive:@selector(cancelAllOperations)];

			[sut cancelPendingDecodings];
		});
	});

	context(NSStringFromSelector(@selector(canDecodeRepresentationType:)), ^{
		it(@"should return NO for an unregistered representation type", ^{
			[[theValue([sut canDecodeRepresentationType:@"an unregistered type"]) should] beNo];
		});
		it(@"should return YES for an registered representation type", ^{
			[sut registerClass:[ImageFactoreyDecoderTestClass class] forItemRepresentationType:testRepresentationType];

			[[theValue([sut canDecodeRepresentationType:testRepresentationType]) should] beYes];
		});
	});
	
	context(NSStringFromSelector(@selector(maxImageSize)), ^{
		it(@"should respond to maxImageSize", ^{
			[[sut should] respondToSelector:@selector(maxImageSize)];
		});
		it(@"should respond to setMaxImageSize:", ^{
			[[sut should] respondToSelector:@selector(setMaxImageSize:)];
		});
		it(@"should have a initial maxImageSize of {100,100}", ^{
			NSValue *expectedSize = [NSValue valueWithSize:CGSizeMake(100, 100)];
			[[[NSValue valueWithSize:sut.maxImageSize] should] equal:expectedSize];
		});
		it(@"should set a valid image size", ^{
			sut.maxImageSize = CGSizeMake(500, 500);
			NSValue *expectedSize = [NSValue valueWithSize:CGSizeMake(500, 500)];
			[[[NSValue valueWithSize:sut.maxImageSize] should] equal:expectedSize];
		});
		context(@"when setting an CGSizeZero maxImageSize", ^{
			beforeEach(^{
				sut.maxImageSize = CGSizeZero;
			});
			it(@"should have a maxImageSize width greater than zero", ^{
				[[theValue(sut.maxImageSize.width) should] beGreaterThan:theValue(0)];
			});
			it(@"should have a maxImageSize height greater than zero", ^{
				[[theValue(sut.maxImageSize.height) should] beGreaterThan:theValue(0)];
			});
		});
		context(@"when setting an maxImageSize with its width equal to 0", ^{
			beforeEach(^{
				sut.maxImageSize = CGSizeMake(0, 100);
			});
			it(@"should have a maxImageSize width greater than zero", ^{
				[[theValue(sut.maxImageSize.width) should] beGreaterThan:theValue(0)];
			});
			it(@"should have a maxImageSize height greater than zero", ^{
				[[theValue(sut.maxImageSize.height) should] beGreaterThan:theValue(0)];
			});
		});
		context(@"when setting an maxImageSize with its height equal to 0", ^{
			beforeEach(^{
				sut.maxImageSize = CGSizeMake(100, 0);
			});
			it(@"should have a maxImageSize width greater than zero", ^{
				[[theValue(sut.maxImageSize.width) should] beGreaterThan:theValue(0)];
			});
			it(@"should have a maxImageSize height greater than zero", ^{
				[[theValue(sut.maxImageSize.height) should] beGreaterThan:theValue(0)];
			});
		});
		context(@"when setting an maxImageSize negative values", ^{
			beforeEach(^{
				sut.maxImageSize = CGSizeMake(-100, -100);
			});
			it(@"should have a maxImageSize width greater than zero", ^{
				[[theValue(sut.maxImageSize.width) should] beGreaterThan:theValue(0)];
			});
			it(@"should have a maxImageSize height greater than zero", ^{
				[[theValue(sut.maxImageSize.height) should] beGreaterThan:theValue(0)];
			});
		});
	});
	context(NSStringFromSelector(@selector(createCGImageFromRepresentation:withType:completionHandler:)), ^{
		beforeEach(^{
			[sut stub:@selector(decoderforItem:withRepresentationType:) andReturn:decoderMock withArguments:[KWAny any], testRepresentationType];
			[sut stub:@selector(canDecodeRepresentationType:) andReturn:theValue(YES) withArguments:testRepresentationType];
		});
		it(@"should respond to createCGImageFromRepresentation:withType:completionHandler:", ^{
			[[sut should] respondToSelector:@selector(createCGImageFromRepresentation:withType:completionHandler:)];
		});
		it(@"should throw an NSInternalInconsistencyException when invoked with a nil item", ^{
			[[theBlock(^{
				[sut createCGImageFromRepresentation:nil withType:testRepresentationType completionHandler:^(CGImageRef image){
				}];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		it(@"should throw an NSInternalInconsistencyException when invoked with a nil type", ^{
			[[theBlock(^{
				[sut createCGImageFromRepresentation:testImage withType:nil completionHandler:^(CGImageRef image){
				}];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		it(@"should throw an NSInternalInconsistencyException when invoked with a NULL completetionHandler", ^{
			[[theBlock(^{
				[sut createCGImageFromRepresentation:testImage withType:testRepresentationType completionHandler:NULL];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		it(@"should invoke the completionBlock on the same thread as the caller", ^{
			NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
			__block NSOperationQueue *queueOnCompletionBlock = nil;
			[decoderMock stub:@selector(CGImage) andReturn:(__bridge id)(testImageRef)];

			[sut createCGImageFromRepresentation:testImage withType:testRepresentationType completionHandler:^(CGImageRef image) {
				queueOnCompletionBlock = [NSOperationQueue currentQueue];
			}];
			[[expectFutureValue(queueOnCompletionBlock) shouldEventually] equal:currentQueue];
		});
		context(@"interaction with image decoder", ^{
			it(@"should send the decoder CGImage:", ^{
				[[decoderMock shouldEventually] receive:@selector(CGImage)];

				[sut createCGImageFromRepresentation:testImage withType:testRepresentationType completionHandler:^(CGImageRef image) {
				}];
			});
		});
	});
});

SPEC_END
