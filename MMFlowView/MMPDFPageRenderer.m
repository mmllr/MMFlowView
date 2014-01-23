//
//  MMPDFPageRenderer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 22.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMPDFPageRenderer.h"
#import "NSAffineTransform+MMAdditions.h"

@interface MMPDFPageRenderer ()

@property (nonatomic, strong) NSBitmapImageRep *imageRepresentation;

@end

@implementation MMPDFPageRenderer

#pragma mark - init/cleanup

- (id)initWithPDFPage:(CGPDFPageRef)aPage
{
	NSParameterAssert(CFGetTypeID(aPage) == CGPDFPageGetTypeID());

	self = [super init];
	if (self) {
		_page =  CGPDFPageRetain(aPage);
		_backgroundColor = [NSColor whiteColor];
		_imageSize = CGPDFPageGetBoxRect(aPage, kCGPDFCropBox).size;
	}
	return self;
}

- (void)dealloc
{
    if (_page) {
		CGPDFPageRelease(_page);
		_page = NULL;
	}
}

#pragma mark - accessors

- (CGSize)imageSize
{
	if (_imageSize.width <= 0 || _imageSize.height <= 0) {
		return CGPDFPageGetBoxRect(self.page, kCGPDFCropBox).size;
	}
	return _imageSize;
}

- (NSAffineTransform*)affineTransform
{
	CGRect imageRect = CGRectMake(0, 0, self.imageSize.width, self.imageSize.height);
	CGRect boxRect = CGPDFPageGetBoxRect(self.page, kCGPDFCropBox);
	if (CGRectGetWidth(imageRect) > CGRectGetWidth(boxRect)) {
		CGFloat scaleX = CGRectGetWidth(imageRect) / CGRectGetWidth(boxRect);
		CGAffineTransform transform = CGAffineTransformMakeTranslation(-boxRect.origin.x, -boxRect.origin.y);
		return [NSAffineTransform affineTransformWithCGAffineTransform:CGAffineTransformScale(transform, scaleX, scaleX)];
	}
	return [NSAffineTransform affineTransformWithCGAffineTransform:CGPDFPageGetDrawingTransform(_page, kCGPDFCropBox, imageRect, 0, true)];
}

- (void)drawBackground
{
	[self.backgroundColor setFill];
	CGSize size = self.imageSize;
	[NSBezierPath fillRect:CGRectMake(0, 0, size.width, size.height)];
}

- (void)drawPage:(NSGraphicsContext *)context
{
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:context];
	[self drawBackground];
	[self.affineTransform set];
	CGContextDrawPDFPage([context graphicsPort], self.page);
	[NSGraphicsContext restoreGraphicsState];
}

- (NSBitmapImageRep*)imageRepresentation
{
	CGSize size = self.imageSize;

	NSBitmapImageRep *image = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																	  pixelsWide:size.width
																	  pixelsHigh:size.height
																   bitsPerSample:8
																 samplesPerPixel:4
																		hasAlpha:YES
																		isPlanar:NO
																  colorSpaceName:NSCalibratedRGBColorSpace
																	 bytesPerRow:0
																	bitsPerPixel:0];

	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:image];
	[self drawPage:context];
	return image;
}

@end
