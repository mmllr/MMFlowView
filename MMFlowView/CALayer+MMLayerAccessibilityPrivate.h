//
//  CALayer+MMLayerAccessibilityPrivate.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 14.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

extern const void* kMMLayerAccessibilityParentViewKey;

#define PREFIX_STRING(PREFIX, STRING) [PREFIX stringByAppendingString:STRING]
#define PARAMERTERIZED_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(@"param", ATTRIBUTE)
#define GETTER_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(@"get", ATTRIBUTE)
#define SETTER_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(@"set", ATTRIBUTE)
#define ACTION_ATTRIBUTE_KEY(ATTRIBUTE) PREFIX_STRING(@"action", ATTRIBUTE)

@interface CALayer (MMLayerAccessibilityPrivate)

@property (nonatomic, strong) NSMutableArray *mmAccessibilityAttributes;
@property (nonatomic, strong) NSMutableArray *mmParameterizedAttributes;
@property (nonatomic, strong) NSMutableArray *mmActionNames;

- (id(^)(void))mm_getterForAttribute:(NSString*)attribute;
- (void(^)(id))mm_setterForAttribute:(NSString*)attribute;
- (id(^)(id))mm_handlerForParameterizedAttribute:(NSString*)attribute;
- (id)mm_accessibilityParent;
- (NSView*)mm_containingView;
- (void)mm_addAXCustomAttributeName:(NSString*)anAttribute;
- (void)mm_removeAXCustomAttribute:(NSString*)anAttribute;
- (void)mm_addAXActionName:(NSString*)action;
- (void)mm_addAXParameterizedAttributeName:(NSString*)attribute;
- (void(^)(void))mm_handlerForAction:(NSString*)action;
- (BOOL)mm_hasCustomAttributes;
- (BOOL)mm_hasActions;
- (BOOL)mm_hasParameterizedAttributes;
- (NSArray*)mm_attributeNames;
- (id)mm_handleCustomAttribute:(NSString*)anAttribute;

@end