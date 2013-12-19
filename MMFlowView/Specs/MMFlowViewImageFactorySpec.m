//
//  MMFlowViewImageFactorySpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 19.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"

#import <Quartz/Quartz.h>

#import "MMFlowViewImageFactory.h"
#import "MMFlowView.h"

SPEC_BEGIN(MMFlowViewImageFactorySpec)

describe(@"MMFlowViewImageFactory", ^{
	NSString *imageString = @"/Library/Screen Savers/Default Collections/3-Cosmos/Cosmos01.jpg";
	NSURL *imageURL = [NSURL fileURLWithPath:imageString];
	const CGSize maximumImageSize = {100, 100};
	__block MMFlowViewImageFactory *sut = nil;
	__block NSImage *image = nil;
	__block NSBitmapImageRep *imageRep = nil;

	beforeAll(^{
		image = [[NSImage alloc] initWithContentsOfURL:imageURL];
		for ( NSImageRep* rep in [image representations] ) {
			if ([rep isKindOfClass:[NSBitmapImageRep class]] ) {
				imageRep = (NSBitmapImageRep*)rep;
				break;
			}
		}
	});
	afterAll(^{
		imageRep = nil;
		image = nil;
	});
	
	beforeEach(^{
		sut = [[MMFlowViewImageFactory alloc] init];
	});
	afterEach(^{
		sut = nil;
	});

	it(@"should exist", ^{
		[[sut shouldNot] beNil];
	});
	context(@"createImageForItem:withRepresentationType:maximumSize:completionHandler:", ^{
		it(@"should throw an exception when invoked with a NULL completetionHandler", ^{
			[[theBlock(^{
				[sut createImageForItem:imageURL withRepresentationType:kMMFlowViewQuickLookPathRepresentationType maximumSize:maximumImageSize completionHandler:NULL];
			}) should] raise];
		});
	});
	context(@"kMMFlowViewQuickLookPathRepresentationType", ^{
		it(@"should handle kMMFlowViewQuickLookPathRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewQuickLookPathRepresentationType]) should] beYes];
		});

		it(@"should asynchronously load an image from an NSURL", ^{
			__block CGImageRef quickLookImage = NULL;

			[sut createImageForItem:imageURL withRepresentationType:kMMFlowViewQuickLookPathRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				quickLookImage = image;
			}];
			[[expectFutureValue(theValue(quickLookImage != NULL)) shouldEventually] beTrue];
		});

		it(@"should asynchronously load an image from an NSString", ^{
			__block CGImageRef quickLookImage = NULL;

			[sut createImageForItem:imageString withRepresentationType:kMMFlowViewQuickLookPathRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				quickLookImage = image;
			}];
			[[expectFutureValue(theValue(quickLookImage != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewPDFPageRepresentationType", ^{
		__block PDFDocument *document = nil;
		__block PDFPage *pdfPage = nil;
		
		beforeAll(^{
			NSURL *resource = [[NSBundle bundleForClass:[self class]] URLForResource:@"Test" withExtension:@"pdf"];
			document = [[PDFDocument alloc] initWithURL:resource];
			pdfPage = [document pageAtIndex:0];
		});
		afterAll(^{
			document = nil;
			pdfPage = nil;
		});

		it(@"should handle MMFlowViewPDFPageRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewPDFPageRepresentationType]) should] beYes];
		});

		it(@"should asynchronously load an image from an PDFPage", ^{
			__block CGImageRef pdfImage = NULL;
			
			[sut createImageForItem:pdfPage withRepresentationType:kMMFlowViewPDFPageRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				pdfImage = image;
			}];
			[[expectFutureValue(theValue(pdfImage != NULL)) shouldEventually] beTrue];
		});
		it(@"should asynchronously load an image from an CGPDFPageRef", ^{
			__block CGImageRef pdfImage = NULL;
			
			[sut createImageForItem:(id)[pdfPage pageRef] withRepresentationType:kMMFlowViewPDFPageRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				pdfImage = image;
			}];
			[[expectFutureValue(theValue(pdfImage != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewPathRepresentationType", ^{
		it(@"should handle kMMFlowViewPathRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewPathRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an image from an NSString", ^{
			__block CGImageRef imageFromPath = NULL;
			
			[sut createImageForItem:imageString withRepresentationType:kMMFlowViewPathRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				imageFromPath = image;
			}];
			[[expectFutureValue(theValue(imageFromPath != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewURLRepresentationType", ^{
		it(@"should handle kMMFlowViewURLRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewURLRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an image from an NSURL", ^{
			__block CGImageRef imageFromURL = NULL;
			
			[sut createImageForItem:imageURL withRepresentationType:kMMFlowViewURLRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				imageFromURL = image;
			}];
			[[expectFutureValue(theValue(imageFromURL != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewNSImageRepresentationType", ^{
		it(@"should handle kMMFlowViewNSImageRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewNSImageRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an image from an NSImage", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createImageForItem:image withRepresentationType:kMMFlowViewNSImageRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				decodedImage = image;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewNSBitmapRepresentationType", ^{
		it(@"should handle kMMFlowViewNSBitmapRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewNSBitmapRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an image from an NSBitmapImageRep", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createImageForItem:imageRep withRepresentationType:kMMFlowViewNSBitmapRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				decodedImage = image;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewCGImageSourceRepresentationType", ^{
		__block CGImageSourceRef imageSource = NULL;

		beforeAll(^{
			imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)(imageURL), NULL);
		});
		afterAll(^{
			if (imageSource) {
				CFRelease(imageSource);
				imageSource = NULL;
			}
		});

		it(@"should handle kMMFlowViewCGImageSourceRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewCGImageSourceRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an image from an CGimageSourceRef", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createImageForItem:(__bridge id)imageSource withRepresentationType:kMMFlowViewCGImageSourceRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				decodedImage = image;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewNSDataRepresentationType", ^{
		__block NSData *dataImage = nil;

		beforeAll(^{
			dataImage = [NSData dataWithContentsOfURL:imageURL];
		});
		afterAll(^{
			dataImage = nil;
		});
		it(@"should handle kMMFlowViewNSDataRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewNSDataRepresentationType]) should] beYes];
		});

		it(@"should asynchronously load an image from an NSData", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createImageForItem:dataImage withRepresentationType:kMMFlowViewNSDataRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				decodedImage = image;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventually] beTrue];
		});
	});
});

SPEC_END
