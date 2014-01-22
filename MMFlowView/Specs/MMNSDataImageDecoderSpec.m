//
//  MMNSDataImageDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 19.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMNSDataImageDecoder.h"
#import "MMMacros.h"

SPEC_BEGIN(MMNSDataImageDecoderSpec)

describe(@"MMNSDataImageDecoder", ^{
	__block NSData *imageData = nil;
	__block MMNSDataImageDecoder *sut = nil;
	__block CGImageRef imageRef = NULL;

	beforeAll(^{
		imageData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"]];
	});
	afterAll(^{
		imageData = nil;
	});
	beforeEach(^{
		sut = [[MMNSDataImageDecoder alloc] init];
	});
	afterEach(^{
		sut = nil;
	});
	afterAll(^{
		SAFE_CGIMAGE_RELEASE(imageRef)
	});
	it(@"should exist", ^{
		[[sut shouldNot] beNil];
	});
	it(@"should conform to MMImageDecoderProtocol", ^{
		[[sut should] conformToProtocol:@protocol(MMImageDecoderProtocol)];
	});
	it(@"should respond to newCGImageFromItem:", ^{
		[[sut should] respondToSelector:@selector(newCGImageFromItem:)];
	});
	it(@"should respond to imageFromItem:", ^{
		[[sut should] respondToSelector:@selector(imageFromItem:)];
	});
	it(@"should have a maxPixelSize of zero", ^{
		[[theValue(sut.maxPixelSize) should] beZero];
	});
	context(@"newCGImageFromItem:", ^{
		context(@"when created from NSData and a maxPixelSize of 100", ^{
			beforeAll(^{
				sut.maxPixelSize = 100;
				imageRef = [sut newCGImageFromItem:imageData];
			});
			afterAll(^{
				SAFE_CGIMAGE_RELEASE(imageRef)
			});
			it(@"should load an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
			it(@"should have a width less or equal 100", ^{
				[[theValue(CGImageGetWidth(imageRef)) should] beLessThanOrEqualTo:theValue(100)];
			});
			it(@"should have a height less or equal 100", ^{
				[[theValue(CGImageGetHeight(imageRef)) should] beLessThanOrEqualTo:theValue(100)];
			});
		});
		context(@"when asking for an image with zero image size", ^{
			beforeAll(^{
				sut.maxPixelSize = 0;
				imageRef = [sut newCGImageFromItem:imageData];
			});
			afterAll(^{
				SAFE_CGIMAGE_RELEASE(imageRef)
			});
			it(@"should return an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
		});
	});
	context(@"imageFromItem:", ^{
		__block NSImage *image = nil;

		context(@"loading from an NSData object", ^{
			beforeAll(^{
				image = [sut imageFromItem:imageData];
			});
			afterAll(^{
				image = nil;
			});
			it(@"should load an image", ^{
				[[image shouldNot] beNil];
			});
			it(@"should return an NSImage", ^{
				[[image should] beKindOfClass:[NSImage class]];
			});
		});
		context(@"when asking for an image with an invalid item", ^{
			it(@"should not return an image for nil", ^{
				[[[sut imageFromItem:nil] should] beNil];
			});
			it(@"should not return an image for an item from wrong type", ^{
				[[[sut imageFromItem:@"Test"] should] beNil];
			});
		});
	});
});

SPEC_END
