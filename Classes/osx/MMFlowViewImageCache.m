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
//  MMFlowViewImageCache.m
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