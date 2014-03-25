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
//  MMFlowView+MMScrollBarDelegate.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 04.03.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+MMScrollBarDelegate.h"
#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayer.h"

@implementation MMFlowView (MMScrollBarDelegate)

- (void)scrollBarLayer:(MMScrollBarLayer *)scrollBarLayer knobDraggedToPosition:(CGFloat)positionInPercent
{
	if (scrollBarLayer != self.scrollBarLayer) {
		return;
	}
	NSUInteger draggedIndex = (self.numberOfItems - 1) * positionInPercent;
	self.selectedIndex = draggedIndex;
}

- (void)decrementClickedInScrollBarLayer:(MMScrollBarLayer *)scrollBarLayer
{
	if (scrollBarLayer != self.scrollBarLayer) {
		return;
	}
	[self moveLeft:self];
}

- (void)incrementClickedInScrollBarLayer:(MMScrollBarLayer *)scrollBarLayer
{
	if (scrollBarLayer != self.scrollBarLayer) {
		return;
	}
	[self moveRight:self];
}

- (CGFloat)contentSizeForScrollBarLayer:(MMScrollBarLayer *)scrollBarLayer
{
	return self.coverFlowLayout.contentSize.width;
}

- (CGFloat)visibleSizeForScrollBarLayer:(MMScrollBarLayer *)scrollBarLayer
{
	return CGRectGetWidth(self.coverFlowLayer.visibleRect);
}

- (CGFloat)currentKnobPositionInScrollBarLayer:(MMScrollBarLayer *)scrollBarLayer
{
	if (self.selectedIndex == NSNotFound) {
		return 0;
	}
	CGFloat position = self.selectedIndex;
	return position / MAX((self.numberOfItems - 1), 1);
}

@end
