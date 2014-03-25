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
//  CALayer+MMAdditions.m
//
//  Created by Markus Müller on 10.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "CALayer+MMAdditions.h"

@implementation CALayer (MMAdditions)

- (void)mm_enableImplicitAnimationForKey:(NSString *)key
{
	NSMutableDictionary *customActions = [NSMutableDictionary dictionaryWithDictionary:self.actions];
	[customActions removeObjectForKey:key];
	self.actions = [customActions copy];
}

- (void)mm_disableImplicitAnimationForKey:(NSString *)key
{
	NSMutableDictionary *customActions = [NSMutableDictionary dictionaryWithDictionary:self.actions];
	customActions[key] = [NSNull null];
	self.actions = [customActions copy];
}

- (void)mm_disableImplicitPositionAndBoundsAnimations
{
	[self mm_disableImplicitAnimationForKey:@"bounds"];
	[self mm_disableImplicitAnimationForKey:@"position"];
}

- (void)mm_enableImplicitPositionAndBoundsAnimations
{
	[self mm_enableImplicitAnimationForKey:@"position"];
	[self mm_enableImplicitAnimationForKey:@"bounds"];
}

- (CGRect)mm_boundingRect
{
	CGRect boundingRect = self.frame;

	for (CALayer *layer in self.sublayers) {
		boundingRect = CGRectUnion([layer mm_boundingRect], boundingRect);
	}
	return boundingRect;
}

@end
