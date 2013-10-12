//
//  MMFlowView+NSAccessibility.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 07.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+NSAccessibility.h"
#import "MMLayerAccessibilityHelper.h"
#import "MMFlowView_Private.h"

NSString * const kMMFLowViewAccessibilityHelperKey = @"axHelper";

@implementation MMFlowView (NSAccessibility)

#pragma mark -
#pragma mark NSAccessibility protocol

#if 1

- (BOOL)accessibilityIsIgnored
{
	return NO;
}

- (NSArray*)accessibilityAttributeNames
{
	static NSArray *attributes = nil;
	if ( attributes == nil ) {
	    attributes = [ [ super accessibilityAttributeNames ] arrayByAddingObjectsFromArray:@[NSAccessibilityContentsAttribute] ];
	}
	return attributes;
}

- (id)accessibilityAttributeValue:(NSString *)anAttribute
{
	if ( [ anAttribute isEqualToString:NSAccessibilityRoleAttribute ] ) {
		return NSAccessibilityScrollAreaRole;
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityRoleDescriptionAttribute ] ) {
		return NSAccessibilityRoleDescriptionForUIElement(self);
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityChildrenAttribute ] ) {
		MMLayerAccessibilityHelper *axListHelper = [ self.backgroundLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];
		MMLayerAccessibilityHelper *axScrollBarHelper = [ self.scrollBarLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];
		
		return NSAccessibilityUnignoredChildren( @[axListHelper, axScrollBarHelper]  );
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityContentsAttribute ] ) {
		MMLayerAccessibilityHelper *axListHelper = [ self.backgroundLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];
		MMLayerAccessibilityHelper *axScrollBarHelper = [ self.scrollBarLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];
		
		return @[axListHelper, axScrollBarHelper];
	}
	else {
		return [ super accessibilityAttributeValue:anAttribute ];
    }
}

- (id)accessibilityHitTest:(NSPoint)aPoint
{
	NSPoint windowPoint = [ [ self window ] convertScreenToBase:aPoint ];
    CGPoint localPoint = NSPointToCGPoint([ self convertPoint:windowPoint
													 fromView:nil ] );
	
	CALayer *hitLayer = [ self hitLayerAtPoint:localPoint ];
	MMLayerAccessibilityHelper *axHelper = [ hitLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];
	return axHelper ? axHelper : self;
}

#endif
@end
