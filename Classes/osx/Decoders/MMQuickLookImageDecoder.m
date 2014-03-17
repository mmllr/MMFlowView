//
//  MMQuickLookImageDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMQuickLookImageDecoder.h"
#import <QuickLook/QuickLook.h>

const CGFloat kDefaultMaxPixelSize = 4000;

@implementation MMQuickLookImageDecoder

@synthesize maxPixelSize;

- (CGImageRef)newCGImageFromItem:(id)anItem
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
	NSDictionary *quickLookOptions = @{(id)kQLThumbnailOptionIconModeKey: (id)kCFBooleanFalse};
	return QLThumbnailImageCreate(NULL, itemURL, self.maxPixelSize ? CGSizeMake(self.maxPixelSize, self.maxPixelSize) : CGSizeMake(kDefaultMaxPixelSize, kDefaultMaxPixelSize), (__bridge CFDictionaryRef)quickLookOptions );
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
