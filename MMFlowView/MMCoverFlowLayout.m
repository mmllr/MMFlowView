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
static const CGFloat kDefaultStackedDistance = 300;
static const CGFloat kDefaultVerticalMargin = 10.;
static const CGFloat kMinimumContentHeight = 1;

static NSString * const kContentHeightKey = @"contentHeight";
static NSString * const kInterItemSpacingKey = @"interItemSpacing";
static NSString * const kStackedAngleKey = @"stackedAngle";
static NSString * const kSelectedItemIndexKey = @"selectedItemIndex";
static NSString * const kNumberOfItemsKey = @"numberOfItems";
static NSString * const kStackedDistanceKey = @"stackedDistance";
static NSString * const kVerticalMarginKey = @"verticalMargin";

@interface MMCoverFlowLayout ()

@end

@implementation MMCoverFlowLayout

@dynamic contentWidth;
@dynamic itemSize;

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

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
		_contentHeight = [coder decodeDoubleForKey:kContentHeightKey];
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
		[aCoder encodeDouble:self.contentHeight forKey:kContentHeightKey];
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

- (CGFloat)contentWidth
{
	if ( !self.numberOfItems ) {
		return 0;
	}
	CGFloat itemWidth = self.itemSize.width;
	CGFloat cosStackedAngle = cos(self.stackedAngle * M_PI / 180.);
	CGFloat width = itemWidth + (cosStackedAngle*self.interItemSpacing + cosStackedAngle*itemWidth) * MAX( 0, (self.numberOfItems - 1 ));

	if ( self.selectedItemIndex == 0 ||
		self.selectedItemIndex == ( self.numberOfItems - 1 )) {
		width += self.interItemSpacing;
	}
	else {
		width += self.interItemSpacing * 2;
	}
	return width;
}

#pragma mark - public interface

- (MMCoverFlowLayoutAttributes*)layoutAttributesForItemAtIndex:(NSUInteger)itemIndex
{
	if ( itemIndex < self.numberOfItems ) {
		MMCoverFlowLayoutAttributes *attributes = [[MMCoverFlowLayoutAttributes alloc] init];
		attributes.index = itemIndex;
		CGFloat height = self.contentHeight - (self.verticalMargin * 2);
		attributes.bounds = CGRectMake(0, 0, height, height);
		attributes.position = [self originForItem:itemIndex];
		attributes.anchorPoint = CGPointMake(0, 0);
		if ( itemIndex < self.selectedItemIndex ) {
			// left stack
			attributes.transform = CATransform3DMakeRotation( self.stackedAngle * M_PI / 180., 0, 1, 0 );
			attributes.zPosition = -self.stackedDistance;
		}
		else if ( itemIndex > self.selectedItemIndex ) {
			// right stack
			attributes.transform = CATransform3DMakeRotation( -(self.stackedAngle * M_PI / 180.), 0, 1, 0 );
			attributes.zPosition = -self.stackedDistance;
		}
		else if ( itemIndex == self.selectedItemIndex ) {
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
	CGFloat itemWidth = self.itemSize.width;

	CGFloat cosStackedAngle = cos(self.stackedAngle * M_PI / 180.);
	CGFloat stackedWidth = itemWidth * cosStackedAngle + cosStackedAngle * self.interItemSpacing;
	CGFloat offset = stackedWidth * anIndex;

	BOOL firstItemSelected = ( self.selectedItemIndex == 0 );
	if ( ( anIndex == self.selectedItemIndex ) && !firstItemSelected ) {
		offset += itemWidth / 2.;
	}
	if ( anIndex > self.selectedItemIndex ) {
		offset += firstItemSelected ? itemWidth / 2. : itemWidth;
	}
	return offset;
}

@end
