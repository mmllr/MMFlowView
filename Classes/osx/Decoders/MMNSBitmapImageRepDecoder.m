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
//  MMNSBitmapImageRepDecoder.m
//
//  Created by Markus Müller on 18.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMNSBitmapImageRepDecoder.h"
#import "MMNSDataImageDecoder.h"

@interface MMNSBitmapImageRepDecoder ()

@property (nonatomic, strong) id item;
@property NSUInteger maxPixelSize;

@end

@implementation MMNSBitmapImageRepDecoder

- (instancetype)init
{
    return [self initWithItem:nil maxPixelSize:0];
}

- (id<MMImageDecoderProtocol>)initWithItem:(id)anItem maxPixelSize:(NSUInteger)maxPixelSize
{
	NSParameterAssert(anItem);
	NSParameterAssert([anItem isKindOfClass:[NSBitmapImageRep class]]);
	NSParameterAssert(maxPixelSize > 0);

	self = [super init];
	if (self) {
		_item = anItem;
		_maxPixelSize = maxPixelSize;
	}
	return self;
}

- (CGImageRef)CGImage
{
	MMNSDataImageDecoder *dataDecoder = [[MMNSDataImageDecoder alloc] initWithItem:[self.item TIFFRepresentation]
																	  maxPixelSize:self.maxPixelSize];
	return dataDecoder.CGImage;
}

- (NSImage*)image
{
	NSImage *image = [[NSImage alloc] init];
	[image addRepresentation:self.item];
	return image;
}

@end
