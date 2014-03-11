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
//  CALayer+NSAccessibility.h
//  LayerAccessibility
//
//  Created by Markus Müller on 03.10.13.
//  Copyright (c) 2013 Markus Müller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@protocol MMLayerAccessibility <NSObject>

/**
 *  Add a read-only handler for an readable accessibility attribute
 *
 *  @param attribute an NSAccessibility attribute name, must not be nil
 *  @param handler   a block which gets invoked the layer is in accessibilityAttributeValue:
 The block takes no arguments and returns a value. Must not be nil.
 *  @throws NSInternalInconsistencyException when attribute or handler are nil
 */
- (void)setReadableAccessibilityAttribute:(NSString*)attribute withBlock:(id(^)(void))handler;
- (void)setWritableAccessibilityAttribute:(NSString*)attribute readBlock:(id(^)(void))getter writeBlock:(void(^)(id value))setter;
- (void)removeAccessibilityAttribute:(NSString*)attribute;
- (void)setParameterizedAccessibilityAttribute:(NSString*)parameterizedAttribute withBlock:(id(^)(id))handler;
- (void)setAccessibilityAction:(NSString*)actionName withBlock:(void(^)(void))handler;

@end

@interface NSView (MMLayerAccessibility)

- (void)setAccessiblityEnabledLayer:(CALayer*)layer;

@end

@interface CALayer (MMLayerAccessibility) <MMLayerAccessibility>

@end
