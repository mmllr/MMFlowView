//
//  MMFlowView+MMCoverFlowLayerDataSource.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 11.03.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+MMCoverFlowLayerDataSource.h"
#import "MMFlowView_Private.h"
#import "MMFlowViewImageFactory.h"
#import "MMCoverFlowLayout.h"
#import "MMScrollBarLayer.h"

@implementation MMFlowView (MMCoverFlowLayerDataSource)

- (CALayer*)coverFlowLayer:(MMCoverFlowLayer *)layer contentLayerForIndex:(NSUInteger)index
{
	CALayer *contentLayer = [CALayer layer];
	contentLayer.contents = (id)[[self class] defaultImage];
	contentLayer.contentsGravity = kCAGravityResizeAspectFill;
	return contentLayer;
}

- (void)coverFlowLayerWillRelayout:(MMCoverFlowLayer *)coverFlowLayer
{
}

- (void)coverFlowLayerDidRelayout:(MMCoverFlowLayer *)coverFlowLayer
{
	self.imageFactory.maxImageSize = self.layout.itemSize;
	[self.scrollBarLayer setNeedsLayout];
}

- (void)coverFlowLayer:(MMCoverFlowLayer *)coverFlowLayer willShowLayer:(CALayer *)contentLayer atIndex:(NSUInteger)idx
{
	[self.imageFactory createCGImageForItem:[self imageItemForIndex:idx]
						  completionHandler:^(CGImageRef image) {
							  contentLayer.contents = (__bridge id)(image);
						  }];
}

@end
