//
//  MMFlowViewImageCache.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 02.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMFlowViewImageCache <NSObject>

- (CGImageRef)imageForUUID:(NSString*)anUUID;
- (void)cacheImage:(CGImageRef)anImage withUUID:(NSString*)anUUID;
- (void)reset;

@end

@interface MMFlowViewImageCache : NSObject <MMFlowViewImageCache>

@end
