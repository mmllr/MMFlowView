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
	CGSize desiredSize = {50, 50};
	NSString *imageString = @"/Library/Screen Savers/Default Collections/3-Cosmos/Cosmos01.jpg";
	NSURL *imageURL = [NSURL fileURLWithPath:imageString];
	__block MMQuickLookImageDecoder *sut = nil;
	__block CGImageRef image = NULL;

	beforeEach(^{
		sut = [[MMQuickLookImageDecoder alloc] init];
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
	context(@"when created with NSURL and non-zero size", ^{
		beforeEach(^{
			image = [sut newImageFromItem:imageURL withSize:desiredSize];
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
	context(@"when created with an CFURLRef and non-zero size", ^{
		__block CFURLRef urlRef = NULL;
		beforeEach(^{
			urlRef = CFURLCreateWithFileSystemPath(NULL, (__bridge CFStringRef)(imageString), kCFURLPOSIXPathStyle, false);
			image = [sut newImageFromItem:(__bridge id)urlRef withSize:desiredSize];
		});
		afterEach(^{
			if ( urlRef ) {
				CFRelease(urlRef);
				urlRef = NULL;
			}
		});
		it(@"should create an image", ^{
			[[theValue(image != NULL) should] beTrue];
		});
	});
	context(@"when asking for an image with zero image size", ^{
		beforeEach(^{
			image = [sut newImageFromItem:imageURL withSize:CGSizeZero];
		});
		it(@"should return an image", ^{
			[[theValue(image != NULL) should] beTrue];
		});
	});
	context(@"when asking for an image from a string item", ^{
		beforeEach(^{
			image = [sut newImageFromItem:imageString withSize:desiredSize];
		});
		it(@"should return an image", ^{
			[[theValue(image != NULL) should] beTrue];
		});
	});
});

SPEC_END
