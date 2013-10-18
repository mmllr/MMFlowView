//
//  MMCoverFlowLayout.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayout.h"

const CGSize kDefaultItemSize = { 50, 50 };
const CGFloat kDefaultInterItemSpacing = 10.;

@implementation MMCoverFlowLayout

- (id)init
{
    self = [super init];
    if (self) {
		self.interItemSpacing = kDefaultInterItemSpacing;
		self.itemSize = kDefaultItemSize;
    }
    return self;
}

@end
