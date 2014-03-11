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
