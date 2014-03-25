/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://github.com/mmllr All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this
 software and associated documentation files (the "Software"), to deal in the Software
 without restriction, including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies
 or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
 
 */
//
//  MMQuickLookImageDecoder.m
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
{
	CGImageRef _imageRef;
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

- (instancetype)init
{
    return [self initWithItem:nil maxPixelSize:0];
}

- (id<MMImageDecoderProtocol>)initWithItem:(id)anItem maxPixelSize:(NSUInteger)maxPixelSize
{
	NSParameterAssert(anItem);
	NSParameterAssert(maxPixelSize > 0);
	NSParameterAssert([anItem isKindOfClass:[NSURL class]] || [anItem isKindOfClass:[NSString class]]);

	self = [super init];
	if (self) {
		_imageRef = NULL;
		NSURL *url = [[self class] urlForItem:anItem];
		NSAssert(url != nil, @"anItem must be a url or string path");

		_url = url;
		_maxPixelSize = maxPixelSize;
	}
	return self;
}

- (void)dealloc
{
    if (_imageRef) {
		CGImageRelease(_imageRef);
	}
}

- (CGImageRef)CGImage
{
	if (_imageRef) {
		return _imageRef;
	}
	NSDictionary *quickLookOptions = @{(id)kQLThumbnailOptionIconModeKey: (id)kCFBooleanFalse};
	_imageRef = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)self.url, self.maxPixelSize ? CGSizeMake(self.maxPixelSize, self.maxPixelSize) : CGSizeMake(kDefaultMaxPixelSize, kDefaultMaxPixelSize), (__bridge CFDictionaryRef)quickLookOptions );
	return _imageRef;
}

- (NSImage*)image
{
	return [[NSImage alloc] initWithContentsOfURL:self.url];
}

@end
