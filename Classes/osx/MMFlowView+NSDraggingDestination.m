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
//  MMFlowView+NSDraggingDestination.m
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+NSDraggingDestination.h"
#import "MMFlowView_Private.h"
#import "MMCoverFlowLayer.h"

@implementation MMFlowView (NSDraggingDestination)

- (BOOL)wantsPeriodicDraggingUpdates
{
	return NO;
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)dragInfo
{
	return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)dragInfo
{
	NSPoint pointInView = [self convertPointFromBacking:[dragInfo draggingLocation]];
	NSUInteger draggedIndex = [self indexOfItemAtPoint:pointInView];
	
	if ( (draggedIndex != NSNotFound) &&
		[self.dataSource respondsToSelector:@selector(flowView:acceptDrop:atIndex:)]) {
		return [self.dataSource flowView:self
							  acceptDrop:dragInfo
								 atIndex:draggedIndex ];
	}
	return NO;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)dragInfo
{
	self.highlightedLayer = nil;
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)dragInfo
{
	if (([dragInfo draggingSource] == self)) {
		return NSDragOperationNone;
	}
	self.highlightedLayer = self.backgroundLayer;
	return NSDragOperationNone;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	self.highlightedLayer = nil;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)dragInfo
{
	NSPoint pointInView = [self convertPointFromBacking:[dragInfo draggingLocation]];
	NSUInteger destinationIndex = [self indexOfItemAtPoint:pointInView];
	BOOL dragFromSelf = ([dragInfo draggingSource] == self);
	self.highlightedLayer = nil;

	if (dragFromSelf && destinationIndex == self.selectedIndex) {
		return NSDragOperationNone;
	}
	if (![self.dataSource respondsToSelector:@selector(flowView:validateDrop:proposedIndex:)]) {
		return NSDragOperationNone;
	}
	NSDragOperation operation = [self.dataSource flowView:self
							 validateDrop:dragInfo
							proposedIndex:destinationIndex];
	if (operation != NSDragOperationNone) {
		BOOL dragOnItem = destinationIndex != NSNotFound;
		self.highlightedLayer = dragOnItem ? self.coverFlowLayer.contentLayers[destinationIndex] : self.backgroundLayer;
	}
	return operation;
}

@end
