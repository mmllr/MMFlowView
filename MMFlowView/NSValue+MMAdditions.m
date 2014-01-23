//
//  NSValue+MMAdditions.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 23.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "NSValue+MMAdditions.h"

@implementation NSValue (MMAdditions)

+ (instancetype)valueWithCGAffineTransform:(CGAffineTransform)affineTransform
{
	NSValue *value = [self valueWithBytes:&affineTransform objCType:@encode(CGAffineTransform)];
	return value;
}

- (CGAffineTransform)CGAffineTransformValue
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	if (strcmp([self objCType], @encode(CGAffineTransform)) == 0) {
		[self getValue:&transform];
	}
	return transform;
}

@end
