//
//  MMCoverFlowLayout.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMCoverFlowLayoutAttributes;

@interface MMCoverFlowLayout : NSObject

@property (nonatomic, readonly) CGFloat contentWidth;
@property (nonatomic, readonly) CGSize itemSize;
@property (nonatomic) CGFloat contentHeight;
@property (nonatomic) CGFloat interItemSpacing;
@property (nonatomic) CGFloat stackedAngle;
@property (nonatomic) NSUInteger selectedItemIndex;
@property (nonatomic) NSUInteger numberOfItems;
@property (nonatomic) CGFloat stackedDistance;
@property (nonatomic) CGFloat verticalMargin;

- (id)initWithContentHeight:(CGFloat)contentHeight;
- (MMCoverFlowLayoutAttributes*)layoutAttributesForItemAtIndex:(NSUInteger)itemIndex;

@end
