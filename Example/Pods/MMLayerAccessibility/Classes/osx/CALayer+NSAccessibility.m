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
//  CALayer+NSAccessibility.m
//  LayerAccessibility
//
//  Created by Markus Müller on 03.10.13.
//  Copyright (c) 2013 Markus Müller. All rights reserved.
//

#import "CALayer+NSAccessibility.h"
#import "CALayer+MMLayerAccessibilityPrivate.h"
#import "CALayer+MMLayerAccessibilityDefaultHandlers.h"
#import <objc/runtime.h>

@implementation NSView (MMLayerAccessibility)

- (void)setAccessiblityEnabledLayer:(CALayer*)layer
{
	NSParameterAssert(layer);

	objc_setAssociatedObject(layer, kMMLayerAccessibilityParentViewKey, self, OBJC_ASSOCIATION_ASSIGN);
	[self setLayer:layer];
	[self setWantsLayer:YES];
}

@end

@implementation CALayer (MMLayerAccessibility)

#pragma mark - NSAccessibility

- (BOOL)accessibilityIsIgnored
{
	if ([self mm_hasCustomAttributes]) {
		return NO;
	}
	if ([self mm_hasActions]) {
		return NO;
	}
	if ([self mm_hasParameterizedAttributes]) {
		return NO;
	}
	return YES;
}

- (NSArray*)accessibilityAttributeNames
{
	return [self mm_attributeNames];
}

