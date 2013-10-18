//
//  MMCoverFlowLayoutAttributes.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayoutAttributes.h"

const CGPoint kDefaultAnchorPoint = {.5, .5};

@implementation MMCoverFlowLayoutAttributes

- (id)init
{
    self = [super init];
    if (self) {
		_index = NSNotFound;
        _transform = CATransform3DIdentity;
		_anchorPoint = kDefaultAnchorPoint;
    }
    return self;
}

@end
