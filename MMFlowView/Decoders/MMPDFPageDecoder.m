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

@implementation MMPDFPageDecoder

@synthesize maxPixelSize;

- (MMPDFPageRenderer*)renderForItem:(id)anItem
{
	if ([anItem isKindOfClass:[PDFPage class]]) {
		return [[MMPDFPageRenderer alloc] initWithPDFPage:[((PDFPage*)anItem) pageRef]];
	}
	if (CFGetTypeID((__bridge CFTypeRef)(anItem)) == CGPDFPageGetTypeID()) {
		return [[MMPDFPageRenderer alloc] initWithPDFPage:(__bridge CGPDFPageRef)(anItem)];
	}
	return nil;
}

- (CGImageRef)newCGImageFromItem:(id)anItem
{
	MMPDFPageRenderer *renderer = [self renderForItem:anItem];
	if (!renderer) {
		return NULL;
	}
	renderer.imageSize = CGSizeMake(self.maxPixelSize, self.maxPixelSize);
	return CGImageRetain([renderer.imageRepresentation CGImage]);
}

- (NSImage*)imageFromItem:(id)anItem
{
	CGImageRef imageRef = [self newCGImageFromItem:anItem];
	if (imageRef) {
		NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef))];
		CGImageRelease(imageRef);
		return image;
	}
	return nil;
}

@end
