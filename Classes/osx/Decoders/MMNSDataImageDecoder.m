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
		_item = anItem;
		_maxPixelSize = maxPixelSize;
	}
	return self;
}

- (CGImageRef)CGImage
{
	CFDataRef dataRef = (__bridge CFDataRef)(self.item);

	NSDictionary *options = self.maxPixelSize ? @{(NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES,
												  (NSString *)kCGImageSourceThumbnailMaxPixelSize: @(self.maxPixelSize)} :
												@{(NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES};
	
	CGImageSourceRef imageSource = CGImageSourceCreateWithData(dataRef, (__bridge CFDictionaryRef)options);
	CGImageRef image = NULL;
	if (imageSource) {
		image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options );
		CFRelease(imageSource);
		imageSource = NULL;
	}
	return image;
}

- (NSImage*)image
{
	return [[NSImage alloc] initWithData:self.item];
}

@end
