//
//  MMQuickLookImageDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMQuickLookImageDecoder.h"

SPEC_BEGIN(MMQuickLookImageDecoderSpec)

describe(@"MMQuickLookImageDecoder", ^{
	const NSUInteger desiredSize = 50;
	NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
	NSString *testImageString = [testImageURL path];
	__block MMQuickLookImageDecoder *sut = nil;
	__block CGImageRef imageRef = NULL;
	__block NSImage *image = nil;

	beforeEach(^{
		sut = [[MMQuickLookImageDecoder alloc] init];
	});
	afterEach(^{
		if (imageRef) {
			CGImageRelease(imageRef);
			imageRef = NULL;
		}
		image = nil;
		sut = nil;
	});
	it(@"should exist", ^{
		[[sut shouldNot] beNil];
	});
	it(@"should conform to MMImageDecoderProtocol", ^{
		[[sut should] conformToProtocol:@protocol(MMImageDecoderProtocol)];
	});
	it(@"should respond to newCGImageFromItem", ^{
		[[sut should] respondToSelector:@selector(newCGImageFromItem:)];
	});
	it(@"should respond to imageFromItem:", ^{
		[[sut should] respondToSelector:@selector(imageFromItem:)];
	});
	it(@"should have a maxPixelSize of zero", ^{
		[[theValue(sut.maxPixelSize) should] beZero];
	});
	context(@"newCGImageFromItem:", ^{
		it(@"should raise when invoked with nil item", ^{
			[[theBlock(^{
				[sut newCGImageFromItem:nil];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		context(@"when created with NSURL", ^{
			beforeEach(^{
				sut.maxPixelSize = desiredSize;
				imageRef = [sut newCGImageFromItem:testImageURL];
			});
			it(@"should load an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
			it(@"should be in the specified size", ^{
				CGFloat width = CGImageGetWidth(imageRef);
				CGFloat height = CGImageGetHeight(imageRef);
				[[theValue(width == desiredSize || height == desiredSize) should] beTrue];
			});
		});
		context(@"when asking for an image with zero pixel size", ^{
			beforeEach(^{
				sut.maxPixelSize = 0;
				imageRef = [sut newCGImageFromItem:testImageURL];
			});
			it(@"should return an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
			it(@"should have a width less or equal than 4000 points", ^{
				[[theValue(CGImageGetWidth(imageRef)) should] beLessThanOrEqualTo:theValue(4000)];
			});
			it(@"should have a height less or equal than 4000 points", ^{
				[[theValue(CGImageGetHeight(imageRef)) should] beLessThanOrEqualTo:theValue(4000)];
			});
		});
		context(@"when asking for an image from a string item", ^{
			beforeEach(^{
				sut.maxPixelSize = desiredSize;
				imageRef = [sut newCGImageFromItem:testImageString];
			});
			it(@"should return an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
		});
	});
	context(@"imageFromItem:", ^{
		context(@"when created with NSURL", ^{
			beforeEach(^{
				image = [sut imageFromItem:testImageURL];
			});
			it(@"should load an image", ^{
				[[image shouldNot] beNil];
			});
		});
		context(@"when created with NSString", ^{
			context(@"filepath", ^{
				beforeEach(^{
					image = [sut imageFromItem:testImageString];
				});
				it(@"should load an image", ^{
					[[image shouldNot] beNil];
				});
				it(@"should return an NSImage", ^{
					[[image should] beKindOfClass:[NSImage class]];
				});
			});
		});
	});
});

SPEC_END
