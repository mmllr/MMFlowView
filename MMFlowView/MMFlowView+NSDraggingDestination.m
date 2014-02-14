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
	NSPoint pointInView = [ self convertPointFromBase:[ dragInfo draggingLocation ] ];
	NSUInteger draggedIndex = [ self indexOfItemAtPoint:pointInView ];
	
	if ( ( draggedIndex != NSNotFound ) &&
		[ self.dataSource respondsToSelector:@selector(flowView:acceptDrop:atIndex:) ] ) {
		return [ self.dataSource flowView:self
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
	if ( ( [ dragInfo draggingSource ] == self ) ) {
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
	NSPoint pointInView = [ self convertPointFromBase:[ dragInfo draggingLocation ] ];
	NSUInteger draggedIndex = [ self indexOfItemAtPoint:pointInView ];
	
	BOOL dragFromSelf = [ dragInfo draggingSource ] == self;
	if ( draggedIndex != NSNotFound ) {
		// no drag from self to selected index
		if ( dragFromSelf && draggedIndex == self.selectedIndex ) {
			return NSDragOperationNone;
		}
		//self.highlightedLayer = [ self imageLayerAtIndex:draggedIndex ];
		if ( [ self.dataSource respondsToSelector:@selector(flowView:validateDrop:proposedIndex:) ] ) {
			return [ self.dataSource flowView:self
								 validateDrop:dragInfo
								proposedIndex:draggedIndex ];
		}
	}
	else if ( !dragFromSelf ) {
		self.highlightedLayer = self.backgroundLayer;
	}
	return NSDragOperationNone;
}

@end
