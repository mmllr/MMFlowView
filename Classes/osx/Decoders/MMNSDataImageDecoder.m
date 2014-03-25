//
//  MMNSDataImageDecoder.m
//  MMFlowViewDemo
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
