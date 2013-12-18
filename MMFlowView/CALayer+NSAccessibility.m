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
//static const void* kCustomAccessibilityAttributeNamesKey = @"mm_CustomAccessibilityAttributeNames";

static NSString * const kCustomAccessibilityAttributeNamesKey = @"MMCustomAccessibilityAttributeNames";
static NSString * const kAccessibilityCachedAttributeNamesKey = @"MMAccessibilityCachedAttributeNamesKey";
static NSString * const kCustomAccessibilityActionNamesKey = @"MMCustomAccessibilityActionNames";
static NSString * const kCustomAccessibilityParameterizedAttributeNamesKey = @"MMCustomAccessibilityParameterizedAttributeNames";

@implementation NSView (MMLayerAccessibility)

- (void)setAccessiblityEnabledLayer:(CALayer*)layer
{
	objc_setAssociatedObject(layer, kMMLayerAccessibilityParentViewKey, self, OBJC_ASSOCIATION_ASSIGN);
	[ self setLayer:layer ];
	[ self setWantsLayer:YES ];
}

@end

@interface CALayer (MMLayerAccessibilityAdditions)

@property (readonly, nonatomic) BOOL hasCustomAccessibilityAttributes;

@end

@implementation CALayer (NSAccessibility)

#pragma mark - class methods

+ (NSSet*)defaultAccessibilityAttributes
{
	static NSSet *defaultAttributes = nil;

	if ( !defaultAttributes ) {
		defaultAttributes = [NSSet setWithObjects:NSAccessibilityParentAttribute, NSAccessibilitySizeAttribute, NSAccessibilityPositionAttribute, NSAccessibilityWindowAttribute, NSAccessibilityTopLevelUIElementAttribute, NSAccessibilityRoleAttribute, NSAccessibilityRoleDescriptionAttribute, NSAccessibilityEnabledAttribute, NSAccessibilityFocusedAttribute, nil];
	}
	return defaultAttributes;
}

#pragma mark - NSAccessibility

- (BOOL)accessibilityIsIgnored
{
	if ( [self mm_hasCustomAttributes] ) {
		return NO;
	}
	if ( [self mm_hasActions] ) {
		return NO;
	}
	if ( [self mm_hasParameterizedAttributes] ) {
		return NO;
	}
	return YES;
}

- (NSArray*)accessibilityAttributeNames
{
	NSMutableArray *cachedAttributeNames = [self mm_cachedAttributeNames];
	BOOL hasChildrenAttribute = [cachedAttributeNames containsObject:NSAccessibilityChildrenAttribute];

	if ( self.sublayers ) {
		if ( !hasChildrenAttribute ) {
			[cachedAttributeNames addObject:NSAccessibilityChildrenAttribute];
		}
	}
	else if ( hasChildrenAttribute ) {
		[cachedAttributeNames removeObject:NSAccessibilityChildrenAttribute];
	}
	return cachedAttributeNames;
}

- (id)accessibilityAttributeValue:(NSString*)anAttribute
{
	NSSet *customAttributes = [self mm_customAccessibilityAttributes];
	if ( [customAttributes containsObject:anAttribute] ) {
		id (^attributeGetter)(void) =  [self mm_getterForAttribute:anAttribute];
		if ( attributeGetter ) {
			return attributeGetter();
		}
	}
	else if ( [anAttribute isEqualToString:NSAccessibilityRoleAttribute] ) {
		// default role
		return NSAccessibilityUnknownRole;
	}
	else if ( [ anAttribute isEqualToString:NSAccessibilityChildrenAttribute ] ) {
		return NSAccessibilityUnignoredChildren(self.sublayers);
	}
	else if ( [ anAttribute isEqualToString:NSAccessibilityParentAttribute ] ) {
		id parent = [ self mm_accessibilityParent ];

		if ( !parent ) {
			NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
															 reason:@"No accessibility parent available"
														   userInfo:nil ];
			[exception raise];
		}
		return NSAccessibilityUnignoredAncestor(parent);
	}
	else if ( [ anAttribute isEqualToString:NSAccessibilityRoleDescriptionAttribute] ) {
		return NSAccessibilityRoleDescriptionForUIElement(self);
	}
	else if ( [ anAttribute isEqualToString:NSAccessibilitySizeAttribute ] ) {
		NSView *containingView = [ self mm_containingView ];

		return [ NSValue valueWithSize:[containingView convertSizeFromBacking:self.bounds.size] ];
	}
	else if ( [anAttribute isEqualToString:NSAccessibilityPositionAttribute] ) {
		NSView *containingView = [self mm_containingView];

		CGPoint pointInView = [containingView.layer convertPoint:self.frame.origin
													   fromLayer:self.superlayer ? self.superlayer : nil ];
		NSPoint windowPoint = [containingView convertPoint:NSPointFromCGPoint(pointInView)
													toView:nil ];
		return [ NSValue valueWithPoint:[[containingView window ] convertRectToScreen:NSMakeRect(windowPoint.x, windowPoint.y, 1,1)].origin];
	}
	else if ( [anAttribute isEqualToString:NSAccessibilityWindowAttribute] ) {
		return [[self mm_accessibilityParent] accessibilityAttributeValue:NSAccessibilityWindowAttribute];
	}
	else if ( [anAttribute isEqualToString:NSAccessibilityTopLevelUIElementAttribute] ) {
		return [[self mm_accessibilityParent] accessibilityAttributeValue:NSAccessibilityTopLevelUIElementAttribute];
	}
	else if ( [anAttribute isEqualToString:NSAccessibilityFocusedAttribute] ) {
		return @NO;
	}
	else if ( [anAttribute isEqualToString:NSAccessibilityEnabledAttribute] ) {
		return @YES;
	}
	return nil;
}

