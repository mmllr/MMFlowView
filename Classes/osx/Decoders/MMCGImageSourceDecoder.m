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
	}
	return self;
}

- (CGImageRef)CGImage
{
	CFStringRef imageSourceType = CGImageSourceGetType((__bridge CGImageSourceRef)(self.item));
	CGImageRef image = NULL;
	if (imageSourceType) {
		NSDictionary *options = self.maxPixelSize ? @{(id)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES,
													  (id)kCGImageSourceThumbnailMaxPixelSize: @(self.maxPixelSize)
													  } : @{(id)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES};
		image = CGImageSourceCreateThumbnailAtIndex((__bridge CGImageSourceRef)(self.item), 0, (__bridge CFDictionaryRef)options);
	}
	return image;
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
