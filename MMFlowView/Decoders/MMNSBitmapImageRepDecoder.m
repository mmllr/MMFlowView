//
//  MMNSBitmapImageRepDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMNSBitmapImageRepDecoder.h"
#import "MMNSDataImageDecoder.h"

@implementation MMNSBitmapImageRepDecoder

@synthesize maxPixelSize;

- (CGImageRef)newCGImageFromItem:(id)anItem
{
	if ([anItem isKindOfClass:[NSBitmapImageRep class]]) {
		NSBitmapImageRep *bitmapImage = anItem;
		MMNSDataImageDecoder *dataDecoder = [[MMNSDataImageDecoder alloc] init];
		dataDecoder.maxPixelSize = self.maxPixelSize;
		return [dataDecoder newCGImageFromItem:[bitmapImage TIFFRepresentation]];
	}
	return NULL;
}

- (NSImage*)imageFromItem:(id)anItem
{
	NSImage *image = nil;
	if ([anItem isKindOfClass:[NSBitmapImageRep class]]) {
		image = [[NSImage alloc] init];
		[image addRepresentation:anItem];
	}
	return image;
}

@end
