//
//  CALayer+MMLayerAccessibilityDefaultHandlers.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 14.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "CALayer+MMLayerAccessibilityDefaultHandlers.h"
#import "CALayer+MMLayerAccessibilityPrivate.h"

@implementation CALayer (MMLayerAccessibilityDefaultHandlers)

#pragma mark - class methods

+ (NSArray*)defaultAccessibilityAttributes
{
	static NSArray *defaultAttributes = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultAttributes = @[NSAccessibilityParentAttribute, NSAccessibilitySizeAttribute, NSAccessibilityPositionAttribute, NSAccessibilityWindowAttribute, NSAccessibilityTopLevelUIElementAttribute, NSAccessibilityRoleAttribute, NSAccessibilityRoleDescriptionAttribute, NSAccessibilityEnabledAttribute, NSAccessibilityFocusedAttribute];
	});
	return defaultAttributes;
}

#pragma mark - default handlers

- (id)mm_defaultPositionAttributeHandler
{
	NSView *containingView = [self mm_containingView];
	CGPoint pointInView = [containingView.layer convertPoint:self.frame.origin
												   fromLayer:self.superlayer];
	NSPoint windowPoint = [containingView convertPoint:NSPointFromCGPoint(pointInView)
												toView:nil ];
	return [ NSValue valueWithPoint:[[containingView window ] convertRectToScreen:NSMakeRect(windowPoint.x, windowPoint.y, 1,1)].origin];
}

- (id)mm_defaultSizeAttributeHandler
{
	NSView *containingView = [self mm_containingView];
	return [NSValue valueWithSize:[containingView convertSizeFromBacking:self.bounds.size]];
}

- (id)mm_defaultParentAttributeHandler
{
	id parent = [self mm_accessibilityParent];
	if (parent) {
		return NSAccessibilityUnignoredAncestor(parent);
	}
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:@"No accessibility parent available"
								 userInfo:nil];
	return nil;
}

@end
