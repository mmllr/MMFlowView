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
//  CALayer+MMLayerAccessibilityPrivate.h
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