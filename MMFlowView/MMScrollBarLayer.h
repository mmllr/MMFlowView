//
//  MMScrollBarLayer.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 14.11.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface MMScrollBarLayer : CALayer

@property (weak, nonatomic, readonly) CAScrollLayer *scrollLayer;
@property (nonatomic) CGPoint dragOrigin;

- (id)initWithScrollLayer:(CAScrollLayer*)scrollLayer;
- (void)beginDragAtPoint:(CGPoint)pointInLayerCoordinates;
- (void)mouseDraggedToPoint:(CGPoint)pointInLayerCoordinates;
- (void)endDrag;

@end