- (void)accessibilitySetValue:(id)value forAttribute:(NSString *)attribute
{
	NSSet *customAttributes = [self mm_customAccessibilityAttributes];
	if ( [customAttributes containsObject:attribute] ) {
		void (^attributeSetter)(id) = [self mm_setterForAttribute:attribute];
		if ( attributeSetter ) {
			attributeSetter(value);
			NSAccessibilityPostNotification(self, NSAccessibilityValueChangedNotification);
		}
	}
}

- (NSArray *)accessibilityActionNames
{
	NSSet *actionNames = [ self valueForKey:kCustomAccessibilityActionNamesKey];

	return actionNames ? [ actionNames allObjects ] : @[];
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
	return [self modelLayer];
}

- (id)accessibilityFocusedUIElement
{
    return NSAccessibilityUnignoredAncestor( self );
}

- (NSArray *)accessibilityParameterizedAttributeNames
{
	NSArray *names = [[self valueForKey:kCustomAccessibilityParameterizedAttributeNamesKey] allObjects];
	return names ? names : @[];
}

- (id)accessibilityAttributeValue:(NSString *)attribute forParameter:(id)parameter
{
	id (^attributeHandler)(id) = [self mm_handlerForParameterizedAttribute:attribute];
	return attributeHandler ? attributeHandler(parameter) : nil;
}

#pragma mark - private implementation

- (id(^)(void))mm_getterForAttribute:(NSString*)attribute
{
	return [self valueForKey:[self mm_getterKeyForAttribute:attribute]];
}

- (void(^)(id))mm_setterForAttribute:(NSString*)attribute
{
	return [self valueForKey:[self mm_setterKeyForAttribute:attribute]];
}

