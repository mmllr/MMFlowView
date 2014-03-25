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
//  MMCoverFlowLayout.m
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayoutAttributes.h"
#import "MMMacros.h"

static const CGFloat kDefaultContentHeight = 100;
static const CGFloat kDefaultInterItemSpacing = 10.;
static const CGFloat kDefaultStackedAngle = 70.;
static const CGFloat kDefaultStackedDistance = 300;
static const CGFloat kDefaultVerticalMargin = 10.;
static const CGFloat kMinimumContentHeight = 1;

static NSString * const kVisibleSizeKey = @"visibleSize";
static NSString * const kInterItemSpacingKey = @"interItemSpacing";
static NSString * const kStackedAngleKey = @"stackedAngle";
static NSString * const kSelectedItemIndexKey = @"selectedItemIndex";
static NSString * const kNumberOfItemsKey = @"numberOfItems";
static NSString * const kStackedDistanceKey = @"stackedDistance";
static NSString * const kVerticalMarginKey = @"verticalMargin";

@interface MMCoverFlowLayout ()

@end

@implementation MMCoverFlowLayout

@dynamic contentSize;
@dynamic itemSize;

#pragma mark - init/cleanup

- (id)init
{
	return [self initWithVisibleSize:CGSizeMake(kDefaultContentHeight, kDefaultContentHeight)];
}

- (id)initWithVisibleSize:(CGSize)visisbleSize
{
    self = [super init];
    if (self) {
		_visibleSize = CGSizeMake(MAX(kMinimumContentHeight, visisbleSize.width), MAX(kMinimumContentHeight, visisbleSize.height));
		_interItemSpacing = kDefaultInterItemSpacing;
		_stackedAngle = kDefaultStackedAngle;
		_selectedItemIndex = NSNotFound;
		_verticalMargin = kDefaultVerticalMargin;
		_stackedDistance = kDefaultStackedDistance;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
		_visibleSize = [coder decodeSizeForKey:kVisibleSizeKey];
		_interItemSpacing = [coder decodeDoubleForKey:kInterItemSpacingKey];
		_stackedAngle = [coder decodeDoubleForKey:kStackedAngleKey];
		_selectedItemIndex = [coder decodeIntegerForKey:kSelectedItemIndexKey];
		_numberOfItems = [coder decodeIntegerForKey:kNumberOfItemsKey];
		_stackedDistance = [coder decodeDoubleForKey:kStackedDistanceKey];
		_verticalMargin = [coder decodeDoubleForKey:kVerticalMarginKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if ( [aCoder isKindOfClass:[NSKeyedArchiver class]] ) {
		[aCoder encodeSize:self.visibleSize forKey:kVisibleSizeKey];
		[aCoder encodeDouble:self.interItemSpacing forKey:kInterItemSpacingKey];
		[aCoder encodeDouble:self.stackedAngle forKey:kStackedAngleKey];
		[aCoder encodeInteger:self.selectedItemIndex forKey:kSelectedItemIndexKey];
		[aCoder encodeInteger:self.numberOfItems forKey:kNumberOfItemsKey];
		[aCoder encodeDouble:self.stackedDistance forKey:kStackedDistanceKey];
		[aCoder encodeDouble:self.verticalMargin forKey:kVerticalMarginKey];
	}
	else {
        [NSException raise:NSInvalidArchiveOperationException format:@"Only supports NSKeyedArchiver coders"];
    }
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
	_verticalMargin = CLAMP(verticalMargin, 0, self.visibleSize.height);
}

- (void)setVisibleSize:(CGSize)visibleSize
{
	_visibleSize.width = MAX(kMinimumContentHeight, visibleSize.width);
	_visibleSize.height = MAX(kMinimumContentHeight, visibleSize.height);
}

- (CGSize)itemSize
{
	CGFloat height = self.visibleSize.height - self.verticalMargin * 2;
	return CGSizeMake(height, height);
}

- (CGSize)contentSize
{
	if ( !self.numberOfItems ) {
		return CGSizeZero;
	}
	CGFloat itemWidth = self.itemSize.width;
	CGFloat stackedWidth = (itemWidth * cos(DEGREES2RADIANS(self.stackedAngle))) + self.interItemSpacing;
	CGFloat width = itemWidth + stackedWidth * MAX( 0, (self.numberOfItems-1));

	if ( self.selectedItemIndex == 0 ||
		self.selectedItemIndex == (self.numberOfItems-1)) {
		width += itemWidth;
	}
	else {
		width += itemWidth*2;
	}
	return CGSizeMake(width, self.visibleSize.height - 2*self.verticalMargin);
}

#pragma mark - public interface

- (MMCoverFlowLayoutAttributes*)layoutAttributesForItemAtIndex:(NSUInteger)itemIndex
{
	if (itemIndex >= self.numberOfItems) {
		return nil;
	}
	BOOL isSelectedItem = (itemIndex == self.selectedItemIndex);
	return [[MMCoverFlowLayoutAttributes alloc] initWithIndex:itemIndex
													 position:[self originForItem:itemIndex]
														 size:self.itemSize
												  anchorPoint:CGPointMake(0.5, 0)
													transfrom:[self transformForItem:itemIndex]
													zPosition:isSelectedItem ? 0 : -self.stackedDistance];
}

#pragma mark - layout logic

- (CATransform3D)transformForItem:(NSUInteger)item
{
	if (item == self.selectedItemIndex) {
		return CATransform3DIdentity;
	}
	else if (item < self.selectedItemIndex) {
		return CATransform3DMakeRotation(DEGREES2RADIANS(self.stackedAngle), 0, 1, 0);
	}
	return CATransform3DMakeRotation(-DEGREES2RADIANS(self.stackedAngle), 0, 1, 0);
}

- (CGPoint)originForItem:(NSUInteger)itemIndex
{
	return CGPointMake( [self horizontalOffsetForItem:itemIndex], self.visibleSize.height/2 - self.itemSize.height / 2 );
}

- (NSUInteger)distanceForItemFormSelection:(NSUInteger)anIndex
{
	if (anIndex < self.selectedItemIndex) {
		return self.selectedItemIndex - anIndex;
	}
	else if (anIndex > self.selectedItemIndex) {
		return anIndex - self.selectedItemIndex;
	}
	return 0;
}

- (CGFloat)horizontalOffsetForItem:(NSUInteger)anIndex
{
	CGFloat itemWidth = self.itemSize.width;
	CGFloat halfItemWidth = itemWidth / 2;
	CGFloat stackedWidth = (itemWidth * cos(DEGREES2RADIANS(self.stackedAngle))) + self.interItemSpacing;
	CGRect visibleRect = {CGPointZero, self.visibleSize };
	CGFloat selectedLeftEdge = CGRectGetMidX(visibleRect) - halfItemWidth;
	CGFloat selectedRightEdge = CGRectGetMidX(visibleRect) + halfItemWidth;
	
	if (anIndex < self.selectedItemIndex) {
		return selectedLeftEdge - [self distanceForItemFormSelection:anIndex] * stackedWidth - itemWidth;
	}
	else if (anIndex > self.selectedItemIndex) {
		return selectedRightEdge + [self distanceForItemFormSelection:anIndex] * stackedWidth;
	}
	return selectedLeftEdge;
}

@end
