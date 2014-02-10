//
//  MMFlowViewImageCache.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 02.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMFlowViewImageCache <NSObject>

- (id)itemForUUID:(NSString*)anUUID;
- (void)cacheItem:(id)anItem withUUID:(NSString*)anUUID;

@end

@interface MMFlowViewImageCache : NSObject <MMFlowViewImageCache>

@end
