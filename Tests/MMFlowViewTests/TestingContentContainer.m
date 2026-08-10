//
//  TestingContentContainer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 02.04.14.
//  Copyright (c) 2014 Markus Müller. All rights reserved.
//

#import "TestingContentContainer.h"

@implementation TestingContentContainer
{
	NSMutableArray *_items;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _items = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)items
{
	return [_items copy];
}

- (NSUInteger)countOfItems
{
	return [_items count];
}

- (id)objectInItemsAtIndex:(NSUInteger)anIndex {
    return [_items objectAtIndex:anIndex];
}

- (void)insertObject:(id)item inItemsAtIndex:(NSUInteger)anIndex {
    [_items insertObject:item
				 atIndex:anIndex];
}

- (void)removeObjectFromItemsAtIndex:(NSUInteger)anIndex {
    [_items removeObjectAtIndex:anIndex];
}

@end
