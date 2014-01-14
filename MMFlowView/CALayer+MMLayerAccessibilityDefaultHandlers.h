//
//  CALayer+MMLayerAccessibilityDefaultHandlers.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 14.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (MMLayerAccessibilityDefaultHandlers)

+ (NSArray*)defaultAccessibilityAttributes;
- (id)mm_defaultPositionAttributeHandler;
- (id)mm_defaultSizeAttributeHandler;
- (id)mm_defaultParentAttributeHandler;

@end
