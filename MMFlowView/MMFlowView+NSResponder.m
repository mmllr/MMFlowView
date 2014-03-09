//
//  MMFlowView+NSResponder.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+NSResponder.h"
#import "MMFlowView_Private.h"
#import "MMFlowViewImageCache.h"
#import "MMScrollBarLayer.h"
#import "NSEvent+MMAdditions.h"

@implementation MMFlowView (NSResponder)

#pragma mark - class methods

+ (Class)cellClass
{
    return [NSActionCell class];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

#pragma mark - NSResponder overrides

- (void)mouseDown:(NSEvent *)theEvent
{
	[self handleScrollBarClick:theEvent];
	[self handleItemClick:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint locationInWindow = [theEvent locationInWindow];
	CGPoint mouseInView = NSPointToCGPoint([self convertPoint:locationInWindow fromView:nil]);

	CGPoint pointInScrollBarLayer = [self.layer convertPoint:mouseInView toLayer:self.scrollBarLayer];

	[self.scrollBarLayer mouseDraggedToPoint:pointInScrollBarLayer];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[self.scrollBarLayer endDrag];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
	if (![self.delegate respondsToSelector:@selector
		(flowView:itemWasRightClickedAtIndex:withEvent:)]) {
		return;
	}
	NSPoint pointInView = [self convertPoint:[theEvent locationInWindow]
									fromView:nil];
	NSUInteger clickedIndex = [self indexOfItemAtPoint:pointInView];

	if (clickedIndex == NSNotFound) {
		return;
	}
	[self.delegate flowView:self itemWasRightClickedAtIndex:clickedIndex withEvent:theEvent];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	[self mouseEnteredSelection];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[self mouseExitedSelection];
}

- (void)keyDown:(NSEvent *)theEvent
{
	if (self.canControlQuickLookPanel &&
		[[theEvent characters] isEqualToString:@" "]) {
		[self togglePreviewPanel:self];
	}
	[super keyDown:theEvent];
}

- (IBAction)moveLeft:(id)sender
{
	self.selectedIndex -= 1;
}

- (IBAction)moveRight:(id)sender
{
	self.selectedIndex += 1;
}

- (void)swipeWithEvent:(NSEvent *)event
{
	[self changeSelectionFromEvent:event];
}

- (void)scrollWheel:(NSEvent *)event
{
	[self changeSelectionFromEvent:event];
}

#pragma mark - helpers

- (void)changeSelectionFromEvent:(NSEvent *)event
{
	self.selectedIndex += event.dominantDeltaInXYSpace;
}

- (void)scrollBarClicked:(CGPoint)mouseInView
{
	CGPoint pointInScrollBarLayer = [[self layer] convertPoint:mouseInView toLayer:self.scrollBarLayer];
	[self.scrollBarLayer mouseDownAtPoint:pointInScrollBarLayer];
}

- (CGRect)scrollBarFrame
{
	return [self.layer convertRect:self.scrollBarLayer.frame fromLayer:self.scrollBarLayer.superlayer];
}

- (void)handleItemClick:(NSEvent*)theEvent
{
	CGPoint mouseInView = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow]
													 fromView:nil]);

	NSUInteger clickedItemIndex = [self indexOfItemAtPoint:mouseInView];
	if (clickedItemIndex == NSNotFound) {
		return;
	}
	if (clickedItemIndex != self.selectedIndex) {
		self.selectedIndex = clickedItemIndex;
		return;
	}
	[self singleClickOnSelectionWithEven:theEvent];
}

- (void)handleScrollBarClick:(NSEvent*)theEvent
{
	CGPoint mouseInView =  NSPointToCGPoint([self convertPoint:[theEvent locationInWindow]
													  fromView:nil]);
	if (CGRectContainsPoint([self scrollBarFrame], mouseInView)) {
		[self scrollBarClicked:mouseInView];
	}
}

- (void)singleClickOnSelectionWithEven:(NSEvent *)theEvent
{
	if ([self initiateDragFromSelection]) {
		[self dragImage:[self draggedImageForSelection]
					 at:self.selectedItemFrame.origin
				 offset:NSZeroSize
				  event:theEvent
			 pasteboard:[NSPasteboard pasteboardWithName:NSDragPboard]
				 source:self
			  slideBack:YES];
	}
}

- (NSImage*)draggedImageForSelection
{
	id item = [self imageItemForIndex:self.selectedIndex];
	CGImageRef imageRef = [self.imageCache imageForUUID:[self imageUIDForItem:item]];
	return [[NSImage alloc] initWithCGImage:imageRef
									   size:self.selectedItemFrame.size];
}

- (BOOL)initiateDragFromSelection
{
	if ([self.dataSource respondsToSelector:@selector(flowView:writeItemAtIndex:toPasteboard:)]) {
		return [self.dataSource flowView:self writeItemAtIndex:self.selectedIndex toPasteboard:[NSPasteboard pasteboardWithName:NSDragPboard]];
	}
	return [self dragURLFromSelection];
}

- (BOOL)dragURLFromSelection
{
	NSURL *url = self.urlFromSelection;

	if (!url) {
		return NO;
	}
	NSPasteboard *dragBoard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[dragBoard declareTypes:@[NSURLPboardType] owner:nil];
	[url writeToPasteboard:dragBoard];
	return YES;
}

- (NSURL*)urlFromSelection
{
	id item = [self imageItemForIndex:self.selectedIndex];
	
	if (![[self.class pathRepresentationTypes] containsObject:[self imageRepresentationTypeForItem:item]]) {
		return nil;
	}
	id representation = [self imageRepresentationForItem:item];
	return [representation isKindOfClass:[NSURL class]] ? representation : [NSURL fileURLWithPath:representation];
}

@end
