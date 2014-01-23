//
//  NSAffineTransform+MMAdditions.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 23.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "NSAffineTransform+MMAdditions.h"

@implementation NSAffineTransform (MMAdditions)

+ (instancetype)affineTransformWithCGAffineTransform:(CGAffineTransform)cgTransform
{
	NSAffineTransform *transform = [self transform];
	NSAffineTransformStruct transformStruct = {cgTransform.a, cgTransform.b, cgTransform.c, cgTransform.d, cgTransform.tx, cgTransform.ty};
	[transform setTransformStruct:transformStruct];
	return transform;
}

- (CGAffineTransform)mm_CGAffineTransform
{
	NSAffineTransformStruct affineTransform = [self transformStruct];
	return CGAffineTransformMake(affineTransform.m11, affineTransform.m12, affineTransform.m21, affineTransform.m22, affineTransform.tX, affineTransform.tY);
}

@end
