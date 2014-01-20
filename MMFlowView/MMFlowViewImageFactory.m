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

static CGFloat const kDefaultMaxImageDimension = 100;

@interface MMFlowViewImageFactory ()

@property (strong) NSMutableDictionary *imageDecoders;
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

- (id<MMImageDecoderProtocol>)decoderforRepresentationType:(NSString*)representationType
{
	return nil;
}

- (void)setDecoder:(id<MMImageDecoderProtocol>)aDecoder forRepresentationType:(NSString*)representationType
{
	if (![aDecoder conformsToProtocol:@protocol(MMImageDecoderProtocol)]) {
		[NSException raise:NSInvalidArgumentException format:@"aDecoder %@ doesnt conform to MMImageDecoderProtocol", aDecoder];
	}
	if (representationType) {
		_imageDecoders[representationType] = aDecoder;
	}
}

- (BOOL)canDecodeRepresentationType:(NSString*)representationType
{
	return [self.imageDecoders valueForKey:representationType] != nil;
}

- (void)createCGImageForItem:(id<MMFlowViewItem>)anItem completionHandler:(void(^)(CGImageRef image))completionHandler
{
	NSParameterAssert(completionHandler != NULL);

	NSString *representationType = anItem.imageItemRepresentationType;
	if ([self canDecodeRepresentationType:representationType]) {
		id<MMImageDecoderProtocol> decoder = self.imageDecoders[representationType];

		[self.operationQueue addOperationWithBlock:^{
			CGImageRef image = [decoder newImageFromItem:anItem.imageItemRepresentation withSize:self.maxImageSize];
			
			if (image) {
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
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
		id<MMImageDecoderProtocol> decoder = self.imageDecoders[anItem.imageItemRepresentationType];

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

@end
