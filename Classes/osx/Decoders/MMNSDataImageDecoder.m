//
//  MMNSDataImageDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 19.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMNSDataImageDecoder.h"

@implementation MMNSDataImageDecoder

@synthesize maxPixelSize;

- (CGImageRef)newCGImageFromItem:(id)anItem
{
	if (![ anItem isKindOfClass:[NSData class]] ) {
		return NULL;
	}
	CFDataRef dataRef = (__bridge CFDataRef)(anItem);

	NSDictionary *options = self.maxPixelSize ? @{(NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES,
												  (NSString *)kCGImageSourceThumbnailMaxPixelSize: @(self.maxPixelSize)} :
												@{(NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES};
	
	CGImageSourceRef imageSource = CGImageSourceCreateWithData(dataRef, (__bridge CFDictionaryRef)options);
	CGImageRef image = NULL;
	if (imageSource) {
		image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options );
		CFRelease(imageSource);
		imageSource = NULL;
	}
	return image;
}

- (NSImage*)imageFromItem:(id)anItem
{
	if ([anItem isKindOfClass:[NSData class]]) {
		return [[NSImage alloc] initWithData:anItem];
	}
	return nil;
}

@end
