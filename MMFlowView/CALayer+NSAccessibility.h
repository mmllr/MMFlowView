//
//  CALayer+NSAccessibility.h
//  LayerAccessibility
//
//  Created by Markus Müller on 03.10.13.
//  Copyright (c) 2013 Markus Müller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface NSView (MMLayerAccessibility)

- (void)setAccessiblityEnabledLayer:(CALayer*)layer;

@end

@interface CALayer (NSAccessibility)

- (void)setReadableAccessibilityAttribute:(NSString*)attribute withBlock:(id(^)(void))handler;
- (void)setWritableAccessibilityAttribute:(NSString*)attribute readBlock:(id(^)(void))getter writeBlock:(void(^)(id value))setter;
- (void)removeAccessibilityAttribute:(NSString*)attribute;
- (void)setParameterizedAccessibilityAttribute:(NSString*)parameterizedAttribute withBlock:(id(^)(id))handler;

- (void)setAccessibilityAction:(NSString*)actionName withBlock:(void(^)(void))handler;

@end

