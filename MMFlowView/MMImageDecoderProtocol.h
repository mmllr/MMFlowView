//
//  MMImageDecoderProtocol.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMImageDecoderProtocol <NSObject>

- (CGImageRef)newImageFromItem:(id)anItem withSize:(CGSize)imageSize;
- (NSImage*)imageFromItem:(id)anItem;

@end
