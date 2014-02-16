//
//  MMFlowView+NSDraggingDestination.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+NSDraggingDestination.h"
#import "MMFlowView_Private.h"

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
