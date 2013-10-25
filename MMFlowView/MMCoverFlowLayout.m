//
//  MMCoverFlowLayout.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayoutAttributes.h"

static const CGFloat kDefaultContentHeight = 100;
static const CGFloat kDefaultInterItemSpacing = 10.;
static const CGFloat kDefaultStackedAngle = 70.;
static const CGFloat kDefaultStackedDistance = 100;
static const CGFloat kDefaultVerticalMargin = 10.;
static const CGFloat kMinimumContentHeight = 1;

@interface MMCoverFlowLayout ()

@end

@implementation MMCoverFlowLayout

#pragma mark - init/cleanup

- (id)init
{
	return [self initWithContentHeight:kDefaultContentHeight];
}

- (id)initWithContentHeight:(CGFloat)contentHeight
{
    self = [super init];
    if (self) {
		_contentHeight = contentHeight < kMinimumContentHeight ? kMinimumContentHeight : contentHeight;
		_interItemSpacing = kDefaultInterItemSpacing;
		_stackedAngle = kDefaultStackedAngle;
		_selectedItemIndex = NSNotFound;
		_verticalMargin = kDefaultVerticalMargin;
		_stackedDistance = kDefaultStackedDistance;
    }
    return self;
}

#pragma mark - accessors

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

- (void)setSelectedItemIndex:(NSUInteger)selectedItemIndex
{
	if (_numberOfItems > 0 ) {
		if ( selectedItemIndex != NSNotFound) {
			_selectedItemIndex = MIN( self.numberOfItems - 1, selectedItemIndex );
		}
	}
	else {
		_selectedItemIndex = NSNotFound;
	}
}

- (void)updateSelection
{
	if ( _numberOfItems > 0 ) {
		if ( self.selectedItemIndex == NSNotFound ) {
			self.selectedItemIndex = 0;
		}
	}
	else {
		self.selectedItemIndex = NSNotFound;
	}
	
}

- (void)setNumberOfItems:(NSUInteger)numberOfItems
{
	if ( (numberOfItems != NSNotFound ) &&
		(_numberOfItems != numberOfItems ) ) {
		_numberOfItems = numberOfItems;
	}
	[self updateSelection];
}

- (void)setStackedDistance:(CGFloat)stackedDistance
{
	if ( stackedDistance >= 0 ) {
		_stackedDistance = stackedDistance;
	}
}

- (void)setVerticalMargin:(CGFloat)verticalMargin
{
	_verticalMargin = MAX( 0, MIN( verticalMargin, self.contentHeight) );
}

- (void)setContentHeight:(CGFloat)contentHeight
{
	if ( contentHeight >= kMinimumContentHeight ) {
		_contentHeight = contentHeight;
	}
}

- (CGSize)itemSize
{
	CGFloat height = self.contentHeight - self.verticalMargin * 2;
	return CGSizeMake(height, height);
}

#pragma mark - public interface

- (MMCoverFlowLayoutAttributes*)layoutAttributesForItemAtIndex:(NSUInteger)itemIndex
{
	if ( itemIndex < self.numberOfItems ) {
		MMCoverFlowLayoutAttributes *attributes = [[MMCoverFlowLayoutAttributes alloc] init];
		attributes.index = itemIndex;
		CGFloat height = self.contentHeight - (self.verticalMargin * 2);
		attributes.size = CGSizeMake(height, height);
		attributes.position = [self originForItem:itemIndex];

		if ( itemIndex < self.selectedItemIndex ) {
			// left stack
			attributes.transform = CATransform3DMakeRotation( self.stackedAngle * M_PI / 180., 0, 1, 0 );
			attributes.anchorPoint = CGPointMake(0, .5);
			attributes.zPosition = -self.stackedDistance;
		}
		else if ( itemIndex > self.selectedItemIndex ) {
			// right stack
			attributes.transform = CATransform3DMakeRotation( -(self.stackedAngle * M_PI / 180.), 0, 1, 0 );
			attributes.anchorPoint = CGPointMake(1, .5);
			attributes.zPosition = -self.stackedDistance;
		}
		else if ( itemIndex == self.selectedItemIndex ) {
			attributes.anchorPoint = CGPointMake(.5, .5);
		}
		return attributes;
	}
	return nil;
}

#pragma mark - layout logic

- (CGPoint)originForItem:(NSUInteger)itemIndex
{
	CGPoint origin = CGPointMake( [self horizontalOffsetForItem:itemIndex], self.contentHeight/2 - self.itemSize.height / 2 );
	return origin;
}

- (CGFloat)horizontalOffsetForItem:(NSUInteger)anIndex
{
	CGFloat cosStackedAngle = self.stackedAngle * M_PI / 180.;
	CGFloat stackedWidth = self.itemSize.width * cosStackedAngle + cosStackedAngle * self.interItemSpacing;
	CGFloat offset = stackedWidth * anIndex;
	
	return offset;
}

@end
