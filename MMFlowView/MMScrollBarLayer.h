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
- (void)decrementClickedInScrollBarLayer:(MMScrollBarLayer*)scrollBarLayer;
- (void)incrementClickedInScrollBarLayer:(MMScrollBarLayer*)scrollBarLayer;
- (CGFloat)contentSizeForScrollBarLayer:(MMScrollBarLayer*)scrollBarLayer;
- (CGFloat)visibleSizeForScrollBarLayer:(MMScrollBarLayer*)scrollBarLayer;
- (CGFloat)currentKnobPositionInScrollBarLayer:(MMScrollBarLayer*)scrollBarLayer;

@end

@interface MMScrollBarLayer : CALayer

@property (nonatomic) CGFloat draggingOffset;
@property (weak, nonatomic) id<MMScrollBarDelegate> scrollBarDelegate;

- (void)mouseDownAtPoint:(CGPoint)pointInLayerCoordinates;
- (void)beginDragAtPoint:(CGPoint)pointInLayerCoordinates;
- (void)mouseDraggedToPoint:(CGPoint)pointInLayerCoordinates;
- (void)endDrag;

@end
