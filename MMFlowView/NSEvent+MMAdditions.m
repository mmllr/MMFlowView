//
//  NSEvent+MMAdditions.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 23.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "NSEvent+MMAdditions.h"

@implementation NSEvent (MMAdditions)

- (CGFloat)dominantDeltaInXYSpace
{
	if (fabs([self deltaX]) >= fabs([self deltaY])) {
		return [self deltaX];
	}
	return [self deltaY];
}

@end
