//
//  MMNSBitmapImageRepDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMNSBitmapImageRepDecoder.h"

SPEC_BEGIN(MMNSBitmapImageRepDecoderSpec)

describe(@"MMNSBitmapImageRepDecoder", ^{
	__block MMNSBitmapImageRepDecoder *sut = nil;
	__block CGImageRef image = NULL;
	__block NSBitmapImageRep *imageRep = nil;
	const CGSize desiredSize = {50, 50};

	beforeAll(^{
		NSString *imageString = @"/Library/Screen Savers/Default Collections/3-Cosmos/Cosmos01.jpg";
		NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:imageString]];

		for ( NSImageRep* rep in [image representations] ) {
			if ([rep isKindOfClass:[NSBitmapImageRep class]] ) {
				imageRep = [(NSBitmapImageRep*)rep copy];
				break;
			}
		}
	});
	afterAll(^{
		imageRep = nil;
	});
	beforeEach(^{
		sut = [[MMNSBitmapImageRepDecoder alloc] init];
	});
	afterEach(^{
		sut = nil;
		if (image) {
			CGImageRelease(image);
			image = NULL;
		}
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
		context(@"creating images from a NSBitmapImageRep", ^{
			beforeEach(^{
				image = [sut newImageFromItem:imageRep withSize:desiredSize];
			});
			it(@"should create an image", ^{
				[[theValue(image != NULL) should] beTrue];
			});
		});
		context(@"asking for image with an invalid item", ^{
			it(@"should not return an image from nil", ^{
				[[theValue([sut newImageFromItem:nil withSize:desiredSize] == NULL) should] beTrue];
			});
			it(@"should not return an image from a non NSBitmapImageRep", ^{
				[[theValue([sut newImageFromItem:@"String" withSize:desiredSize] == NULL) should] beTrue];
			});
		});
		context(@"when asking for an image with zero image size", ^{
			beforeEach(^{
				image = [sut newImageFromItem:imageRep withSize:CGSizeZero];
			});
			it(@"should return an image", ^{
				[[theValue(image != NULL) should] beTrue];
			});
		});
	});
	context(@"imageFromItem:", ^{
		context(@"creating an image from a NSBitmapImageRep", ^{
			__block NSImage *image = nil;
			beforeEach(^{
				image = [sut imageFromItem:imageRep];
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
			it(@"should contain the bitmapRef in its representations", ^{
				[[[image representations] should] contain:imageRep];
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
