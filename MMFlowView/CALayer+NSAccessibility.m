//
//  CALayer+NSAccessibility.m
//  LayerAccessibility
//
//  Created by Markus Müller on 03.10.13.
//  Copyright (c) 2013 Markus Müller. All rights reserved.
//

#import "CALayer+NSAccessibility.h"
#import <objc/runtime.h>

static const void* kMMLayerAccessibilityParentViewKey = @"mm_AXParentView";

static NSString * const kGetterPrefix = @"get";
static NSString * const kSetterPrefix = @"set";
static NSString * const kParamerizedPrefix = @"param";
static NSString * const kActionPrefix = @"action";

#define PREFIX_STRING(PREFIX, STRING) [PREFIX stringByAppendingString:STRING]
#define PARAMERTERIZED_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(kParamerizedPrefix, ATTRIBUTE)
#define GETTER_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(kGetterPrefix, ATTRIBUTE)
#define SETTER_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(kSetterPrefix, ATTRIBUTE)
#define ACTION_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(kActionPrefix, ATTRIBUTE)

@implementation NSView (MMLayerAccessibility)

- (void)setAccessiblityEnabledLayer:(CALayer*)layer
{
	objc_setAssociatedObject(layer, kMMLayerAccessibilityParentViewKey, self, OBJC_ASSOCIATION_ASSIGN);
	[ self setLayer:layer ];
	[ self setWantsLayer:YES ];
}

@end

@interface CALayer (MMLayerAccessibilityAdditions)

@property (nonatomic, strong) NSMutableArray *mmAccessibilityAttributes;
@property (nonatomic, strong) NSMutableArray *mmParameterizedAttributes;
@property (nonatomic, strong) NSMutableArray *mmActionNames;
	
@end

@implementation CALayer (MMLayerAccessibilityAdditions)

@dynamic mmAccessibilityAttributes;
@dynamic mmParameterizedAttributes;
@dynamic mmActionNames;

@end

@implementation CALayer (MMLayerAccessibility)

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

- (id)accessibilityAttributeValue:(NSString*)anAttribute
{
	NSArray *customAttributes = self.mmAccessibilityAttributes;
	if ( [customAttributes containsObject:anAttribute] ) {
		id (^attributeGetter)(void) =  [self mm_getterForAttribute:anAttribute];
		if ( attributeGetter ) {
			return attributeGetter();
		}
	}
	else if ([anAttribute isEqualToString:NSAccessibilityRoleAttribute]) {
		// default role
		return NSAccessibilityUnknownRole;
	}
	else if ([anAttribute isEqualToString:NSAccessibilityChildrenAttribute]) {
		return NSAccessibilityUnignoredChildren(self.sublayers);
	}
	else if ([anAttribute isEqualToString:NSAccessibilityParentAttribute]) {
		id parent = [self mm_accessibilityParent];
		if (parent) {
			return NSAccessibilityUnignoredAncestor(parent);
		}
		NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
														 reason:@"No accessibility parent available"
													   userInfo:nil ];
		[exception raise];
	}
	else if ([ anAttribute isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
		return NSAccessibilityRoleDescriptionForUIElement(self);
	}
	else if ([ anAttribute isEqualToString:NSAccessibilitySizeAttribute ]) {
		NSView *containingView = [self mm_containingView];
		return [NSValue valueWithSize:[containingView convertSizeFromBacking:self.bounds.size]];
	}
	else if ([anAttribute isEqualToString:NSAccessibilityPositionAttribute]) {
		NSView *containingView = [self mm_containingView];
		CGPoint pointInView = [containingView.layer convertPoint:self.frame.origin
													   fromLayer:self.superlayer];
		NSPoint windowPoint = [containingView convertPoint:NSPointFromCGPoint(pointInView)
													toView:nil ];
		return [ NSValue valueWithPoint:[[containingView window ] convertRectToScreen:NSMakeRect(windowPoint.x, windowPoint.y, 1,1)].origin];
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


- (void)setWritableAccessibilityAttribute:(NSString*)attribute readBlock:(id(^)(void))getter writeBlock:(void(^)(id value))setter
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
