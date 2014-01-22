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
#import "MMImageDecoderProtocol.h"
#import "MMFlowView.h"

SPEC_BEGIN(MMFlowViewImageFactorySpec)

describe(@"MMFlowViewImageFactory", ^{
	NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
	NSString *testImageString = [testImageURL path];
	__block MMFlowViewImageFactory *sut = nil;
	__block NSImage *testImage = nil;
	__block NSBitmapImageRep *testImageRep = nil;
	__block id itemMock = nil;
	__block CGImageRef testImageRef = NULL;
	__block id decoderMock = nil;

	beforeAll(^{
		testImage = [[NSImage alloc] initWithContentsOfURL:testImageURL];
		testImageRef = [testImage CGImageForProposedRect:NULL
												 context:NULL
												   hints:nil];
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
		itemMock = nil;
		if (testImageRef) {
			CGImageRelease(testImageRef);
			testImageRef = NULL;
		}
	});

	beforeEach(^{
		sut = [[MMFlowViewImageFactory alloc] init];
		itemMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewItem)];
		[itemMock stub:@selector(imageItemRepresentationType) andReturn:@"testRepresentationType"];
		[itemMock stub:@selector(imageItemRepresentation) andReturn:(__bridge id)testImageRef];
		decoderMock = [KWMock nullMockForProtocol:@protocol(MMImageDecoderProtocol)];
		//[decoderMock stub:@selector(newCGImageFromItem:) andReturn:(__bridge id)(testImageRef)];
		//[decoderMock stub:@selector(maxPixelSize) andReturn:@100];
		//[decoderMock stub:@selector(setMaxPixelSize:)];
	});
	afterEach(^{
		sut = nil;
		itemMock = nil;
		decoderMock = nil;
	});

	it(@"should exist", ^{
		[[sut shouldNot] beNil];
	});
	it(@"should respond to maxImageSize", ^{
		[[sut should] respondToSelector:@selector(maxImageSize)];
	});
	it(@"should respond to setMaxImageSize:", ^{
		[[sut should] respondToSelector:@selector(setMaxImageSize:)];
	});
	it(@"should respond to decoderforRepresentationType:", ^{
		[[sut should] respondToSelector:@selector(decoderforRepresentationType:)];
	});
	it(@"should respond to setDecoder:forRepresentationType:", ^{
		[[sut should] respondToSelector:@selector(setDecoder:forRepresentationType:)];
	});
	it(@"should have a initial maxImageSize of {100,100}", ^{
		NSValue *expectedSize = [NSValue valueWithSize:CGSizeMake(100, 100)];
		[[[NSValue valueWithSize:sut.maxImageSize] should] equal:expectedSize];
	});
	context(@"decoders", ^{
		it(@"should raise an NSInternalInconsistencyException when setting an object not conforming to MMImageDecoderProtocol", ^{
			[[theBlock(^{
				[sut setDecoder:((id<MMImageDecoderProtocol>)@"A string") forRepresentationType:@"type"];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		it(@"should raise an NSInternalInconsistencyException when setting a decoder with a nil representationType", ^{
			[[theBlock(^{
				[sut setDecoder:decoderMock forRepresentationType:nil];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		context(@"when setting decoder with empty representation type", ^{
			it(@"should not raise when setting a decoder for an empty string representationType", ^{
				[[theBlock(^{
					[sut setDecoder:decoderMock forRepresentationType:@""];
				}) shouldNot] raise];
			});
			it(@"should not set the decoder", ^{
				[sut setDecoder:decoderMock forRepresentationType:@""];
				[[(id)[sut decoderforRepresentationType:@""] should] beNil];
			});
		});
		context(@"when setting a valid decoder", ^{
			beforeEach(^{
				[sut setDecoder:decoderMock forRepresentationType:@"myRepresentationType"];
			});
			it(@"should set the decoder", ^{
				[[(id)[sut decoderforRepresentationType:@"myRepresentationType"] should] equal:decoderMock];
			});
		});
	});
	context(@"createCGImageForItem:completionHandler:", ^{
		beforeEach(^{
			[sut setDecoder:decoderMock forRepresentationType:@"testRepresentationType"];
		});
		it(@"should respond to createCGImageForItem:completionHandler:", ^{
			[[sut should] respondToSelector:@selector(createCGImageForItem:completionHandler:)];
		});
		it(@"should throw an exception when invoked with a NULL completetionHandler", ^{
			[[theBlock(^{
				[sut createCGImageForItem:itemMock completionHandler:NULL];
			}) should] raise];
		});
		it(@"should call invoke completionBlock on the main thread", ^{
			NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
			__block NSOperationQueue *queueOnCompletionBlock = nil;
			[decoderMock stub:@selector(newCGImageFromItem:) andReturn:(__bridge id)(testImageRef)];
			
			[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef image) {
				queueOnCompletionBlock = [NSOperationQueue currentQueue];
			}];
			[[expectFutureValue(queueOnCompletionBlock) shouldEventually] equal:mainQueue];
		});
		context(@"interaction with image decoder", ^{
			it(@"should ask the item for its imageRepresentationType", ^{
				[[itemMock should] receive:@selector(imageItemRepresentationType)];
				[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef image) {
				}];
			});
			it(@"should should ask the item for its imageRepresentation", ^{
				[[itemMock should] receive:@selector(imageItemRepresentationType)];
				[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef image) {
				}];
			});
			it(@"should set its image size to the decoder", ^{
				[[decoderMock should] receive:@selector(setMaxPixelSize:) withArguments:theValue(MAX(sut.maxImageSize.width, sut.maxImageSize.height))];
				[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef image) {
				}];
			});
			it(@"should send the decoder newImageFromItem:", ^{
				[[decoderMock shouldEventually] receive:@selector(newCGImageFromItem:) andReturn:(__bridge id)testImageRef];
				 
				[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef image) {
				}];
			});
		});
	});
	context(@"imageForItem:completionHandler:", ^{
		it(@"should respond to imageForItem:completionHandler:", ^{
			[[sut should] respondToSelector:@selector(imageForItem:completionHandler:)];
		});
		it(@"should throw an exception when invoked with a NULL completetionHandler", ^{
			[[theBlock(^{
				[sut imageForItem:itemMock completionHandler:NULL];
			}) should] raise];
		});
	});
	context(@"kMMFlowViewQuickLookPathRepresentationType", ^{
		beforeEach(^{
			[itemMock stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewQuickLookPathRepresentationType];
		});
		it(@"should handle kMMFlowViewQuickLookPathRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewQuickLookPathRepresentationType]) should] beYes];
		});
		context(@"load from NSURL", ^{
			beforeEach(^{
				[itemMock stub:@selector(imageItemRepresentation) andReturn:testImageURL];
			});
			it(@"should asynchronously load an CGImageRef from an NSURL", ^{
				__block CGImageRef quickLookImage = NULL;
				[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef imageRef) {
					quickLookImage = imageRef;
				}];
				[[expectFutureValue(theValue(quickLookImage != NULL)) shouldEventuallyBeforeTimingOutAfter(3)] beTrue];
			});
			it(@"should asynchronously load an NSImage from an NSURL", ^{
				__block NSImage *quickLookImage = nil;
				
				[sut imageForItem:itemMock completionHandler:^(NSImage *anImage) {
					quickLookImage = anImage;
				}];
				[[expectFutureValue(quickLookImage) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
			});
		});
		context(@"load from NSString", ^{
			beforeEach(^{
				[itemMock stub:@selector(imageItemRepresentation) andReturn:testImageString];
			});
			it(@"should asynchronously load an CGImageRef from an NSString", ^{
				__block CGImageRef quickLookImage = NULL;
				[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef imageRef) {
					quickLookImage = imageRef;
				}];
				[[expectFutureValue(theValue(quickLookImage != NULL)) shouldEventuallyBeforeTimingOutAfter(3)] beTrue];
			});
			it(@"should asynchronously load an NSImage from an NSString", ^{
				__block NSImage *quickLookImage = nil;
				
				[sut imageForItem:itemMock completionHandler:^(NSImage *anImage) {
					quickLookImage = anImage;
				}];
				[[expectFutureValue(quickLookImage) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
			});
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
		beforeEach(^{
			[itemMock stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewPDFPageRepresentationType];
		});

		it(@"should handle MMFlowViewPDFPageRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewPDFPageRepresentationType]) should] beYes];
		});

		context(@"load from PDFPage", ^{
			beforeEach(^{
				[itemMock stub:@selector(imageItemRepresentation) andReturn:pdfPage];
			});
			it(@"should asynchronously load an CGImageRef from an PDFPage", ^{
				__block CGImageRef pdfImage = NULL;
				
				[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef image) {
					pdfImage = image;
				}];
				[[expectFutureValue(theValue(pdfImage != NULL)) shouldEventuallyBeforeTimingOutAfter(3)] beTrue];
			});
			it(@"should asynchronously load an NSImage from an PDFPage", ^{
				__block NSImage *pdfImage = nil;

				[sut imageForItem:itemMock completionHandler:^(NSImage *image) {
					pdfImage = image;
				}];
				[[expectFutureValue(pdfImage) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
			});
		});

		context(@"load from CGPDFPageRef", ^{
			beforeEach(^{
				[itemMock stub:@selector(imageItemRepresentation) andReturn:(id)[pdfPage pageRef]];
			});
			it(@"should asynchronously load an CGImageRef from an CGPDFPageRef", ^{
				__block CGImageRef pdfImage = NULL;
				
				[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef image) {
					pdfImage = image;
				}];
				[[expectFutureValue(theValue(pdfImage != NULL)) shouldEventuallyBeforeTimingOutAfter(3)] beTrue];
			});
			it(@"should asynchronously load an NSImage from an CGPDFPageRef", ^{
				__block NSImage *pdfImage = nil;
				
				[sut imageForItem:itemMock completionHandler:^(NSImage *image) {
					pdfImage = image;
				}];
				[[expectFutureValue(pdfImage) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
			});
		});
		
	});
	context(@"kMMFlowViewPathRepresentationType", ^{
		beforeEach(^{
			[itemMock stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewPathRepresentationType];
			[itemMock stub:@selector(imageItemRepresentation) andReturn:testImageString];
		});
		it(@"should handle kMMFlowViewPathRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewPathRepresentationType]) should] beYes];
		});

		it(@"should asynchronously load an CGImageRef from an NSString", ^{
			__block CGImageRef imageFromPath = NULL;
			
			[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef image) {
				imageFromPath = image;
			}];
			[[expectFutureValue(theValue(imageFromPath != NULL)) shouldEventually] beTrue];
		});

		it(@"should asynchronously load an NSImage from an NSString", ^{
			__block NSImage *imageFromPath = nil;

			[sut imageForItem:itemMock completionHandler:^(NSImage *image) {
				imageFromPath = image;
			}];
			[[expectFutureValue(imageFromPath) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
		});
	});
	context(@"kMMFlowViewURLRepresentationType", ^{
		beforeEach(^{
			[itemMock stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewURLRepresentationType];
			[itemMock stub:@selector(imageItemRepresentation) andReturn:testImageURL];
		});
		it(@"should handle kMMFlowViewURLRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewURLRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an CGImageRef from an NSURL", ^{
			__block CGImageRef imageFromURL = NULL;
			
			[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef image) {
				imageFromURL = image;
			}];
			[[expectFutureValue(theValue(imageFromURL != NULL)) shouldEventuallyBeforeTimingOutAfter(3)] beTrue];
		});
		it(@"should asynchronously load an NSImage from an NSURL", ^{
			__block NSImage *imageFromURL = nil;
			
			[sut imageForItem:itemMock completionHandler:^(NSImage *image) {
				imageFromURL = image;
			}];
			[[expectFutureValue(imageFromURL) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
		});
	});
	context(@"kMMFlowViewNSImageRepresentationType", ^{
		beforeEach(^{
			[itemMock stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewNSImageRepresentationType];
			[itemMock stub:@selector(imageItemRepresentation) andReturn:testImage];
		});
		it(@"should handle kMMFlowViewNSImageRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewNSImageRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an CGImageRef from an NSImage", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef imageRef) {
				decodedImage = imageRef;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventuallyBeforeTimingOutAfter(3)] beTrue];
		});
		it(@"should asynchronously load an NSImage from an NSImage", ^{
			__block NSImage *decodedImage = nil;
			
			[sut imageForItem:itemMock completionHandler:^(NSImage *anImage) {
				decodedImage = anImage;
			}];
			[[expectFutureValue(decodedImage) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
		});
	});
	context(@"kMMFlowViewNSBitmapRepresentationType", ^{
		beforeEach(^{
			[itemMock stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewNSBitmapRepresentationType];
			[itemMock stub:@selector(imageItemRepresentation) andReturn:testImageRep];
		});
		it(@"should handle kMMFlowViewNSBitmapRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewNSBitmapRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an CGImageRef from an NSBitmapImageRep", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef imageRef) {
				decodedImage = imageRef;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventuallyBeforeTimingOutAfter(3)] beTrue];
		});
		it(@"should asynchronously load an NSImage from an NSBitmapImageRep", ^{
			__block NSImage *decodedImage = nil;
			
			[sut imageForItem:itemMock completionHandler:^(NSImage *anImage) {
				decodedImage = anImage;
			}];
			[[expectFutureValue(decodedImage) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
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
		beforeEach(^{
			[itemMock stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewCGImageSourceRepresentationType];
			[itemMock stub:@selector(imageItemRepresentation) andReturn:(__bridge id)imageSource];
		});

		it(@"should handle kMMFlowViewCGImageSourceRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewCGImageSourceRepresentationType]) should] beYes];
		});
		
		it(@"should asynchronously load an CGImageRef from an CGImageSourceRef", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef imageRef) {
				decodedImage = imageRef;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventuallyBeforeTimingOutAfter(3)] beTrue];
		});
		it(@"should asynchronously load an NSImage from an CGImageSourceRef", ^{
			__block NSImage *decodedImage = nil;
			
			[sut imageForItem:itemMock completionHandler:^(NSImage *anImage) {
				decodedImage = anImage;
			}];
			[[expectFutureValue(decodedImage) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
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
		beforeEach(^{
			[itemMock stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewNSDataRepresentationType];
			[itemMock stub:@selector(imageItemRepresentation) andReturn:dataImage];
		});
		it(@"should handle kMMFlowViewNSDataRepresentationType", ^{
			[[theValue([sut canDecodeRepresentationType:kMMFlowViewNSDataRepresentationType]) should] beYes];
		});

		it(@"should asynchronously load an CGImageRef from a NSData", ^{
			__block CGImageRef decodedImage = NULL;
			
			[sut createCGImageForItem:itemMock completionHandler:^(CGImageRef image) {
				decodedImage = image;
			}];
			[[expectFutureValue(theValue(decodedImage != NULL)) shouldEventuallyBeforeTimingOutAfter(3)] beTrue];
		});
		it(@"should asynchronously load an NSImage from a NSData", ^{
			__block NSImage *decodedImage = nil;
			
			[sut imageForItem:itemMock completionHandler:^(NSImage *anImage) {
				decodedImage = anImage;
			}];
			[[expectFutureValue(decodedImage) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
		});
	});
});

SPEC_END
