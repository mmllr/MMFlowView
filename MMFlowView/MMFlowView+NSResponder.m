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

#ifndef CLAMP
#define CLAMP(value, lowerBound, upperbound) MAX( lowerBound, MIN( upperbound, value ))
#endif

@implementation MMFlowView (NSResponder)

+ (Class)cellClass
{
    return [NSActionCell class];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint locationInWindow = [ theEvent locationInWindow ];
	CGPoint mouseInView = NSPointToCGPoint( [ self convertPoint:locationInWindow fromView:nil ] );
	
	CALayer *hitLayer = [ self hitLayerAtPoint:mouseInView ];
	CALayer *knob = (self.scrollBarLayer.sublayers)[0];
	
	NSUInteger clickedIndex = [ self indexOfItemAtPoint:[ self convertPoint:locationInWindow fromView:nil ] ];
	
	// dragging only from selection
	if ( clickedIndex == self.selectedIndex ) {
		id item = [ self imageItemForIndex:clickedIndex ];
		NSString *representationType = [ self imageRepresentationTypeForItem:item ];
		id representation = [ self imageRepresentationForItem:item ];
		NSPasteboard *dragPBoard = [ NSPasteboard pasteboardWithName:NSDragPboard ];
		BOOL isURL = [ [ [ self class ] pathRepresentationTypes ] containsObject:representationType ];
		
		// ask imagecache for drag image
		NSImage *dragImage = [[NSImage alloc] initWithCGImage:[self.imageCache imageForUUID:[self imageUIDForItem:item]] size:NSSizeFromCGSize(hitLayer.bounds.size)];
		// double click handling
		if ( [ theEvent clickCount ] > 1 ) {
			if ( [ self.delegate respondsToSelector:@selector(flowView:itemWasDoubleClickedAtIndex:) ] ) {
				[ self.delegate flowView:self itemWasDoubleClickedAtIndex:clickedIndex ];
			}
			else if ( [ self action ] ) {
				[ self sendAction:self.action to:self.target ];
			}
			else if ( isURL ) {
				NSString *filePath = [ representation isKindOfClass:[ NSURL class ] ] ? [ representation path ] : representation;
				[ [ NSWorkspace sharedWorkspace ] openFile:filePath
												 fromImage:dragImage
														at:NSPointFromCGPoint(mouseInView)
													inView:self ];
			}
		}
		else {
			// dragging
			if ( [ self.dataSource respondsToSelector:@selector(flowView:writeItemAtIndex:toPasteboard:) ] ) {
				[ self.dataSource flowView:self
						  writeItemAtIndex:clickedIndex
							  toPasteboard:dragPBoard ];
			}
			else if ( isURL ) {
				NSURL *fileURL = [ representation isKindOfClass:[ NSURL class ] ] ? representation : [ NSURL fileURLWithPath:representation ];
				[ dragPBoard declareTypes:@[NSURLPboardType]
									owner:nil ];
				[ fileURL writeToPasteboard:dragPBoard ];
			}
			[ self dragImage:dragImage
						  at:self.selectedItemFrame.origin
					  offset:NSZeroSize
					   event:theEvent
				  pasteboard:dragPBoard
					  source:self
				   slideBack:YES ];
		}
	}
	else if ( clickedIndex != NSNotFound ) {
		self.selectedIndex = clickedIndex;
	}
	else if (hitLayer.modelLayer == self.scrollBarLayer) {
		CGPoint mouseInScrollBar = [ self.layer convertPoint:mouseInView toLayer:self.scrollBarLayer ];
		
		if ( mouseInScrollBar.x < knob.frame.origin.x ) {
			[ self moveLeft:self ];
		}
		else {
			[ self moveRight:self ];
		}
	}
	else if (hitLayer.modelLayer == self.scrollBarLayer) {
		self.mouseDownInKnob = [ self.layer convertPoint:mouseInView toLayer:knob ].x;
		self.draggingKnob = YES;
	}
	self.selectedLayer = hitLayer;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint locationInWindow = [ theEvent locationInWindow ];
	CGPoint mouseInView = NSPointToCGPoint( [ self convertPoint:locationInWindow fromView:nil ] );
	
	self.selectedLayer = [ self hitLayerAtPoint:mouseInView ];
	
	if ( self.draggingKnob ) {
		CALayer *knob = (self.scrollBarLayer.sublayers)[0];
		
		CGPoint mouseInScrollBar = [ self.layer convertPoint:mouseInView toLayer:self.scrollBarLayer ];
		CGFloat maxX = self.scrollBarLayer.bounds.size.width - knob.bounds.size.width;
		CGFloat scrollPoint = CLAMP( mouseInScrollBar.x - self.mouseDownInKnob, 0, maxX );
		self.selectedIndex = ( scrollPoint / maxX ) * self.numberOfItems;
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	self.draggingKnob = NO;
	if ( [ self.selectedLayer respondsToSelector:@selector(performClick:) ] ) {
		[ (id)self.selectedLayer performClick:self ];
	}
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
	NSPoint locationInWindow = [ theEvent locationInWindow ];
	NSUInteger clickedIndex = [ self indexOfItemAtPoint:[ self convertPoint:locationInWindow fromView:nil ] ];
	if ( [ self.delegate respondsToSelector:@selector(flowView:itemWasRightClickedAtIndex:withEvent:) ] &&
		(clickedIndex != NSNotFound ) ) {
		[ self.delegate flowView:self
	  itemWasRightClickedAtIndex:clickedIndex
					   withEvent:theEvent ];
	}
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	[ self mouseEnteredLayerAtIndex:self.selectedIndex ];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[ self mouseExitedLayerAtIndex:self.selectedIndex ];
}

- (void)keyDown:(NSEvent *)theEvent
{
	if ( self.canControlQuickLookPanel &&
		[[theEvent characters] isEqualToString:@" "]) {
		[self togglePreviewPanel:self];
	}
	[ super keyDown:theEvent ];
}

- (IBAction)moveLeft:(id)sender
{
	self.selectedIndex = self.selectedIndex - 1;
}

- (IBAction)moveRight:(id)sender
{
	self.selectedIndex = self.selectedIndex + 1;
}

- (void)swipeWithEvent:(NSEvent *)event
{
	self.selectedIndex = self.selectedIndex + ( fabs([ event deltaX ] )> fabs ( [ event deltaY ] ) ? [ event deltaX ] : [ event deltaY ] );
}

- (void)scrollWheel:(NSEvent *)event
{
	self.selectedIndex = self.selectedIndex + ( fabs([ event deltaX ] )> fabs ( [ event deltaY ] ) ? [ event deltaX ] : [ event deltaY ] );
}

@end