- (id(^)(id))mm_handlerForParameterizedAttribute:(NSString*)attribute
{
	return [self valueForKey:[self mm_getterKeyForParameterizedAttribute:attribute]];
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

- (void)mm_addAXCustomAttributeName:(NSString*)attribute
{
	NSSet *customAttributes = [self mm_customAccessibilityAttributes];

	if ( !customAttributes ) {
		customAttributes = [NSSet setWithObject:attribute];
	}
	else {
		NSMutableSet *mutableAttributeNames = [customAttributes mutableCopy];
		[mutableAttributeNames addObject:attribute];
		customAttributes = [mutableAttributeNames copy];
	}
	[self mm_setCustomAccessibilityAttributes:customAttributes];
	NSMutableArray *cachedAttributes = [self mm_cachedAttributeNames];
	if (![cachedAttributes containsObject:attribute]) {
		[cachedAttributes addObject:attribute];
	}
}

- (void)mm_removeAXCustomAttributeName:(NSString*)attribute
{
	NSSet *customAttributes = [self mm_customAccessibilityAttributes];
	if ( [customAttributes containsObject:attribute] ) {
		NSMutableSet *mutableAttributeNames = [customAttributes mutableCopy];
		[ mutableAttributeNames removeObject:attribute];
		[self mm_setCustomAccessibilityAttributes:[mutableAttributeNames copy]];
	}
	NSMutableArray *cachedAttributes = [self mm_cachedAttributeNames];
	if ([cachedAttributes containsObject:attribute] && ![[[self class] defaultAccessibilityAttributes] containsObject:attribute]) {
		[cachedAttributes removeObject:attribute];
	}
}

- (void)mm_addAXActionName:(NSString*)action
{
	NSSet *customActions = [ self valueForKey:kCustomAccessibilityActionNamesKey ];
	
	if ( !customActions ) {
		customActions = [NSSet setWithObject:action];
	}
	else {
		NSMutableSet *mutableActionNames = [customActions mutableCopy];
		[mutableActionNames addObject:action];
		customActions = [mutableActionNames copy];
	}
	[self setValue:customActions
			forKey:kCustomAccessibilityActionNamesKey];
}

- (void)mm_addAXParameterizedAttributeName:(NSString*)attribute
{
	NSSet *customAttributes = [self valueForKey:kCustomAccessibilityParameterizedAttributeNamesKey];
	
	if ( !customAttributes ) {
		customAttributes = [NSSet setWithObject:attribute];
	}
	else {
		NSMutableSet *mutableAttributesNames = [customAttributes mutableCopy];
		[mutableAttributesNames addObject:attribute];
		customAttributes = [mutableAttributesNames copy];
	}
	[self setValue:customAttributes
			forKey:kCustomAccessibilityParameterizedAttributeNamesKey];
}

- (NSString*)mm_getterKeyForAttribute:(NSString *)attribute
{
	static NSString * const kGetterPrefix = @"get";

	return [kGetterPrefix stringByAppendingString:attribute];
}

- (NSString*)mm_getterKeyForParameterizedAttribute:(NSString*)attribute
{
	static NSString * const kGetterPrefix = @"parameterized";
	
	return [kGetterPrefix stringByAppendingString:attribute];
}

- (NSString*)mm_setterKeyForAttribute:(NSString *)attribute
{
	static NSString * const kSetterPrefix = @"set";

	return [kSetterPrefix stringByAppendingString:attribute];
}

- (NSString*)mm_keyForAction:(NSString*)action
{
	static NSString * const kActionPrefix = @"action";
	return [ kActionPrefix stringByAppendingString:action];
}

- (void(^)(void))mm_handlerForAction:(NSString*)action
{
	return [self valueForKey:[self mm_keyForAction:action]];
}

- (BOOL)mm_hasCustomAttributes
{
	return [[self mm_customAccessibilityAttributes] count] > 0;
}

- (BOOL)mm_hasActions
{
	return [[self valueForKey:kCustomAccessibilityActionNamesKey] count] > 0;
}

- (BOOL)mm_hasParameterizedAttributes
{
	return [[self valueForKey:kCustomAccessibilityParameterizedAttributeNamesKey] count] > 0;
}

- (NSMutableArray*)mm_cachedAttributeNames
{
	NSMutableArray *cachedAttributeNames = [self valueForKey:kAccessibilityCachedAttributeNamesKey];
	if ( !cachedAttributeNames ) {
		cachedAttributeNames = [NSMutableArray arrayWithArray:[[[self class] defaultAccessibilityAttributes] allObjects]];
		[self setValue:cachedAttributeNames forKey:kAccessibilityCachedAttributeNamesKey];
	}
	return cachedAttributeNames;
}

- (NSSet*)mm_customAccessibilityAttributes
{
	//return objc_getAssociatedObject(self, kCustomAccessibilityAttributeNamesKey);
	return [self valueForKey:kCustomAccessibilityAttributeNamesKey];
}


- (void)mm_setCustomAccessibilityAttributes:(NSSet*)attributes
{
	//objc_setAssociatedObject(self, kCustomAccessibilityAttributeNamesKey, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self setValue:attributes forKey:kCustomAccessibilityAttributeNamesKey];
}

#pragma mark - public API

- (void)setReadableAccessibilityAttribute:(NSString*)attribute withBlock:(id(^)(void))handler
{
	NSAssert( handler, @"Handler must not be nil");

	[self mm_addAXCustomAttributeName:attribute];
	[self setValue:handler
			forKey:[self mm_getterKeyForAttribute:attribute]];
}

- (void)setParameterizedAccessibilityAttribute:(NSString*)parameterizedAttribute withBlock:(id(^)(id))handler
{
	NSAssert( handler, @"Handler must not be nil" );
	[self mm_addAXParameterizedAttributeName:parameterizedAttribute];
	[self setValue:handler
			 forKey:[self mm_getterKeyForParameterizedAttribute:parameterizedAttribute]];
}


- (void)setWritableAccessibilityAttribute:(NSString*)attribute readBlock:(id(^)(void))getter writeBlock:(void(^)(id value))setter
{
	NSAssert(getter, @"Getter must not be nil");
	NSAssert(setter, @"Setter must not be nil");

	[self setReadableAccessibilityAttribute:attribute
					 withBlock:getter];

	if ( ![[[self class] defaultAccessibilityAttributes] containsObject:attribute] ) {
		[self setValue:setter
				forKey:[self mm_setterKeyForAttribute:attribute]];
	}
}

- (void)removeAccessibilityAttribute:(NSString*)attribute
{
	[self mm_removeAXCustomAttributeName:attribute];
	[self setValue:nil forKey:[self mm_getterKeyForAttribute:attribute]];
	[self setValue:nil forKey:[self mm_setterKeyForAttribute:attribute]];
}

- (void)setAccessibilityAction:(NSString*)actionName withBlock:(void(^)(void))handler
{
	NSAssert(handler, @"Action handler must not be nil");
	[self mm_addAXActionName:actionName];
	[self setValue:handler
			forKey:[self mm_keyForAction:actionName]];
}

@end
