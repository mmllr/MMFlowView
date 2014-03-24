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
 *  Set a read-only handler for an readable accessibility attribute
 *
 *  @param attribute an NSAccessibility attribute name, must not be nil.
 *  @param handler   a block which return value is returned in -accessibilityAttributeValue:
 *  The block takes no arguments and returns a value. Must not be nil.
 *  @throws NSInternalInconsistencyException if attribute or handler are nil
 *  @warning Because the handler is stored on the layer, be careful with retain cycles. Always use a weak reference to
 *  access the layer inside the block!
 *  @see -accessibilityAttributeValue:
 */
- (void)setReadableAccessibilityAttribute:(NSString*)attribute withBlock:(id(^)(void))handler;

/**
 *  Set a read and write handler for an accessibility attribute
 *
 *  @param attribute an NSAccessibility attribute name, must not be nil.
 *  @param getter    a block returning a value which is returned in -accessibilityAttributeValue:
 *  @param setter    a block with a value parameter which is passed from -accessibilitySetValue:forAttribute:
 *  @throws NSInternalInconsistencyException if attribute or handler are nil
 *  @warning Because the handler is stored on the layer, be careful with retain cycles. Always use a weak reference to access the layer inside the block!
 *  @see -setReadableAccessibilityAttribute:withBlock:
 *  @see -accessibilityAttributeValue:
 *  @see -accessibilitySetValue:forAttribute:
 */
- (void)setWritableAccessibilityAttribute:(NSString*)attribute readBlock:(id(^)(void))getter writeBlock:(void(^)(id))setter;

/**
 *  Remove a previously added handler from the layer. Both the getter and a setter are removed.
 *  The default handlers cannot be removed. However, you can delete overriden handlers for default attributes.
 *  @param attribute an NSAccessibility attribute name, must not be nil, @see NSAccesibility.h
 *  @throws NSInternalInconsistencyException if attribute is nil
 */
- (void)removeAccessibilityAttribute:(NSString*)attribute;

/**
 *  Set a parameterized handler for an accessibility attribute
 *
 *  @param parameterizedAttribute an parameterized NSAccessibility attribute name, must not be nil.
 *  @param handler a block returning a value which is returned from -accessibilityAttributeValue:forParameter:
 *  The block gets the parameter from -accessibilityAttributeValue:forParameter:
 *  @throws NSInternalInconsistencyException if attribute or handler are nil
 *  @warning Because the handler is stored on the layer, be careful with retain cycles. Always use a weak reference to access the layer inside the block!
 *  @see -accessibilityAttributeValue:forParameter:
 */
- (void)setParameterizedAccessibilityAttribute:(NSString*)parameterizedAttribute withBlock:(id(^)(id))handler;

/**
 *  Set a handler which will involed for the specified accessibility action
 *
 *  @param actionName an NSAccessibilty action name, must not be nil.
 *  @param handler a block which will invoked in -accessibilityPerformAction:, must not be nil
 *  @throws NSInternalInconsistencyException if attribute or handler are nil
 *  @warning Because the handler is stored on the layer, be careful with retain cycles. Always use a weak reference to
 *  access the layer inside the block!
 *  @see -accessibilityPerformAction:
 */
- (void)setAccessibilityAction:(NSString*)actionName withBlock:(void(^)(void))handler;

@end

@interface NSView (MMLayerAccessibility)

/**
 *  Set a layer as the root layer of the view. You must set the layer with this method, otherwise the default attributes will not work. It turn
 *  the view in a layer backed view. Invoked -setWantsLayer:YES on the view.
 *
 *  @param layer a CALayer which will be the backing layer of the custom view, must not be nil.
 *  @throws NSInternalInconsistencyException if layer is nil
 *  @see -setWantsLayer:
 *  @see -setLayer:
 */
- (void)setAccessiblityEnabledLayer:(CALayer*)layer;

@end

@interface CALayer (MMLayerAccessibility) <MMLayerAccessibility>

@end
