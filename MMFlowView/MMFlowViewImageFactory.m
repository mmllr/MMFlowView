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

@interface MMFlowViewImageFactory ()

@property (strong) NSDictionary *imageDecoders;
@property (strong) NSOperationQueue *operationQueue;

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
        _imageDecoders = [[self class] createImageDecoders];
    }
    return self;
}

- (void)dealloc
{
    [self.operationQueue cancelAllOperations];
}

#pragma mark - public API

- (BOOL)canDecodeRepresentationType:(NSString*)representationType
{
	return [self.imageDecoders valueForKey:representationType] != nil;
}

- (void)createCGImageForItem:(id)item withRepresentationType:(NSString*)representationType maximumSize:(CGSize)maxiumSize completionHandler:(void(^)(CGImageRef image))completionHandler
{
	NSParameterAssert(completionHandler != NULL);

	if ([self canDecodeRepresentationType:representationType]) {
		id<MMImageDecoderProtocol> decoder = self.imageDecoders[representationType];

		[self.operationQueue addOperationWithBlock:^{
			CGImageRef image = [decoder newImageFromItem:item withSize:maxiumSize];
			
			if (image) {
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					completionHandler(image);
					CGImageRelease(image);
				}];
			}
		}];
	}
}

- (void)imageForItem:(id)item withRepresentationType:(NSString *)representationType completionHandler:(void (^)(NSImage *))completionHandler
{
	NSParameterAssert(completionHandler != NULL);
	if ([self canDecodeRepresentationType:representationType]) {
		id<MMImageDecoderProtocol> decoder = self.imageDecoders[representationType];
		
		[self.operationQueue addOperationWithBlock:^{
			NSImage *image = [decoder imageFromItem:item];
			
			if (image) {
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					completionHandler(image);
				}];
			}
		}];
	}
}

@end
