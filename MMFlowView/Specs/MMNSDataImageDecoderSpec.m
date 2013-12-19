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
	CGSize desiredSize = {100, 100};
	__block NSData *imageData = nil;
	__block MMNSDataImageDecoder *sut = nil;
	__block CGImageRef image = NULL;

	beforeAll(^{
		imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/Screen Savers/Default Collections/3-Cosmos/Cosmos01.jpg"]];
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
	it(@"should respond to newImageFromItem:withSize:", ^{
		[[sut should] respondToSelector:@selector(newImageFromItem:withSize:)];
	});
	context(@"when created from NSData and non-zero size", ^{
		beforeEach(^{
			image = [sut newImageFromItem:imageData withSize:desiredSize];
		});
		it(@"should load an image", ^{
			[[theValue(image != NULL) should] beTrue];
		});
		it(@"should be in the specified size", ^{
			CGFloat width = CGImageGetWidth(image);
			CGFloat height = CGImageGetHeight(image);
			[[theValue(width == desiredSize.width || height == desiredSize.height) should] beTrue];
		});
	});
	context(@"when asking for an image with zero image size", ^{
		beforeEach(^{
			image = [sut newImageFromItem:imageData withSize:CGSizeZero];
		});
		it(@"should return an image", ^{
			[[theValue(image != NULL) should] beTrue];
		});
	});
});

SPEC_END
