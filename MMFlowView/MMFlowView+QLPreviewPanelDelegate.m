//
//  MMFlowView+QLPreviewPanelDelegate.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+QLPreviewPanelDelegate.h"
#import "MMFlowView_Private.h"

@implementation MMFlowView (QLPreviewPanelDelegate)

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
	if ([event type] != NSKeyDown) {
		return NO;
    }
	NSString *characters = [event charactersIgnoringModifiers];
	if ([characters length] == 0 || [characters length] > 1) {
		return NO;
	}
	unichar keyChar = [characters characterAtIndex:0];
	if (keyChar == NSLeftArrowFunctionKey || keyChar == NSRightArrowFunctionKey){
		[self keyDown:event];
		[panel reloadData];
		return YES;
	}
	return NO;
}

- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item
{
	NSRect rectInWindow = [self convertRect:self.selectedItemFrame
									 toView:nil];
	return [[self window] convertRectToScreen:rectInWindow];
}

@end
