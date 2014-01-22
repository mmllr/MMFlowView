//
//  MMNSImageDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMNSImageDecoder.h"
#import "MMNSDataImageDecoder.h"

@implementation MMNSImageDecoder

@synthesize maxPixelSize;

- (CGImageRef)newCGImageFromItem:(id)anItem
{
	if ([anItem isKindOfClass:[NSImage class]]) {
		NSImage *image = (NSImage*)anItem;
		MMNSDataImageDecoder *dataDecoder = [[MMNSDataImageDecoder alloc] init];
		dataDecoder.maxPixelSize = self.maxPixelSize;
		return [dataDecoder newCGImageFromItem:[image TIFFRepresentation]];
	}
	return NULL;
}

- (NSImage*)imageFromItem:(id)anItem
{
	return [anItem isKindOfClass:[NSImage class]] ? anItem : nil;
}

@end
