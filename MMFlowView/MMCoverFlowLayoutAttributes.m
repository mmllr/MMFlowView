//
//  MMCoverFlowLayoutAttributes.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayoutAttributes.h"

static const CGPoint kDefaultAnchorPoint = {.5, .5};

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
