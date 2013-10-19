//
//  MMCoverFlowLayout.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayout.h"

static const CGSize kDefaultItemSize = { 50, 50 };
static const CGFloat kDefaultInterItemSpacing = 10.;
static const CGFloat kDefaultStackedAngle = 70.;
static const CGFloat kDefaultVerticalMargin = 50.;

@implementation MMCoverFlowLayout

#pragma mark - init/cleanup

- (id)init
{
    self = [super init];
    if (self) {
		_interItemSpacing = kDefaultInterItemSpacing;
		_itemSize = kDefaultItemSize;
		_stackedAngle = kDefaultStackedAngle;
		_selectedItemIndex = NSNotFound;
		_verticalMargin = kDefaultVerticalMargin;
    }
    return self;
}

#pragma mark - accessors

- (void)setItemSize:(CGSize)itemSize
{
	static const CGSize kMinimumItemSize = { 1, 1 };

	if ( ( itemSize.width >= kMinimumItemSize.width ) &&
		(itemSize.height >= kMinimumItemSize.height ) ) {
		_itemSize = itemSize;
	}
}

- (void)setInterItemSpacing:(CGFloat)interItemSpacing
{
	static const CGFloat kMinimumSpacing = 1;
	if ( interItemSpacing >= kMinimumSpacing ) {
		_interItemSpacing = interItemSpacing;
	}
}

- (void)setStackedAngle:(CGFloat)stackedAngle
{
	static const CGFloat kMaximumStackedAngle = 90.;

	_stackedAngle = MIN( MAX(0, stackedAngle), kMaximumStackedAngle );
}


@end
