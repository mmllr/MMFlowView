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
