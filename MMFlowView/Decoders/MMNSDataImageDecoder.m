//
//  MMNSDataImageDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 19.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMNSDataImageDecoder.h"

@implementation MMNSDataImageDecoder

- (CGImageRef)newImageFromItem:(id)anItem withSize:(CGSize)imageSize
{
	if ([ anItem isKindOfClass:[NSData class]] ) {
		CFDataRef dataRef = (__bridge CFDataRef)(anItem);

		imageSize.width = imageSize.width > 0 ? imageSize.width : 16000;
		imageSize.height = imageSize.height > 0 ? imageSize.height : 16000;

		NSDictionary *options = @{(NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES,
								  (NSString *)kCGImageSourceThumbnailMaxPixelSize: [ NSNumber numberWithInteger:MAX(imageSize.width, imageSize.height) ]};

		CGImageSourceRef imageSource = CGImageSourceCreateWithData(dataRef, (__bridge CFDictionaryRef)options);
		if (imageSource) {
			CGImageRef image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options );
			CFRelease(imageSource);
			imageSource = NULL;
			return image;
		}
	}
	return NULL;
}

@end
