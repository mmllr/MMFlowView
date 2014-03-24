//
//  MMQuickLookImageDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <QuickLook/QuickLook.h>

#import "MMQuickLookImageDecoder.h"

const CGFloat kDefaultMaxPixelSize = 4000;

@interface MMQuickLookImageDecoder ()

@property (nonatomic, strong) NSURL *url;
@property NSUInteger maxPixelSize;

@end

@implementation MMQuickLookImageDecoder

- (instancetype)init
{
    return [self initWithItem:nil maxPixelSize:0];
}

+ (NSURL*)urlForItem:(id)anItem
{
	if ([anItem isKindOfClass:[NSURL class]]) {
		return anItem;
	}
	NSURL *url = [NSURL fileURLWithPath:anItem];
	if ([url isFileURL]) {
		return url;
	}
	return nil;
}

- (id<MMImageDecoderProtocol>)initWithItem:(id)anItem maxPixelSize:(NSUInteger)maxPixelSize
{
	NSParameterAssert(anItem);
	NSParameterAssert(maxPixelSize > 0);
	NSParameterAssert([anItem isKindOfClass:[NSURL class]] || [anItem isKindOfClass:[NSString class]]);

	self = [super init];
	if (self) {
		NSURL *url = [[self class] urlForItem:anItem];
		NSAssert(url != nil, @"anItem must be a url or string path");

		_url = url;
		_maxPixelSize = maxPixelSize;
	}
	return self;
}

- (CGImageRef)CGImage
{
	NSDictionary *quickLookOptions = @{(id)kQLThumbnailOptionIconModeKey: (id)kCFBooleanFalse};
	return QLThumbnailImageCreate(NULL, (__bridge CFURLRef)self.url, self.maxPixelSize ? CGSizeMake(self.maxPixelSize, self.maxPixelSize) : CGSizeMake(kDefaultMaxPixelSize, kDefaultMaxPixelSize), (__bridge CFDictionaryRef)quickLookOptions );
}

- (NSImage*)image
{
	return [[NSImage alloc] initWithContentsOfURL:self.url];
}

@end
