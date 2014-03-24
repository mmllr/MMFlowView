//
//  MMNSImageDecoder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMNSImageDecoder.h"
#import "MMNSDataImageDecoder.h"

@interface MMNSImageDecoder ()

@property (nonatomic, strong) id item;
@property NSUInteger maxPixelSize;

@end

@implementation MMNSImageDecoder

- (instancetype)init
{
    return [self initWithItem:nil maxPixelSize:0];
}

- (id<MMImageDecoderProtocol>)initWithItem:(id)anItem maxPixelSize:(NSUInteger)maxPixelSize
{
	NSParameterAssert(anItem);
	NSParameterAssert([anItem isKindOfClass:[NSImage class]]);
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
	return self.item;
}

@end
