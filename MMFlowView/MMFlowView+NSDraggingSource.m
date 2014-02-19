//
//  MMFlowView+NSDraggingSource.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+NSDraggingSource.h"

@implementation MMFlowView (NSDraggingSource)

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
	if ([self.delegate respondsToSelector:@selector(flowView:draggingSession:sourceOperationMaskForDraggingContext:)]) {
		return [self.delegate flowView:self draggingSession:session sourceOperationMaskForDraggingContext:context];
	}
	return NSDragOperationNone;
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
	if ((operation & NSDragOperationDelete) && [self.dataSource respondsToSelector:@selector(flowView:removeItemAtIndex:)]) {
		[ self.dataSource flowView:self
				 removeItemAtIndex:self.selectedIndex ];
	}
}

@end
