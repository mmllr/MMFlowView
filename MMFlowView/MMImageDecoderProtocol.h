//
//  MMImageDecoderProtocol.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMImageDecoderProtocol <NSObject>

@property NSUInteger maxPixelSize;

- (CGImageRef)newCGImageFromItem:(id)anItem;
- (NSImage*)imageFromItem:(id)anItem;

@end
