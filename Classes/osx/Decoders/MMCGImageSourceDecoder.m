//
//  MMCGImageSourceDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCGImageSourceDecoder.h"

@implementation MMCGImageSourceDecoder

@synthesize maxPixelSize;

- (CGImageRef)newCGImageFromItem:(id)anItem
{
	if ( anItem && (CGImageSourceGetTypeID() == CFGetTypeID((__bridge CFTypeRef)(anItem))) ) {
		CFStringRef imageSourceType = CGImageSourceGetType((__bridge CGImageSourceRef)(anItem));
		CGImageRef image = NULL;
		if ( imageSourceType ) {
			NSDictionary *options = self.maxPixelSize ? @{(NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES,
									  (NSString *)kCGImageSourceThumbnailMaxPixelSize: @(self.maxPixelSize)
														  } : @{(NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES};
			image = CGImageSourceCreateThumbnailAtIndex((__bridge CGImageSourceRef)(anItem), 0, (__bridge CFDictionaryRef)options );
		}
		return image;
	}
	return NULL;
}

- (NSImage*)imageFromItem:(id)anItem
{
	NSImage *image = nil;
	if ( anItem && (CGImageSourceGetTypeID() == CFGetTypeID((__bridge CFTypeRef)(anItem))) ) {
		CFStringRef imageSourceType = CGImageSourceGetType((__bridge CGImageSourceRef)(anItem));
		if ( imageSourceType != NULL ) {
			CGImageRef imageRef = [self newCGImageFromItem:anItem];
			if (imageRef) {
				image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
				CGImageRelease(imageRef);
			}
		}
	}
	return image;
}

@end