- (id)accessibilityAttributeValue:(NSString*)anAttribute
{
	if (anAttribute == nil) {
		return nil;
	}
	id value = [self mm_handleCustomAttribute:anAttribute];
	if (value) {
		return value;
	}
	else if ([anAttribute isEqualToString:NSAccessibilityRoleAttribute]) {
		// default role
		return NSAccessibilityUnknownRole;
	}
	else if ([anAttribute isEqualToString:NSAccessibilityChildrenAttribute]) {
		return NSAccessibilityUnignoredChildren(self.sublayers);
	}
	else if ([anAttribute isEqualToString:NSAccessibilityParentAttribute]) {
		return [self mm_defaultParentAttributeHandler];
	}
	else if ([ anAttribute isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
		return NSAccessibilityRoleDescriptionForUIElement(self);
	}
	else if ([ anAttribute isEqualToString:NSAccessibilitySizeAttribute ]) {
		return [self mm_defaultSizeAttributeHandler];
	}
	else if ([anAttribute isEqualToString:NSAccessibilityPositionAttribute]) {
		return [self mm_defaultPositionAttributeHandler];
	}
	else if ([anAttribute isEqualToString:NSAccessibilityWindowAttribute]) {
		return [[self mm_accessibilityParent] accessibilityAttributeValue:NSAccessibilityWindowAttribute];
	}
	else if ([anAttribute isEqualToString:NSAccessibilityTopLevelUIElementAttribute] ) {
		return [[self mm_accessibilityParent] accessibilityAttributeValue:NSAccessibilityTopLevelUIElementAttribute];
	}
	else if ([anAttribute isEqualToString:NSAccessibilityFocusedAttribute]) {
		return @NO;
	}
	else if ([anAttribute isEqualToString:NSAccessibilityEnabledAttribute]) {
		return @YES;
	}
	return nil;
}

- (void)accessibilitySetValue:(id)value forAttribute:(NSString *)attribute
{
	void (^attributeSetter)(id) = [self mm_setterForAttribute:attribute];
	if (attributeSetter) {
		attributeSetter(value);
		NSAccessibilityPostNotification([self mm_containingView], NSAccessibilityValueChangedNotification);
	}
}

- (NSArray *)accessibilityActionNames
{
	return [self.mmActionNames copy];
}

- (void)accessibilityPerformAction:(NSString *)action
{
	void (^actionHandler)(void) = [self mm_handlerForAction:action];
	if ( actionHandler ) {
		actionHandler();
	}
}

- (NSString *)accessibilityActionDescription:(NSString *)action
{
	return NSAccessibilityActionDescription(action);
}

- (BOOL)accessibilityIsAttributeSettable:(NSString*)anAttribute
{
	return [self mm_setterForAttribute:anAttribute] != nil;
}

- (id)accessibilityHitTest:(NSPoint)point
{
	NSView *view = [self mm_containingView];
	NSWindow *window = [view window];
	NSPoint pointInWindow = [window convertScreenToBase:point];
	NSPoint pointInView = [view convertPoint:pointInWindow fromView:nil];

	CGPoint pointInLayer = [self convertPoint:pointInView fromLayer:view.layer];
	id hitLayer = [[self hitTest:pointInLayer] modelLayer];
	return [hitLayer accessibilityIsIgnored] ? NSAccessibilityUnignoredAncestor(hitLayer) : hitLayer;
}

- (id)accessibilityFocusedUIElement
{
	BOOL hasFocus = [[self accessibilityAttributeValue:NSAccessibilityFocusedUIElementAttribute] boolValue];
    if (!hasFocus) {
		for (id child in NSAccessibilityUnignoredChildren(self.sublayers)) {
			if ([[child accessibilityAttributeValue:NSAccessibilityFocusedUIElementAttribute] boolValue]) {
				return child;
			}
		}
		return NSAccessibilityUnignoredAncestor([self mm_accessibilityParent]);
	}
	return self;
}

- (NSArray *)accessibilityParameterizedAttributeNames
{
	return [self.mmParameterizedAttributes copy];
}

- (id)accessibilityAttributeValue:(NSString *)attribute forParameter:(id)parameter
{
	id (^attributeHandler)(id) = [self mm_handlerForParameterizedAttribute:attribute];
	return attributeHandler ? attributeHandler(parameter) : nil;
}

#pragma mark - public API

- (void)setReadableAccessibilityAttribute:(NSString*)attribute withBlock:(id(^)(void))handler
{
	NSParameterAssert(attribute);
	NSParameterAssert(handler);

	[self mm_addAXCustomAttributeName:attribute];
	[self setValue:handler
			forKey:GETTER_ATTRIBUTE_KEY(attribute)];
}

- (void)setParameterizedAccessibilityAttribute:(NSString*)parameterizedAttribute withBlock:(id(^)(id))handler
{
	NSParameterAssert(parameterizedAttribute);
	NSParameterAssert(handler);

	[self mm_addAXParameterizedAttributeName:parameterizedAttribute];
	[self setValue:handler
			 forKey:PARAMERTERIZED_ATTRIBUTE_KEY(parameterizedAttribute)];
}


- (void)setWritableAccessibilityAttribute:(NSString*)attribute readBlock:(id(^)(void))getter writeBlock:(void(^)(id))setter
{
	NSParameterAssert(getter);
	NSParameterAssert(setter);

	[self setReadableAccessibilityAttribute:attribute
					 withBlock:getter];

	if ( ![[[self class] defaultAccessibilityAttributes] containsObject:attribute] ) {
		[self setValue:setter
				forKey:SETTER_ATTRIBUTE_KEY(attribute)];
	}
}

- (void)removeAccessibilityAttribute:(NSString*)attribute
{
	NSParameterAssert(attribute);
	[self mm_removeAXCustomAttribute:attribute];
	[self setValue:nil forKey:GETTER_ATTRIBUTE_KEY(attribute)];
	[self setValue:nil forKey:SETTER_ATTRIBUTE_KEY(attribute)];
	[self setValue:nil forKey:PARAMERTERIZED_ATTRIBUTE_KEY(attribute)];
}

- (void)setAccessibilityAction:(NSString*)actionName withBlock:(void(^)(void))handler
{
	NSParameterAssert(actionName);
	NSParameterAssert(handler);
	[self mm_addAXActionName:actionName];
	[self setValue:handler
			forKey:ACTION_ATTRIBUTE_KEY(actionName)];
}

@end
