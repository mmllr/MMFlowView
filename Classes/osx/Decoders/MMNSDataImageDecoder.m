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
//  MMNSDataImageDecoder.m
//
//  Created by Markus Müller on 19.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMNSDataImageDecoder.h"

@interface MMNSDataImageDecoder ()

@property (nonatomic, strong) id item;
@property NSUInteger maxPixelSize;

@end

@implementation MMNSDataImageDecoder
{
	CGImageRef _imageRef;
}

- (instancetype)init
{
    return [self initWithItem:nil maxPixelSize:0];
}

- (id<MMImageDecoderProtocol>)initWithItem:(id)anItem maxPixelSize:(NSUInteger)maxPixelSize
{
	NSParameterAssert(anItem);
	NSParameterAssert(maxPixelSize > 0);
	NSParameterAssert([anItem isKindOfClass:[NSData class]]);

	self = [super init];
	if (self) {
		_imageRef = NULL;
		_item = anItem;
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
	NSDictionary *options = self.maxPixelSize ? @{(NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES,
												  (NSString *)kCGImageSourceThumbnailMaxPixelSize: @(self.maxPixelSize)} :
												@{(NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES};
	
	CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)self.item, (__bridge CFDictionaryRef)options);
	if (imageSource) {
		_imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options );
		CFRelease(imageSource);
	}
	return _imageRef;
}

- (NSImage*)image
{
	return [[NSImage alloc] initWithData:self.item];
}

@end
