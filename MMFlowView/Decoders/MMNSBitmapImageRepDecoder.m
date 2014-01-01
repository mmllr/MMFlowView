//
//  MMNSBitmapImageRepDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMNSBitmapImageRepDecoder.h"

@implementation MMNSBitmapImageRepDecoder

- (CGImageRef)newImageFromItem:(id)anItem withSize:(CGSize)imageSize
{
	if ([anItem isKindOfClass:[NSBitmapImageRep class]]) {
		NSBitmapImageRep *bitmapImage = anItem;
		
		NSRect proposedRect = NSMakeRect(0, 0, imageSize.width, imageSize.height);
		return CGImageRetain([bitmapImage CGImageForProposedRect:&proposedRect
														 context:nil
														   hints:nil]);
	}
	return NULL;
}

- (NSImage*)imageFromItem:(id)anItem
{
	NSImage *image = nil;
	if (anItem && [anItem isKindOfClass:[NSBitmapImageRep class]]) {
		image = [[NSImage alloc] init];
		[image addRepresentation:anItem];
	}
	return image;
}

@end
