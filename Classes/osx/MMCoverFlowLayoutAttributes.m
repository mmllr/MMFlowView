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
//  MMCoverFlowLayoutAttributes.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayoutAttributes.h"

@implementation MMCoverFlowLayoutAttributes

- (id)init
{
	[NSException raise:NSInternalInconsistencyException format:@"init not allowed, use designated initalizer initWithIndex:position:size:anchorPoint:transfrom:zPosition: instead"];
	return nil;
}

- (id)initWithIndex:(NSUInteger)anIndex position:(CGPoint)aPosition size:(CGSize)aSize anchorPoint:(CGPoint)anAnchorPoint transfrom:(CATransform3D)aTransform zPosition:(CGFloat)aZPosition
{
    self = [super init];
    if (self) {
		_index = anIndex;
        _transform = aTransform;
		_anchorPoint = anAnchorPoint;
		_position = aPosition;
		_bounds = CGRectMake(0, 0, aSize.width, aSize.height);
		_zPosition = aZPosition;
    }
    return self;
}

@end
