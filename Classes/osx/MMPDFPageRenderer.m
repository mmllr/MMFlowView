/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://github.com/mmllr All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this
 software and associated documentation files (the "Software"), to deal in the Software
 without restriction, including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies
 or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
 
 */
//
//  MMPDFPageRenderer.m
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

- (id)init
{
	return [self initWithPDFPage:NULL];
}

- (id)initWithPDFPage:(CGPDFPageRef)aPage
{
	NSParameterAssert(aPage != NULL);
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
	[NSGraphicsContext setCurrentContext:context];
	[self drawBackground];
	[self.affineTransform set];
	CGContextDrawPDFPage([context graphicsPort], self.page);
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
	[NSGraphicsContext saveGraphicsState];
	[self drawPage:context];
	[NSGraphicsContext restoreGraphicsState];
	return image;
}

@end
