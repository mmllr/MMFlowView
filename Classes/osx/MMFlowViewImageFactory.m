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
//  MMFlowViewImageFactory.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMFlowViewImageFactory.h"
#import "MMFlowView.h"
#import "MMQuickLookImageDecoder.h"
#import "MMPDFPageDecoder.h"
#import "MMNSImageDecoder.h"
#import "MMNSBitmapImageRepDecoder.h"
#import "MMCGImageSourceDecoder.h"
#import "MMNSDataImageDecoder.h"
#import "MMFlowViewImageCache.h"

static CGFloat const kDefaultMaxImageDimension = 100;

@interface MMFlowViewImageFactory ()

@property (strong) NSMutableDictionary *imageDecoders;

@end

@implementation MMFlowViewImageFactory

#pragma mark - class methods

+ (NSDictionary*)createImageDecoders
{
	MMQuickLookImageDecoder *quickLookDecoder = [MMQuickLookImageDecoder new];

	return @{kMMFlowViewQuickLookPathRepresentationType: quickLookDecoder,
			 kMMFlowViewPathRepresentationType: quickLookDecoder,
			 kMMFlowViewURLRepresentationType: quickLookDecoder,
			 kMMFlowViewPDFPageRepresentationType: [MMPDFPageDecoder new],
			 kMMFlowViewNSImageRepresentationType: [MMNSImageDecoder new],
			 kMMFlowViewNSBitmapRepresentationType: [MMNSBitmapImageRepDecoder new],
			 kMMFlowViewCGImageSourceRepresentationType: [MMCGImageSourceDecoder new],
			 kMMFlowViewNSDataRepresentationType: [MMNSDataImageDecoder new]
			 };
}

#pragma mark - init/cleanup

- (id)init
{
    self = [super init];
    if (self) {
		_operationQueue = [[NSOperationQueue alloc] init];
        _imageDecoders = [NSMutableDictionary dictionaryWithDictionary:[[self class] createImageDecoders]];
		_maxImageSize = CGSizeMake(kDefaultMaxImageDimension, kDefaultMaxImageDimension);
    }
    return self;
}

- (void)dealloc
{
    [self.operationQueue cancelAllOperations];
}

#pragma mark - public API

- (void)setMaxImageSize:(CGSize)maxImageSize
{
	if (CGSizeEqualToSize(_maxImageSize, CGSizeZero) ||
		CGSizeEqualToSize(_maxImageSize, maxImageSize) ||
		maxImageSize.width <= 0 ||
		maxImageSize.height <= 0) {
		return;
	}
	_maxImageSize = maxImageSize;
	[self.cache reset];
	
}

- (id<MMImageDecoderProtocol>)decoderforRepresentationType:(NSString*)representationType
{
	return self.imageDecoders[representationType];
}

- (void)setDecoder:(id<MMImageDecoderProtocol>)aDecoder forRepresentationType:(NSString*)representationType
{
	NSParameterAssert([aDecoder conformsToProtocol:@protocol(MMImageDecoderProtocol)]);
	NSParameterAssert(representationType);

	if ([representationType length] > 0) {
		self.imageDecoders[representationType] = aDecoder;
	}
}

- (BOOL)canDecodeRepresentationType:(NSString*)representationType
{
	return [self decoderforRepresentationType:representationType] != nil;
}

- (void)createCGImageForItem:(id<MMFlowViewItem>)anItem completionHandler:(void(^)(CGImageRef))completionHandler
{
	NSParameterAssert(completionHandler != NULL);

	NSString *representationType = anItem.imageItemRepresentationType;
	NSString *itemUUID = anItem.imageItemUID;

	CGImageRef cachedImage = [self.cache imageForUUID:itemUUID];

	if (cachedImage) {
		completionHandler(cachedImage);
		return;
	}
	if ([self canDecodeRepresentationType:representationType]) {
		id<MMImageDecoderProtocol> decoder = [self decoderforRepresentationType:representationType];
		decoder.maxPixelSize = MAX(self.maxImageSize.width, self.maxImageSize.height);
		NSOperationQueue *callingQueue = [NSOperationQueue currentQueue];
		[self.operationQueue addOperationWithBlock:^{
			CGImageRef image = [decoder newCGImageFromItem:anItem.imageItemRepresentation];

			if (image) {
				[self.cache cacheImage:image withUUID:itemUUID];
				[callingQueue addOperationWithBlock:^{
					completionHandler(image);
					CGImageRelease(image);
				}];
			}
		}];
	}
}

- (void)imageForItem:(id<MMFlowViewItem>)anItem completionHandler:(void (^)(NSImage *))completionHandler
{
	NSParameterAssert(completionHandler != NULL);
	if ([self canDecodeRepresentationType:anItem.imageItemRepresentationType]) {
		id<MMImageDecoderProtocol> decoder = [self decoderforRepresentationType:anItem.imageItemRepresentationType];

		[self.operationQueue addOperationWithBlock:^{
			NSImage *image = [decoder imageFromItem:anItem.imageItemRepresentation];

			if (image) {
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					completionHandler(image);
				}];
			}
		}];
	}
}

- (void)cancelPendingDecodings
{
	[self.operationQueue cancelAllOperations];
}

@end
