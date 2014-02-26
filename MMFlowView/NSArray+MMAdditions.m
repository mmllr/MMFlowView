//
//  NSArray+MMAdditions.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 23.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "NSArray+MMAdditions.h"

@implementation NSArray (MMAdditions)

- (void)mm_addObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths context:(void *)context
{
	NSIndexSet *allIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self count])];
	for (NSString *keyPath in keyPaths) {
		if ([keyPath isEqual:[NSNull null]]) {
			continue;
		}
		[self addObserver:observer
	   toObjectsAtIndexes:allIndexes
			   forKeyPath:keyPath
				  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
				  context:context];
	}
}

- (void)mm_removeObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths context:(void *)context
{
	NSIndexSet *allIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self count])];
	for (NSString *keyPath in keyPaths) {
		if ([keyPath isEqual:[NSNull null]]) {
			continue;
		}
		[self removeObserver:observer fromObjectsAtIndexes:allIndexes forKeyPath:keyPath context:context];
	}
}

@end
