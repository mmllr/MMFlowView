//
//  MMLayerAccessibility.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CALayer+NSAccessibility.h"

@protocol MMLayerAccessibilityDelegate <NSObject, MMLayerAccessibility>

@property (nonatomic, readonly) NSArray *attributeNames;

@end

@interface MMLayerAccessibilityDelegate : NSObject<MMLayerAccessibilityDelegate>

- (id)initWithLayer:(CALayer*)aLayer;
- (id)attributeValue:(NSString *)anAttribute;
- (void)setValue:(id)value forAttribute:(NSString *)key;

@end