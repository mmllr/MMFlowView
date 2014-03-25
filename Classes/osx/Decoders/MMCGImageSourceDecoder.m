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
//  MMCGImageSourceDecoder.m
//
//  Created by Markus Müller on 18.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCGImageSourceDecoder.h"

@interface MMCGImageSourceDecoder ()

@property (nonatomic, strong) id item;
@property NSUInteger maxPixelSize;

@end

@implementation MMCGImageSourceDecoder
{
	CGImageRef _imageRef;
}

- (instancetype)init
{
    return [self initWithItem:nil maxPixelSize:0];
}

- (id<MMImageDecoderProtocol>)initWithItem:(id)anItem maxPixelSize:(NSUInteger)maxPixelSize
{
	NSParameterAssert(anItem);
	NSParameterAssert(CGImageSourceGetTypeID() == CFGetTypeID((__bridge CFTypeRef)anItem));
	NSParameterAssert(maxPixelSize > 0);

	self = [super init];
	if (self) {
		_item = anItem;
		_maxPixelSize = maxPixelSize;
		_imageRef = NULL;
	}
	return self;
}

- (void)dealloc
{
    if (_imageRef) {
		CGImageRelease(_imageRef);
	}
}

- (CGImageRef)CGImage
{
	if (_imageRef != NULL) {
		return _imageRef;
	}

	CFStringRef imageSourceType = CGImageSourceGetType((__bridge CGImageSourceRef)(self.item));

	if (imageSourceType) {
		NSDictionary *options = self.maxPixelSize ? @{(id)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES,
													  (id)kCGImageSourceThumbnailMaxPixelSize: @(self.maxPixelSize)
													  } : @{(id)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES};
		_imageRef = CGImageSourceCreateThumbnailAtIndex((__bridge CGImageSourceRef)(self.item), 0, (__bridge CFDictionaryRef)options);
	}
	return _imageRef;
}

- (NSImage*)image
{
	NSImage *image = nil;
	if (self.item && (CGImageSourceGetTypeID() == CFGetTypeID((__bridge CFTypeRef)(self.item))) ) {
		CFStringRef imageSourceType = CGImageSourceGetType((__bridge CGImageSourceRef)(self.item));
		if ( imageSourceType != NULL ) {
			CGImageRef imageRef = self.CGImage;
			if (imageRef) {
				image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
				CGImageRelease(imageRef);
			}
		}
	}
	return image;
}

@end
