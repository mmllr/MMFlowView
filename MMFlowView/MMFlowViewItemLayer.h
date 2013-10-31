//
//  MMFlowViewItemLayer.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 29.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class MMFlowViewImageLayer;

@interface MMFlowViewItemLayer : CAReplicatorLayer

@property (nonatomic) CGFloat reflectionOffset;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSString *imageUID;
@property (nonatomic, weak, readonly) MMFlowViewImageLayer *imageLayer;

+ (instancetype)layerWithImageUID:(NSString*)anImageUID andIndex:(NSUInteger)index;
- (id)initWithUID:(NSString*)anImageUID andIndex:(NSUInteger)anIndex;
- (void)setImage:(CGImageRef)anImage;

@end
