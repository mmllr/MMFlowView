//
//  MMPDFPageDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "MMPDFPageDecoder.h"
#import "MMPDFPageRenderer.h"

@interface MMPDFPageDecoder ()

@property (nonatomic, strong) id item;
@property NSUInteger maxPixelSize;
@property (nonatomic, strong) MMPDFPageRenderer *pdfPageRenderer;

@end

@implementation MMPDFPageDecoder

- (instancetype)init
{
    return [self initWithItem:nil maxPixelSize:0];
}

- (id<MMImageDecoderProtocol>)initWithItem:(id)anItem maxPixelSize:(NSUInteger)maxPixelSize
{
	NSParameterAssert(anItem);
	NSParameterAssert(maxPixelSize > 0);
	NSParameterAssert([anItem isKindOfClass:[PDFPage class]] ||
					  CFGetTypeID((__bridge CFTypeRef)(anItem)) == CGPDFPageGetTypeID());

	self = [super init];
	if (self) {
		_item = anItem;
		_maxPixelSize = maxPixelSize;
		_pdfPageRenderer = [anItem isKindOfClass:[PDFPage class]] ? [[MMPDFPageRenderer alloc] initWithPDFPage:[((PDFPage*)anItem) pageRef]] : [[MMPDFPageRenderer alloc] initWithPDFPage:(__bridge CGPDFPageRef)anItem];
	}
	return self;
}

- (CGImageRef)CGImage
{
	self.pdfPageRenderer.imageSize = CGSizeMake(self.maxPixelSize, self.maxPixelSize);
	return [self.pdfPageRenderer.imageRepresentation CGImage];
}

- (NSImage*)image
{
	CGImageRef imageRef = self.CGImage;
	NSImage *image = nil;

	if (imageRef) {
		image =[[NSImage alloc] initWithCGImage:imageRef size:CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef))];
	}
	return image;
}

@end
