//
//  MMCoverFlowLayer.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 31.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class MMCoverFlowLayout;
@class MMCoverFlowLayer;

@protocol MMCoverFlowLayerDatasource <NSObject>

- (CGImageRef)coverFlowLayer:(MMCoverFlowLayer*)layer imageAtIndex:(NSUInteger)index;
@optional
- (void)coverFlowLayerWillRelayout:(MMCoverFlowLayer*)layer;
- (void)coverFlowLayerDidRelayout:(MMCoverFlowLayer *)layer;

@end

@interface MMCoverFlowLayer : CAScrollLayer

@property (nonatomic) CGFloat eyeDistance;
@property (nonatomic) BOOL inLiveResize;
@property (nonatomic) NSUInteger numberOfItems;

+ (instancetype)layerWithLayout:(MMCoverFlowLayout*)layout;
- (id)initWithLayout:(MMCoverFlowLayout*)layout;

@end
