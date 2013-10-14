//
//  MMFlowView+NSAccessibility.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 07.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+NSAccessibility.h"
#import "MMFlowView_Private.h"
#import "CALayer+NSAccessibility.h"

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
	static NSMutableArray *attributes = nil;
	
	if ( !attributes ) {
		attributes = [[super accessibilityAttributeNames] mutableCopy];
		NSArray *appendedAttributes = @[NSAccessibilityChildrenAttribute, NSAccessibilityContentsAttribute, NSAccessibilityRoleAttribute, NSAccessibilityRoleDescriptionAttribute];
		
		for ( NSString *attribute in appendedAttributes ) {
			if ( ![attributes containsObject:attributes] ) {
				[attributes addObject:attribute];
			}
		}
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
		return NSAccessibilityUnignoredChildren( @[self.backgroundLayer, self.scrollBarLayer]  );
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityContentsAttribute ] ) {
		return @[self.backgroundLayer, self.scrollBarLayer];
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
	return hitLayer ? NSAccessibilityUnignoredAncestor( [hitLayer modelLayer] ) : self;
}

#endif
@end
