//
//  MMNSDataImageDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 19.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMNSDataImageDecoder.h"

SPEC_BEGIN(MMNSDataImageDecoderSpec)

describe(@"MMNSDataImageDecoder", ^{
	const NSUInteger desiredSize = 100;
	__block NSData *imageData = nil;
	__block MMNSDataImageDecoder *sut = nil;
	__block CGImageRef image = NULL;

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
		if (image) {
			CGImageRelease(image);
			image = NULL;
		}
		sut = nil;
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
		context(@"when created from NSData and non-zero size", ^{
			beforeEach(^{
				sut.maxPixelSize = desiredSize;
				image = [sut newCGImageFromItem:imageData];
			});
			it(@"should load an image", ^{
				[[theValue(image != NULL) should] beTrue];
			});
			it(@"should be in the specified size", ^{
				CGFloat width = CGImageGetWidth(image);
				CGFloat height = CGImageGetHeight(image);
				[[theValue(width == desiredSize || height == desiredSize) should] beTrue];
			});
		});
		context(@"when asking for an image with zero image size", ^{
			beforeEach(^{
				image = [sut newCGImageFromItem:imageData];
			});
			it(@"should return an image", ^{
				[[theValue(image != NULL) should] beTrue];
			});
		});
	});
	context(@"imageFromItem:", ^{
		__block NSImage *image = nil;

		afterEach(^{
			image = nil;
		});
		context(@"loading from an NSData object", ^{
			beforeEach(^{
				image = [sut imageFromItem:imageData];
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
