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

@protocol MMCoverFlowLayerDataSource <NSObject>

- (CALayer*)coverFlowLayer:(MMCoverFlowLayer*)layer contentLayerForIndex:(NSUInteger)index;
@optional
- (void)coverFlowLayerWillRelayout:(MMCoverFlowLayer*)coverFlowLayer;
- (void)coverFlowLayerDidRelayout:(MMCoverFlowLayer *)coverFlowLayer;

@end

@interface MMCoverFlowLayer : CAScrollLayer

@property (nonatomic) CGFloat eyeDistance;
@property (nonatomic) BOOL inLiveResize;
@property (nonatomic, readonly) NSUInteger numberOfItems;
@property (nonatomic) NSUInteger selectedItemIndex;
@property (nonatomic, weak) id<MMCoverFlowLayerDataSource> dataSource;
@property (nonatomic, strong, readonly) NSIndexSet *visibleItemIndexes;
@property (nonatomic, strong, readonly) MMCoverFlowLayout *layout;
@property (nonatomic) CFTimeInterval scrollDuration;

+ (instancetype)layerWithLayout:(MMCoverFlowLayout*)layout;
- (id)initWithLayout:(MMCoverFlowLayout*)layout;
- (void)reloadContent;

@end
