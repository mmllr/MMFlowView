//
//  MMScrollBarLayer.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 14.11.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class MMScrollBarLayer;

@protocol MMScrollBarDelegate <NSObject>

- (void)scrollBarLayer:(MMScrollBarLayer*)scrollBarLayer knobDraggedToPosition:(CGFloat)positionInPercent;

@end

@interface MMScrollBarLayer : CALayer

@property (weak, nonatomic, readonly) CAScrollLayer *scrollLayer;
@property (nonatomic) CGPoint dragOrigin;
@property (weak, nonatomic) id<MMScrollBarDelegate> scrollBarDelegate;

- (id)initWithScrollLayer:(CAScrollLayer*)scrollLayer;
- (void)beginDragAtPoint:(CGPoint)pointInLayerCoordinates;
- (void)mouseDraggedToPoint:(CGPoint)pointInLayerCoordinates;
- (void)endDrag;

@end
