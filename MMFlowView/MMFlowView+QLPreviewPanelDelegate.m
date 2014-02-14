//
//  MMFlowView+QLPreviewPanelDelegate.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+QLPreviewPanelDelegate.h"

@implementation MMFlowView (QLPreviewPanelDelegate)

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
	if ( [event type] == NSKeyDown ) {
		[ self keyDown:event ];
        [ panel reloadData ];
        return YES;
    }
	return NO;
}

- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item
{/*
  NSRect selectedItemRectInWindow = [ self convertRect:[ self rectInViewForLayer:[ self imageLayerAtIndex:self.selectedIndex ] ] toView:nil ];
  selectedItemRectInWindow.origin = [ [ self window ] convertBaseToScreen:selectedItemRectInWindow.origin ];
  return selectedItemRectInWindow;*/
	return NSZeroRect;
}

@end
