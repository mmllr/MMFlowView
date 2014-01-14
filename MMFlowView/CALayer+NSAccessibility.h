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
