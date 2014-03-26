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
//  MMFlowView+MMCoverFlowLayerDataSource.m
//
//  Created by Markus Müller on 11.03.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+MMCoverFlowLayerDataSource.h"
#import "MMFlowView_Private.h"
#import "MMFlowViewImageFactory.h"
#import "MMCoverFlowLayout.h"
#import "MMScrollBarLayer.h"
#import "MMFlowViewImageCache.h"

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
	[self.imageFactory cancelPendingDecodings];
}

- (void)coverFlowLayerDidRelayout:(MMCoverFlowLayer *)coverFlowLayer
{
	[self.scrollBarLayer setNeedsLayout];
}

- (void)coverFlowLayer:(MMCoverFlowLayer *)coverFlowLayer willShowLayer:(CALayer *)contentLayer atIndex:(NSUInteger)itemIndex
{
	id item = [self imageItemForIndex:itemIndex];
	NSString *itemUID = [self imageUIDForItem:item];

	CGImageRef cachedImage = [self.imageCache imageForUUID:itemUID];

	if (cachedImage != NULL && itemIndex != self.selectedIndex) {
		[self setImage:cachedImage forContentLayer:contentLayer];
		return;
	}

	self.imageFactory.maxImageSize = self.coverFlowLayout.itemSize;
	[self.imageFactory createCGImageFromRepresentation:[self imageRepresentationForItem:item]
											  withType:[self imageRepresentationTypeForItem:item]
									 completionHandler:^(CGImageRef anImage) {
										 [self setImage:anImage forContentLayer:contentLayer];
										 [self.imageCache cacheImage:anImage withUUID:itemUID];
										 if (itemIndex == self.selectedIndex) {
											 [self setupTrackingAreas];
										 }
	}];
}

- (void)setImage:(CGImageRef)image forContentLayer:(CALayer*)contentLayer
{
	contentLayer.contents = (__bridge id)(image);

	CGFloat width = CGImageGetWidth(image);
	CGFloat height = CGImageGetHeight(image);
	CGFloat aspectRatio = width / height;
	
	CGFloat scaleX = aspectRatio > 1 ? 1 : aspectRatio;
	CGFloat scaleY = aspectRatio > 1 ? 1 / aspectRatio : 1;
	CGAffineTransform aspectTransform = CGAffineTransformMakeScale(scaleX, scaleY);
	CGSize imageSize = CGSizeApplyAffineTransform(self.coverFlowLayout.itemSize, aspectTransform);
	contentLayer.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
}

@end
