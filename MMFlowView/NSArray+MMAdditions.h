//
//  NSArray+MMAdditions.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 23.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MMAdditions)

- (void)mm_addObserver:(NSObject *)observer forKeyPaths:(NSArray*)keyPaths context:(void *)context;
- (void)mm_removeObserver:(NSObject*)observer forKeyPaths:(NSArray*)keyPaths context:(void *)context;

@end
