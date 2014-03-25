//
//  MMCGImageSourceDecoder.m
//  MMFlowViewDemo
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
