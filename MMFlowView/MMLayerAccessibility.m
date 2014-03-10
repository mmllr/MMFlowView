//
//  MMLayerAccessibility.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMLayerAccessibility.h"

static NSString * const kGetterPrefix = @"get";
static NSString * const kSetterPrefix = @"set";
static NSString * const kParamerizedPrefix = @"param";
static NSString * const kActionPrefix = @"action";

#define PREFIX_STRING(PREFIX, STRING) [PREFIX stringByAppendingString:STRING]
#define PARAMERTERIZED_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(kParamerizedPrefix, ATTRIBUTE)
#define GETTER_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(kGetterPrefix, ATTRIBUTE)
#define SETTER_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(kSetterPrefix, ATTRIBUTE)
#define ACTION_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(kActionPrefix, ATTRIBUTE)

@interface MMLayerAccessibilityDelegate ()

@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, strong) NSMutableDictionary *readHandlers;
@property (nonatomic, strong) NSMutableDictionary *writeHandlers;

@end

@implementation MMLayerAccessibilityDelegate

@synthesize attributeNames=_attributeNames;

#pragma mark - init/cleanup

- (id)init
{
	[ NSException raise:NSInternalInconsistencyException format:@"init not allowed, use designated initalizer -initWithLayer: instead"];
	return nil;
}

- (id)initWithLayer:(CALayer *)aLayer
{
	self = [super init];
	if (self) {
		_layer = aLayer;
		_readHandlers = [NSMutableDictionary dictionary];
		_writeHandlers = [NSMutableDictionary dictionary];
	}
	return self;
}

#pragma mark - public API

- (id)attributeValue:(NSString *)anAttribute
{
	id (^attributeGetter)(void) =  [self.readHandlers valueForKey:anAttribute];
	if (attributeGetter) {
		return attributeGetter();
	}
	return nil;
}

- (void)setValue:(id)value forAttribute:(NSString *)anAttribute
{
	void (^attributeSetter)(id) = [self.writeHandlers valueForKey:anAttribute];
	if ( attributeSetter ) {
		attributeSetter(value);
	}
}

#pragma mark - MMLayerAccessibilityDelegate

- (NSArray*)attributeNames
{
	return [self.readHandlers allKeys];
}

#pragma mark - MMLayerAccessibility protocol

- (void)setReadableAccessibilityAttribute:(NSString*)attribute withBlock:(id(^)(void))handler
{
	NSParameterAssert(attribute);
	NSParameterAssert(handler);
	[self.readHandlers setValue:handler forKey:attribute];
}

- (void)setWritableAccessibilityAttribute:(NSString*)attribute readBlock:(id(^)(void))getter writeBlock:(void(^)(id))setter
{
	NSParameterAssert(getter);
	NSParameterAssert(setter);
	[self setReadableAccessibilityAttribute:attribute withBlock:getter];
	[self.writeHandlers setObject:setter forKey:attribute];
}

- (void)setParameterizedAccessibilityAttribute:(NSString*)parameterizedAttribute withBlock:(id(^)(id))handler
{
	NSParameterAssert(parameterizedAttribute);
	NSParameterAssert(handler);
}

- (void)setAccessibilityAction:(NSString*)actionName withBlock:(void(^)(void))handler
{
	NSParameterAssert(actionName);
	NSParameterAssert(handler);
}

- (void)removeAccessibilityAttribute:(NSString*)attribute
{
	NSParameterAssert(attribute);
}

@end
