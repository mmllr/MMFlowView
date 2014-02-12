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

- (CGImageRef)imageForUUID:(NSString*)anUUID
{
	return (__bridge CGImageRef)([self.cache objectForKey:anUUID]);
}

- (void)cacheImage:(CGImageRef)anImage withUUID:(NSString*)anUUID
{
	[self.cache setObject:(__bridge id)(anImage) forKey:[anUUID copy]];
}

- (void)removeImageWithUUID:(NSString *)anUUID
{
	[self.cache removeObjectForKey:anUUID];
}

- (void)reset
{
	[self.cache removeAllObjects];
}

@end