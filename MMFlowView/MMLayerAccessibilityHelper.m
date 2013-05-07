//
//  MMLayerAccessibilityHelper.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 07.05.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMLayerAccessibilityHelper.h"

@interface MMLayerAccessibilityHelper ()

@property (readwrite, copy) NSString *role;
@property (readwrite, assign) id parent;
@property (readwrite, assign) CALayer *layer;
@property (readwrite, assign) NSView *view;
@property (readwrite, retain) NSMutableDictionary *attributeGetHandlers;
@property (readwrite, retain) NSMutableDictionary *attributeSetHandlers;
@property (readwrite, nonatomic, retain) NSMutableArray *children;
@end

@implementation MMLayerAccessibilityHelper

@synthesize role;
@synthesize parent;
@synthesize layer;
@synthesize view;
@synthesize children;
@synthesize writableAttributeNames;
@synthesize attributeNames;
@synthesize attributeGetHandlers;
@synthesize attributeSetHandlers;
@synthesize focused;
@synthesize enabled;

+ (id)layerAccesibilityHelperWithRole:(NSString*)aRole parent:(id)aParent layer:(CALayer*)aLayer view:(NSView*)aView
{
	return [ [ [ self alloc ] initWithRole:aRole
									parent:aParent
									 layer:aLayer
									  view:aView ] autorelease ];
}

- (id)initWithRole:(NSString*)aRole parent:(id)aParent layer:(CALayer*)aLayer view:(NSView*)aView
{
    self = [super init];
    if (self) {
		self.role = aRole;
		self.parent = aParent;
		self.layer = aLayer;
		self.view = aView;
		self.focused = NO;
		self.enabled = YES;
		children = [[ NSMutableArray alloc ] init ];
		self.attributeGetHandlers = [ NSMutableDictionary dictionary ];
		self.attributeSetHandlers = [ NSMutableDictionary dictionary ];
    }
    return self;
}

