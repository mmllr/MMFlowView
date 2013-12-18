//
//  MMPDFPageDecoderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMPDFPageDecoder.h"
#import <Quartz/Quartz.h>

SPEC_BEGIN(MMPDFPageDecoderSpec)

describe(@"MMPDFPageDecoder", ^{
	__block MMPDFPageDecoder *sut = nil;
	__block CGImageRef image = NULL;
	const CGSize desiredSize = {50, 50};
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
		sut = [[MMPDFPageDecoder alloc] init];
		
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
	context(@"creating an image from a PDFPage", ^{
		beforeEach(^{
			image = [sut newImageFromItem:pdfPage withSize:desiredSize];
		});
		it(@"should return an image", ^{
			[[theValue(image != NULL) should] beTrue];
		});
		it(@"should be in the specified size", ^{
			CGFloat width = CGImageGetWidth(image);
			CGFloat height = CGImageGetHeight(image);
			[[theValue(width == desiredSize.width || height == desiredSize.height) should] beTrue];
		});
	});
	context(@"creating an image from a CGPDFPageRef", ^{
		beforeEach(^{
			image = [sut newImageFromItem:(id)[pdfPage pageRef] withSize:desiredSize];
		});
		it(@"should return an image", ^{
			[[theValue(image != NULL) should] beTrue];
		});
		it(@"should be in the specified size", ^{
			CGFloat width = CGImageGetWidth(image);
			CGFloat height = CGImageGetHeight(image);
			[[theValue(width == desiredSize.width || height == desiredSize.height) should] beTrue];
		});
	});
	context(@"invoking with a non pdf item", ^{
		beforeEach(^{
			image = [sut newImageFromItem:@"Test"
							  withSize:desiredSize];
		});
		it(@"should not return an image", ^{
			[[theValue(image == NULL) should] beTrue];
		});
	});
});


SPEC_END
