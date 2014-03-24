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
#import "MMImageDecoderProtocol.h"

static CGFloat const kDefaultMaxImageDimension = 100;

@interface MMFlowViewImageFactory ()

@property (strong) NSMutableDictionary *imageDecoders;

@end

@implementation MMFlowViewImageFactory

#pragma mark - init/cleanup

- (id)init
{
    self = [super init];
    if (self) {
		_operationQueue = [[NSOperationQueue alloc] init];
		_maxImageSize = CGSizeMake(kDefaultMaxImageDimension, kDefaultMaxImageDimension);
		_imageDecoders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self.operationQueue cancelAllOperations];
}

#pragma mark - public API

- (void)registerClass:(Class)aClass forItemRepresentationType:(NSString*)representationType
{
	if (![aClass conformsToProtocol:@protocol(MMImageDecoderProtocol)]) {
		return;
	}
	self.imageDecoders[representationType] = aClass;
}

- (void)setMaxImageSize:(CGSize)maxImageSize
{
	if (CGSizeEqualToSize(_maxImageSize, CGSizeZero) ||
		CGSizeEqualToSize(_maxImageSize, maxImageSize) ||
		maxImageSize.width <= 0 ||
		maxImageSize.height <= 0) {
		return;
	}
	_maxImageSize = maxImageSize;
}

- (id<MMImageDecoderProtocol>)decoderforItem:(id)anItem withRepresentationType:(NSString *)representationType
{
	Class decoderClass = self.imageDecoders[representationType];

	return [[decoderClass alloc] initWithItem:anItem
								 maxPixelSize:self.maxImageSize.width];
}

- (BOOL)canDecodeRepresentationType:(NSString*)representationType
{
	return self.imageDecoders[representationType] != nil;
}


- (void)createCGImageFromRepresentation:(id)anItem withType:(NSString *)representationType completionHandler:(void (^)(CGImageRef))completionHandler
{
	NSParameterAssert(anItem);
	NSParameterAssert(representationType);
	NSParameterAssert(completionHandler != NULL);

	if ([self canDecodeRepresentationType:representationType]) {
		id<MMImageDecoderProtocol> decoder = [self decoderforItem:anItem
										   withRepresentationType:representationType];

		NSOperationQueue *callingQueue = [NSOperationQueue currentQueue];
		[self.operationQueue addOperationWithBlock:^{
			CGImageRef image = decoder.CGImage;

			if (image) {
				[callingQueue addOperationWithBlock:^{
					completionHandler(image);
					CGImageRelease(image);
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
