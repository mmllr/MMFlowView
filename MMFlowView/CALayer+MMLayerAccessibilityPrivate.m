//
//  CALayer+MMLayerAccessibilityPrivate.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 14.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <objc/runtime.h>
#import "CALayer+MMLayerAccessibilityPrivate.h"
#import "CALayer+MMLayerAccessibilityDefaultHandlers.h"

const void* kMMLayerAccessibilityParentViewKey = @"mm_AXParentView";

@implementation CALayer (MMLayerAccessibilityPrivate)

@dynamic mmAccessibilityAttributes;
@dynamic mmParameterizedAttributes;
@dynamic mmActionNames;

#pragma mark - private implementation

- (id(^)(void))mm_getterForAttribute:(NSString*)attribute
{
	return [self valueForKey:GETTER_ATTRIBUTE_KEY(attribute)];
}

- (void(^)(id))mm_setterForAttribute:(NSString*)attribute
{
	return [self valueForKey:SETTER_ATTRIBUTE_KEY(attribute)];
}

- (id(^)(id))mm_handlerForParameterizedAttribute:(NSString*)attribute
{
	return [self valueForKey:PARAMERTERIZED_ATTRIBUTE_KEY(attribute)];
}

- (id)mm_accessibilityParent
{
	return self.superlayer ? self.superlayer : [self mm_containingView];
}

- (NSView*)mm_containingView
{
	id parentView = nil;
	CALayer *layer = self;
	while ( layer ) {
		parentView = objc_getAssociatedObject(layer, kMMLayerAccessibilityParentViewKey );
		layer = layer.superlayer;
		if ( parentView ) {
			break;
		}
	}
	return parentView;
}

- (void)mm_addAXCustomAttributeName:(NSString*)anAttribute
{
	NSMutableArray *attributes = self.mmAccessibilityAttributes;
	if ( attributes == nil ) {
		self.mmAccessibilityAttributes = [NSMutableArray array];
	}
	if (![attributes containsObject:anAttribute]) {
		[self.mmAccessibilityAttributes addObject:anAttribute];
	}
}

- (void)mm_removeAXCustomAttribute:(NSString*)anAttribute
{
	[self.mmAccessibilityAttributes removeObject:anAttribute];
	[self.mmParameterizedAttributes removeObject:anAttribute];
	
}

- (void)mm_addAXActionName:(NSString*)action
{
	if (self.mmActionNames == nil) {
		self.mmActionNames = [NSMutableArray array];
	}
	if (![self.mmActionNames containsObject:action]) {
		[self.mmActionNames addObject:action];
	}
}

- (void)mm_addAXParameterizedAttributeName:(NSString*)attribute
{
	if ( self.mmParameterizedAttributes == nil ) {
		self.mmParameterizedAttributes = [NSMutableArray array];
	}
	if (![self.mmParameterizedAttributes containsObject:attribute]) {
		[self.mmParameterizedAttributes addObject:attribute];
	}
}

- (void(^)(void))mm_handlerForAction:(NSString*)action
{
	return [self valueForKey:ACTION_ATTRIBUTE_KEY(action)];
}

- (BOOL)mm_hasCustomAttributes
{
	return [self.mmAccessibilityAttributes count] > 0;
}

- (BOOL)mm_hasActions
{
	return [self.mmActionNames count] > 0;
}

- (BOOL)mm_hasParameterizedAttributes
{
	return [self.mmParameterizedAttributes count] > 0;
}

- (NSArray*)mm_attributeNames
{
	NSMutableArray *attributeNames = self.mmAccessibilityAttributes;
	BOOL hasChildrenAttribute = [attributeNames containsObject:NSAccessibilityChildrenAttribute];
	
	if (self.sublayers) {
		if ( !hasChildrenAttribute ) {
			[attributeNames addObject:NSAccessibilityChildrenAttribute];
		}
	}
	else if (hasChildrenAttribute) {
		[attributeNames removeObject:NSAccessibilityChildrenAttribute];
	}
	return [[[self class] defaultAccessibilityAttributes] arrayByAddingObjectsFromArray:attributeNames];
}

- (id)mm_handleCustomAttribute:(NSString*)anAttribute
{
	id (^attributeGetter)(void) = [self mm_getterForAttribute:anAttribute];
	if ( attributeGetter ) {
		return attributeGetter();
	}
	return nil;
}

@end
