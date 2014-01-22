//
//  MMNSBitmapImageRepDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMNSBitmapImageRepDecoder.h"
#import "MMMacros.h"

SPEC_BEGIN(MMNSBitmapImageRepDecoderSpec)

describe(@"MMNSBitmapImageRepDecoder", ^{
	__block MMNSBitmapImageRepDecoder *sut = nil;
	__block CGImageRef imageRef = NULL;
	__block NSBitmapImageRep *imageRep = nil;

	beforeAll(^{
		NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
		NSImage *image = [[NSImage alloc] initWithContentsOfURL:testImageURL];

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
	context(@"a new instance", ^{
		beforeEach(^{
			sut = [[MMNSBitmapImageRepDecoder alloc] init];
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
		context(@"setting the maxPixelSize to 100", ^{
			beforeEach(^{
				sut.maxPixelSize = 100;
			});
			it(@"should have a maxPixelSize of 100", ^{
				[[theValue(sut.maxPixelSize) should] equal:theValue(100)];
			});
			context(@"newCGImageFromItem:", ^{
				context(@"creating images from a NSBitmapImageRep", ^{
					beforeAll(^{
						imageRef = [sut newCGImageFromItem:imageRep];
					});
					afterAll(^{
						SAFE_CGIMAGE_RELEASE(imageRef)
					});
					it(@"should create an image", ^{
						[[theValue(imageRef != NULL) should] beTrue];
					});
					it(@"should have a width less or equal 100", ^{
						[[theValue(CGImageGetWidth(imageRef)) should] beLessThanOrEqualTo:theValue(100)];
					});
					it(@"should have a height less or equal 100", ^{
						[[theValue(CGImageGetHeight(imageRef)) should] beLessThanOrEqualTo:theValue(100)];
					});
				});
				context(@"asking for image with an invalid item", ^{
					it(@"should not return an image from nil", ^{
						[[theValue([sut newCGImageFromItem:nil] == NULL) should] beTrue];
					});
					it(@"should not return an image from a non NSBitmapImageRep", ^{
						[[theValue([sut newCGImageFromItem:@"String"] == NULL) should] beTrue];
					});
				});
				context(@"when asking for an image with zero image size", ^{
					beforeAll(^{
						imageRef = [sut newCGImageFromItem:imageRep];
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
				context(@"creating an image from a NSBitmapImageRep", ^{
					__block NSImage *image = nil;
					beforeAll(^{
						image = [sut imageFromItem:imageRep];
					});
					afterAll(^{
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
	});
});

SPEC_END
