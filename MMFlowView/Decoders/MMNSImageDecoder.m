//
//  MMNSImageDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMNSImageDecoder.h"

@implementation MMNSImageDecoder

- (CGImageRef)newImageFromItem:(id)anItem withSize:(CGSize)imageSize
{
	if ( [anItem isKindOfClass:[NSImage class]] ) {
		NSImage *image = [anItem copy];
		[image setSize:imageSize];
		return CGImageRetain([image CGImageForProposedRect:NULL
												   context:nil
													 hints:nil]);
	}
	else {
		return NULL;
	}
}

@end
