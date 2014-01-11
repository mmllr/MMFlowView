//
//  MMQuickLookImageDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMQuickLookImageDecoder.h"
#import <QuickLook/QuickLook.h>

@implementation MMQuickLookImageDecoder

- (CGImageRef)newImageFromItem:(id)anItem withSize:(CGSize)imageSize
{
	NSParameterAssert(anItem);
	CFURLRef itemURL = NULL;
	if ( [anItem isKindOfClass:[NSURL class]] ||
		CFURLGetTypeID() == CFGetTypeID((CFTypeRef)anItem) ) {
		itemURL = (__bridge CFURLRef)anItem;
	}
	else if ( [anItem isKindOfClass:[NSString class]] ) {
		itemURL = (__bridge CFURLRef)[NSURL fileURLWithPath:anItem];
	}
	if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
		imageSize.width = 16000;
		imageSize.height = 16000;
	}
	NSDictionary *quickLookOptions = @{(id)kQLThumbnailOptionIconModeKey: (id)kCFBooleanFalse};
	return QLThumbnailImageCreate(NULL, itemURL, imageSize, (__bridge CFDictionaryRef)quickLookOptions );
}

- (NSImage*)imageFromItem:(id)anItem
{
	NSURL *url = nil;
	if ( [anItem isKindOfClass:[NSURL class]] ) {
		url = anItem;
	}
	else if ( [anItem isKindOfClass:[NSString class]] ) {
		url = [[NSFileManager defaultManager] fileExistsAtPath:anItem] ? [NSURL fileURLWithPath:anItem] : [NSURL URLWithString:anItem];
	}
	NSImage *image = url ? [[NSImage alloc] initWithContentsOfURL:url] : nil;
	return image;
}

@end
