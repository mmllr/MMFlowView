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
//  MMFlowViewImageLayer.m
//
//  Created by Markus Müller on 29.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMFlowViewImageLayer.h"

static NSString * const kLayerName = @"MMFlowViewContentLayerImage";
static NSString * const kContentsKey = @"contents";
static NSString * const kBoundsKey = @"bounds";

@implementation MMFlowViewImageLayer

@dynamic index;

#pragma mark - class methods

+ (id < CAAction >)defaultActionForKey:(NSString *)key
{
	if ([key isEqualToString:kCAOnOrderOut]) {
		CATransition *fadeTransition = [CATransition animation];
		fadeTransition.duration = .5;
		fadeTransition.type = kCATransitionFade;
		return fadeTransition;
	}
	else if ( [key isEqualToString:kCAOnOrderIn] ) {
		CATransition *transition = [CATransition animation];
		transition.duration = .5;
		transition.type = kCATransitionReveal;
		return transition;
	}
	else if ( [key isEqualToString:kContentsKey] ||
			 [key isEqualToString:kBoundsKey] ) {
		return nil;
	}
	return [super defaultActionForKey:key];
}

#pragma mark - init

- (id)init
{
	[ NSException raise:NSInternalInconsistencyException format:@"init not allowed, use designated initalizer initWithIndex: instead"];
	return nil;
}

- (id)initWithIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
		self.index = index;
        self.name = kLayerName;
		self.contentsGravity = kCAGravityResizeAspect;
		self.layoutManager = [CAConstraintLayoutManager layoutManager];
    }
    return self;
}

#pragma mark - MMFlowViewContentLayerProtocol

- (void)setContentValue:(id)content
{
	self.contents = content;
}

@end
