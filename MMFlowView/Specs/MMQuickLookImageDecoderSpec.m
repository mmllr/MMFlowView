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
	it(@"should respond to newImageFromItem:withSize:", ^{
		[[sut should] respondToSelector:@selector(newImageFromItem:withSize:)];
	});
	it(@"should respond to imageFromItem:", ^{
		[[sut should] respondToSelector:@selector(imageFromItem:)];
	});
	context(@"newImageFromItem:withSize:", ^{
		it(@"should raise when invoked with nil item", ^{
			[[theBlock(^{
				[sut newImageFromItem:nil withSize:CGSizeZero];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		context(@"when created with NSURL and non-zero size", ^{
			beforeEach(^{
				imageRef = [sut newImageFromItem:testImageURL withSize:desiredSize];
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
		context(@"when asking for an image with zero image size", ^{
			beforeEach(^{
				imageRef = [sut newImageFromItem:testImageURL withSize:CGSizeZero];
			});
			it(@"should return an image", ^{
				[[theValue(imageRef != NULL) should] beTrue];
			});
		});
		context(@"when asking for an image from a string item", ^{
			beforeEach(^{
				imageRef = [sut newImageFromItem:testImageString withSize:desiredSize];
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
			context(@"http urlstring", ^{
				beforeEach(^{
					image = [sut imageFromItem:@"http://images.apple.com/global/elements/flags/22x22/usa.png"];
				});
				it(@"should load an image", ^{
					[[image shouldNot] beNil];
				});
			});
			
		});
	});
});

SPEC_END