- (void)dealloc
{
	self.writableAttributeNames = nil;
	self.attributeNames = nil;
	self.attributeSetHandlers = nil;
	self.attributeGetHandlers = nil;
	self.children = nil;
    self.role = nil;
	self.parent = nil;
	self.layer = nil;
	self.view = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Private implementation

- (void)adjustChildrenAttribute
{
	BOOL hasChildren = [ self countOfChildren ] > 0;
	NSMutableSet *newAttributeNames = [ [ self.attributeNames mutableCopy ] autorelease ];
	if ( hasChildren ) {
		[ newAttributeNames addObject:NSAccessibilityChildrenAttribute ];
	}
	else if ( [ newAttributeNames containsObject:NSAccessibilityChildrenAttribute ] ) {
		[ newAttributeNames removeObject:NSAccessibilityChildrenAttribute ];
	}
	self.attributeNames = newAttributeNames;
}

#pragma mark -
#pragma mark Accessors

- (NSArray*)children
{
	return [ [ children retain ] autorelease ];
}

- (NSUInteger)countOfChildren
{
	return [ children count ];
}

- (id)objectInChildrenAtIndex:(NSUInteger)index
{
	return [ children objectAtIndex:index ];
}

- (NSArray*)childrenAtIndexes:(NSIndexSet *)indexes
{
	return [ children objectsAtIndexes:indexes ];
}

- (void)insertObject:(MMLayerAccessibilityHelper*)aChild inChildrenAtIndex:(NSUInteger)index
{
	aChild.parent = self;
	[ children insertObject:aChild atIndex:index ];
	[ self adjustChildrenAttribute ];
}

- (void)insertChildren:(NSArray *)someChilds atIndexes:(NSIndexSet *)indexes
{
	[ someChilds performSelector:@selector(setParent:) withObject:self ];
	[ children insertObjects:someChilds atIndexes:indexes ];
	[ self adjustChildrenAttribute ];
}

- (void)removeObjectFromChildrenAtIndex:(NSUInteger)index
{
	MMLayerAccessibilityHelper *child = [ children objectAtIndex:index ];
	child.parent = nil;
	[ children removeObjectAtIndex:index ];
	[ self adjustChildrenAttribute ];
}

- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes
{
	NSArray *removedChildren = [ children objectsAtIndexes:indexes ];
	[ removedChildren performSelector:@selector(setParent:) withObject:nil ];
	[ children removeObjectsAtIndexes:indexes ];
	[ self adjustChildrenAttribute ];
}

- (void)addChildrenObject:(MMLayerAccessibilityHelper *)aChild
{
	aChild.parent = self;
	[ children addObject:aChild ];
	[ self adjustChildrenAttribute ];
}

- (void)addHandlerForAttribute:(NSString*)anAttribute withBlock:(id (^)(MMLayerAccessibilityHelper*))aHandler
{
	id (^copiedHandler)(MMLayerAccessibilityHelper*) = Block_copy(aHandler);
	[ self.attributeGetHandlers setValue:copiedHandler forKey:anAttribute ];
	// avoid memory leak, NSMutableDictionary retains itself
	Block_release(copiedHandler);
}

- (void)addHandlerForWritableAttribute:(NSString*)anAttribute withBlock:(void (^)(MMLayerAccessibilityHelper*, id))aHandler
{
	void (^copiedHandler)(MMLayerAccessibilityHelper*, id) = Block_copy(aHandler);
	[ self.attributeSetHandlers setValue:copiedHandler forKey:anAttribute ];
	// avoid memory leak, NSMutableDictionary retains itself
	Block_release(copiedHandler);
}

#pragma mark -
#pragma mark NSAccessibility protocol

// attributes

- (NSArray *)accessibilityAttributeNames
{
    static NSSet *attributes = nil;
    if ( attributes == nil ) {
		attributes = [ [ NSSet alloc ] initWithObjects:
					  NSAccessibilityRoleAttribute,
					  NSAccessibilityRoleDescriptionAttribute,
					  NSAccessibilityParentAttribute,
					  NSAccessibilityWindowAttribute,
					  NSAccessibilityTopLevelUIElementAttribute,
					  NSAccessibilityPositionAttribute,
					  NSAccessibilitySizeAttribute,
					  NSAccessibilityFocusedAttribute,
					  NSAccessibilityEnabledAttribute,
					  nil ];
    }
    return [ [ attributes setByAddingObjectsFromSet:self.attributeNames ] allObjects ];
}

- (id)accessibilityAttributeValue:(NSString*)anAttribute
{
    if ( [ anAttribute isEqualToString:NSAccessibilityRoleAttribute ] ) {
        return self.role;
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityRoleDescriptionAttribute ] ) {
		//return NSAccessibilityRoleDescription( self.role, nil );
		return NSAccessibilityRoleDescriptionForUIElement( self );
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityParentAttribute ] ) {
        return NSAccessibilityUnignoredAncestor( self.parent );
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityWindowAttribute ] ) {
        // We're in the same window as our parent.
        return [ self.parent accessibilityAttributeValue:NSAccessibilityWindowAttribute ];
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityTopLevelUIElementAttribute ] ) {
        // We're in the same top level element as our parent.
        return [ self.parent accessibilityAttributeValue:NSAccessibilityTopLevelUIElementAttribute ];
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityPositionAttribute ] ) {
		CGPoint pointInView = [ self.view.layer convertPoint:self.layer.frame.origin fromLayer:self.layer.superlayer ];
		NSPoint windowPoint = [ self.view convertPoint:NSPointFromCGPoint(pointInView)
												toView:nil ];
		return [ NSValue valueWithPoint:[ [ self.view window ] convertBaseToScreen:windowPoint ] ];
	}
	else if ( [ anAttribute isEqualToString:NSAccessibilityFocusedAttribute ] ) {
		return [ NSNumber numberWithBool:self.focused ];
	}
	else if ( [ anAttribute isEqualToString:NSAccessibilityEnabledAttribute ] ) {
		return [ NSNumber numberWithBool:self.enabled ];
	}
	else if ( [ anAttribute isEqualToString:NSAccessibilitySizeAttribute ] ) {
		return [ NSValue valueWithSize:[ self.view convertSize:NSSizeFromCGSize(self.layer.bounds.size)
														toView:nil ] ];
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityChildrenAttribute ] && self.children ) {
		return NSAccessibilityUnignoredChildren( self.children );
	}
	else {
		id (^handler)(MMLayerAccessibilityHelper*) = [ self.attributeGetHandlers valueForKey:anAttribute ];
		return handler ? handler( self ) : nil;
	}
}

- (BOOL)accessibilityIsAttributeSettable:(NSString*)anAttribute
{
	return [ self.writableAttributeNames containsObject:anAttribute ];
}

- (void)accessibilitySetValue:(id)value forAttribute:(NSString*)anAttribute
{
	void (^handler)(MMLayerAccessibilityHelper*, id) = [ self.attributeSetHandlers valueForKey:anAttribute ];
	return handler ? handler( self, value ) : nil;
}

// actions

- (NSArray*)accessibilityActionNames
{
    return [ NSArray array ];
}

- (NSString*)accessibilityActionDescription:(NSString*)anAction
{
    return nil;
}

- (void)accessibilityPerformAction:(NSString*)anAction
{
}

// misc

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

- (id)accessibilityHitTest:(NSPoint)aPoint
{
	NSPoint windowPoint = [ [ self.view window ] convertScreenToBase:aPoint ];
    CGPoint localPoint = NSPointToCGPoint([ self.view convertPoint:windowPoint
														  fromView:nil ] );
	
	CALayer *presentationLayer = [ self.view.layer presentationLayer ];
	CALayer *hitLayer = [ presentationLayer hitTest:localPoint ];
	
	if ( hitLayer.modelLayer == self.layer ) {
		return self;
	}
	else {
		return NSAccessibilityUnignoredAncestor( self );
	}
}

- (id)accessibilityFocusedUIElement
{
    return NSAccessibilityUnignoredAncestor( self );
}

#pragma mark -
#pragma mark NSObject overrides

- (NSString*)description
{
	return [ NSString stringWithFormat:@"<MMLayerAccessibilityHelper> role: %@",  self.role ];
}

@end
