//
//  MMCoverFlowLayout.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMCoverFlowLayout : NSObject

@property (nonatomic, readonly) CGSize contentSize;
@property (nonatomic)  CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacing;
@property (nonatomic) CGFloat stackedAngle;
@property NSUInteger selectedItemIndex;
@property NSUInteger numberOfItems;
@property CGFloat verticalMargin;

@end
