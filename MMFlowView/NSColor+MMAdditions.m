//
//  NSColor+MMAdditions.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 07.05.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "NSColor+MMAdditions.h"

@implementation NSColor (NSColorAdditions)

- (CGColorRef)mm_CGColor
{
	// Ensure that the color is in the "generic" RGB space so we can safely get the components
	NSColor *rgbColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	// Get the r, g, b, a components
	CGFloat colorComponents[4];
	[rgbColor getComponents:colorComponents];
	
	// Create the CGColor
	return (__bridge CGColorRef)((__bridge_transfer id)CGColorCreateGenericRGB( colorComponents[0],
													colorComponents[1],
													colorComponents[2],
													colorComponents[3]));
}

@end
