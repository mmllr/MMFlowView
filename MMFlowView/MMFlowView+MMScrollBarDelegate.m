//
//  MMFlowView+MMScrollBarDelegate.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 04.03.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+MMScrollBarDelegate.h"

@implementation MMFlowView (MMScrollBarDelegate)

- (void)scrollBarLayer:(MMScrollBarLayer *)scrollBarLayer knobDraggedToPosition:(CGFloat)positionInPercent
{
	if (scrollBarLayer != self.scrollBarLayer) {
		return;
	}
	NSUInteger draggedIndex = (self.numberOfItems - 1) * positionInPercent;
	self.selectedIndex = draggedIndex;
}

@end
