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
	__block CGImageRef image = NULL;

	beforeEach(^{
		sut = [[MMNSImageDecoder alloc] init];
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
	context(@"when created with an NSImage and non-zero size", ^{
		beforeEach(^{
			image = [sut newImageFromItem:[NSImage imageNamed:NSImageNameUser] withSize:desiredSize];
		});
		it(@"should load an image", ^{
			[[theValue(image != NULL) should] beTrue];
		});
	});
	context(@"when not invoked with an NSImage", ^{
		beforeEach(^{
			image = [sut newImageFromItem:@"Test" withSize:desiredSize];
		});
		it(@"should not return an image", ^{
			[[theValue(image == NULL) should] beTrue];
		});
	});
});

SPEC_END
