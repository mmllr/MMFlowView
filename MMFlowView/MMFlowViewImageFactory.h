//
//  MMFlowViewImageFactory.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMFlowViewItem;
@protocol MMImageDecoderProtocol;
@protocol MMFlowViewImageCache;

@interface MMFlowViewImageFactory : NSObject

@property (nonatomic) CGSize maxImageSize;
@property (strong) id<MMFlowViewImageCache> cache;

- (BOOL)canDecodeRepresentationType:(NSString*)representationType;
- (id<MMImageDecoderProtocol>)decoderforRepresentationType:(NSString*)representationType;
- (void)setDecoder:(id<MMImageDecoderProtocol>)aDecoder forRepresentationType:(NSString*)representationType;
- (void)createCGImageForItem:(id<MMFlowViewItem>)anItem completionHandler:(void(^)(CGImageRef image))completionHandler;
- (void)imageForItem:(id<MMFlowViewItem>)anItem completionHandler:(void(^)(NSImage *image))completionHandler;

@end
