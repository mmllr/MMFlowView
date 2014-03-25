/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://github.com/mmllr All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this
 software and associated documentation files (the "Software"), to deal in the Software
 without restriction, including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies
 or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
 
 */
//
//  MMFlowView+NSAccessibility.m
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
	if ([anAttribute isEqualToString:NSAccessibilityRoleAttribute]) {
		return NSAccessibilityScrollAreaRole;
    }
	else if ([anAttribute isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
		return NSAccessibilityRoleDescriptionForUIElement(self);
    }
	else if ([anAttribute isEqualToString:NSAccessibilityChildrenAttribute ]) {
		return NSAccessibilityUnignoredChildren(@[self.coverFlowLayer, self.scrollBarLayer]);
    }
	else if ([anAttribute isEqualToString:NSAccessibilityContentsAttribute ]) {
		return @[self.coverFlowLayer];
	}
	else if ([anAttribute isEqualToString:NSAccessibilityHorizontalScrollBarAttribute]) {
		return self.scrollBarLayer;
	}
	return [super accessibilityAttributeValue:anAttribute];
}

- (id)accessibilityHitTest:(NSPoint)aPoint
{
	NSWindow *window = [self window];
	NSRect windowRect = [window convertRectFromScreen:NSMakeRect(aPoint.x, aPoint.y, 1, 1)];
    NSPoint localPoint = [[window contentView] convertPoint:windowRect.origin
													 toView:self];

	CALayer *hitLayer = [self hitLayerAtPoint:localPoint];
	return hitLayer ? NSAccessibilityUnignoredAncestor(hitLayer) : self;
}

@end
