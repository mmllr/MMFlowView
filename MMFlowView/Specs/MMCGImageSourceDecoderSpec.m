//
//  MMCGImageSourceDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMCGImageSourceDecoder.h"

SPEC_BEGIN(MMCGImageSourceDecoderSpec)

describe(@"MMCGImageSourceDecoder", ^{
	__block MMCGImageSourceDecoder *sut = nil;
	CGSize desiredSize = {50, 50};
	__block CGImageSourceRef imageSource = NULL;
	__block CGImageRef imageRef = NULL;

	beforeAll(^{
		NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
		imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)(imageURL), NULL);
	});
	afterAll(^{
		if (imageSource) {
			CFRelease(imageSource);
			imageSource = NULL;
		}
	});
	beforeEach(^{
		sut = [[MMCGImageSourceDecoder alloc] init];
	});
	afterEach(^{
		if (imageRef) {
			CGImageRelease(imageRef);
			imageRef = NULL;
		}
		sut = nil;
	});
	it(@"should exist", ^{
		[[sut shouldNot] beNil];
	});
	it(@"should conform to MMImageDecoderProtocol", ^{
		[[sut should] conformToProtocol:@protocol(MMImageDecoderProtocol)];
	});
	it(@"should respond to newImageFromItem:withSize:", ^{
		[[sut should] respondToSelector:@selector(newImageFromItem:withSize:)];
	});
	it(@"should respond to imageFromItem:", ^{
		[[sut should] respondToSelector:@selector(imageFromItem:)];
	});
	context(@"newImageFromItem:withSize:", ^{
		context(@"when created with NSURL and non-zero size", ^{
			beforeEach(^{
				imageRef = [sut newImageFromItem:(__bridge id)imageSource withSize:desiredSize];
			});
			it(@"should load an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
			it(@"should be in the specified size", ^{
				CGFloat width = CGImageGetWidth(imageRef);
				CGFloat height = CGImageGetHeight(imageRef);
				[[theValue(width == desiredSize.width || height == desiredSize.height) should] beTrue];
			});
		});
		context(@"when asking for an image with an invalid item", ^{
			it(@"should not return an image for nil", ^{
				[[theValue([sut newImageFromItem:nil withSize:desiredSize] == NULL) should] beTrue];
			});
			it(@"should not return an image for an item from wrong type", ^{
				[[theValue([sut newImageFromItem:@"Test" withSize:desiredSize] == NULL) should] beTrue];
			});
		});
		context(@"when asking for an image with zero image size", ^{
			beforeEach(^{
				imageRef = [sut newImageFromItem:(__bridge id)imageSource withSize:CGSizeZero];
			});
			it(@"should return an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
		});
	});
	context(@"imageFromItem:", ^{
		context(@"creating an image from a CGImageSourceRef", ^{
			__block NSImage *image = nil;

			beforeEach(^{
				image = [sut imageFromItem:(__bridge id)imageSource];
			});
			afterEach(^{
				image = nil;
			});
			it(@"should return an image", ^{
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
