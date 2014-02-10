//
//  MMFlowViewImageCache.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 02.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowViewImageCache.h"

@interface MMFlowViewImageCache ()

@property (strong) NSCache *cache;

@end

@implementation MMFlowViewImageCache


- (id)init
{
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (id)itemForUUID:(NSString*)anUUID
{
	return [self.cache objectForKey:anUUID];
}

- (void)cacheItem:(id)anItem withUUID:(NSString*)anUUID
{
	[self.cache setObject:anItem forKey:[anUUID copy]];
}

@end