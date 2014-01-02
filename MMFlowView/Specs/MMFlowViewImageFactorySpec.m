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
	NSString *testImageString = @"/Library/Screen Savers/Default Collections/3-Cosmos/Cosmos01.jpg";
	NSURL *testImageURL = [NSURL fileURLWithPath:testImageString];
	const CGSize maximumImageSize = {100, 100};
	__block MMFlowViewImageFactory *sut = nil;
	__block NSImage *testImage = nil;
	__block NSBitmapImageRep *testImageRep = nil;

	beforeAll(^{
		testImage = [[NSImage alloc] initWithContentsOfURL:testImageURL];
		for ( NSImageRep* rep in [testImage representations] ) {
			if ([rep isKindOfClass:[NSBitmapImageRep class]] ) {
				testImageRep = [(NSBitmapImageRep*)rep copy];
				break;
			}
		}
	});
	afterAll(^{
		testImage = nil;
		testImageRep = nil;
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
	context(@"createCGImageForItem:withRepresentationType:maximumSize:completionHandler:", ^{
		it(@"should respond to createCGImageForItem:withRepresentationType:maximumSize:completionHandler:", ^{
			[[sut should] respondToSelector:@selector(createCGImageForItem:withRepresentationType:maximumSize:completionHandler:)];
		});
		it(@"should throw an exception when invoked with a NULL completetionHandler", ^{
			[[theBlock(^{
				[sut createCGImageForItem:testImageURL withRepresentationType:kMMFlowViewQuickLookPathRepresentationType maximumSize:maximumImageSize completionHandler:NULL];
			}) should] raise];
		});
	});
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

		it(@"should asynchronously load an CGImageRef from an NSURL", ^{
			__block CGImageRef quickLookImage = NULL;

			[sut createCGImageForItem:testImageURL withRepresentationType:kMMFlowViewQuickLookPathRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef imageRef) {
				quickLookImage = imageRef;
			}];
			[[expectFutureValue(theValue(quickLookImage != NULL)) shouldEventually] beTrue];
		});

		it(@"should asynchronously load an image from an NSString", ^{
		it(@"should asynchronously load an CGImageRef from an NSString", ^{
			__block CGImageRef quickLookImage = NULL;

			[sut createCGImageForItem:testImageString withRepresentationType:kMMFlowViewQuickLookPathRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef imageRef) {
				quickLookImage = imageRef;
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

		it(@"should asynchronously load an CGImageRef from an PDFPage", ^{
			__block CGImageRef pdfImage = NULL;
			
			[sut createCGImageForItem:pdfPage withRepresentationType:kMMFlowViewPDFPageRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				pdfImage = image;
			}];
			[[expectFutureValue(theValue(pdfImage != NULL)) shouldEventually] beTrue];
		});
		it(@"should asynchronously load an image from an CGPDFPageRef", ^{
		it(@"should asynchronously load an CGImageRef from an CGPDFPageRef", ^{
			__block CGImageRef pdfImage = NULL;
			
			[sut createCGImageForItem:(id)[pdfPage pageRef] withRepresentationType:kMMFlowViewPDFPageRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				pdfImage = image;
			}];
			[[expectFutureValue(theValue(pdfImage != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewPathRepresentationType", ^{
		it(@"should handle kMMFlowViewPathRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewPathRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an CGImageRef from an NSString", ^{
			__block CGImageRef imageFromPath = NULL;
			
			[sut createCGImageForItem:testImageString withRepresentationType:kMMFlowViewPathRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				imageFromPath = image;
			}];
			[[expectFutureValue(theValue(imageFromPath != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewURLRepresentationType", ^{
		it(@"should handle kMMFlowViewURLRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewURLRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an CGImageRef from an NSURL", ^{
			__block CGImageRef imageFromURL = NULL;
			
			[sut createCGImageForItem:testImageURL withRepresentationType:kMMFlowViewURLRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				imageFromURL = image;
			}];
			[[expectFutureValue(theValue(imageFromURL != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewNSImageRepresentationType", ^{
		it(@"should handle kMMFlowViewNSImageRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewNSImageRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an CGImageRef from an NSImage", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createCGImageForItem:testImage withRepresentationType:kMMFlowViewNSImageRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef imageRef) {
				decodedImage = imageRef;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewNSBitmapRepresentationType", ^{
		it(@"should handle kMMFlowViewNSBitmapRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewNSBitmapRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an CGImageRef from an NSBitmapImageRep", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createCGImageForItem:testImageRep withRepresentationType:kMMFlowViewNSBitmapRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef imageRef) {
				decodedImage = imageRef;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewCGImageSourceRepresentationType", ^{
		__block CGImageSourceRef imageSource = NULL;

		beforeAll(^{
			imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)(testImageURL), NULL);
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
		
		it(@"should asynchronously load an CGImageRef from an CGImageSourceRef", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createCGImageForItem:(__bridge id)imageSource withRepresentationType:kMMFlowViewCGImageSourceRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef imageRef) {
				decodedImage = imageRef;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventually] beTrue];
		});
	});
	context(@"kMMFlowViewNSDataRepresentationType", ^{
		__block NSData *dataImage = nil;

		beforeAll(^{
			dataImage = [NSData dataWithContentsOfURL:testImageURL];
		});
		afterAll(^{
			dataImage = nil;
		});
		it(@"should handle kMMFlowViewNSDataRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewNSDataRepresentationType]) should] beYes];
		});

		it(@"should asynchronously load an CGImageRef from a NSData", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createCGImageForItem:dataImage withRepresentationType:kMMFlowViewNSDataRepresentationType maximumSize:maximumImageSize completionHandler:^(CGImageRef image) {
				decodedImage = image;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventually] beTrue];
		});
	});
});

SPEC_END
