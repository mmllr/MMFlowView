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

- (BOOL)accessibilityIsIgnored
{
	return NO;
}

- (NSArray*)accessibilityAttributeNames
{
	static NSMutableArray *attributes = nil;
	
	if ( !attributes ) {
		attributes = [[super accessibilityAttributeNames] mutableCopy];
		NSArray *appendedAttributes = @[NSAccessibilityChildrenAttribute, NSAccessibilityContentsAttribute, NSAccessibilityRoleAttribute,  NSAccessibilityRoleDescriptionAttribute, NSAccessibilityHorizontalScrollBarAttribute];
		
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
		return NSAccessibilityUnignoredChildren( @[self.backgroundLayer] );
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityContentsAttribute ] ) {
		return @[self.coverFlowLayer];
	}
	else if ( [anAttribute isEqualToString:NSAccessibilityHorizontalScrollBarAttribute] ) {
		return self.scrollBarLayer;
	}
	return [ super accessibilityAttributeValue:anAttribute ];
}

- (id)accessibilityHitTest:(NSPoint)aPoint
{
	NSPoint windowPoint = [ [ self window ] convertScreenToBase:aPoint ];
    CGPoint localPoint = NSPointToCGPoint([ self convertPoint:windowPoint
													 fromView:nil ] );

	CALayer *hitLayer = [ self hitLayerAtPoint:localPoint ];
	return hitLayer ? NSAccessibilityUnignoredAncestor( hitLayer ) : self;
}

@end
