//
//  MMNSImageDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMNSImageDecoder.h"

SPEC_BEGIN(MMNSImageDecoderSpec)

describe(@"MMNSImageDecoder", ^{
	__block MMNSImageDecoder *sut = nil;
	CGSize desiredSize = {50, 50};
	__block CGImageRef imageRef = NULL;

	beforeEach(^{
		sut = [[MMNSImageDecoder alloc] init];
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
		context(@"when created with an NSImage and non-zero size", ^{
			beforeEach(^{
				imageRef = [sut newImageFromItem:[NSImage imageNamed:NSImageNameUser] withSize:desiredSize];
			});
			it(@"should load an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
		});
		context(@"when not invoked with an NSImage", ^{
			beforeEach(^{
				imageRef = [sut newImageFromItem:@"Test" withSize:desiredSize];
			});
			it(@"should not return an image", ^{
				[[theValue(imageRef == NULL) should] beTrue];
			});
		});
	});
	context(@"imageFromItem:", ^{
		__block NSImage *image = nil;

		context(@"when created with an NSImage", ^{
			beforeEach(^{
				image = [sut imageFromItem:[NSImage imageNamed:NSImageNameUser]];
			});
			afterEach(^{
				image = nil;
			});
			it(@"should load an image", ^{
				[[image should] equal:[NSImage imageNamed:NSImageNameUser]];
			});
		});
		context(@"when not invoked with an NSImage", ^{
			it(@"should not return an image", ^{
				[[[sut imageFromItem:@"Test"] should] beNil];
			});
		});
	});
	
});

SPEC_END
