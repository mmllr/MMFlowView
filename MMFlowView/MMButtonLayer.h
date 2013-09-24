//
//  MMButtonLayer.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 07.05.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#pragma mark -
#pragma mark MMButtonLayer helper class

extern NSString * const kMMButtonLayerStateKey;
extern NSString * const kMMButtonLayerHighlightedKey;
extern NSString * const kMMButtonLayerEnabledKey;
extern NSString * const kMMButtonLayerStateKey;
extern NSString * const kMMButtonLayerTypeKey;

@interface MMButtonLayer : CALayer

@property(strong) __attribute__((NSObject)) CGImageRef image;
@property(strong) __attribute__((NSObject)) CGImageRef alternateImage;
@property (nonatomic, weak) id<NSObject> target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSCellStateValue state;
@property (nonatomic, assign) NSButtonType type;

- (void)performClick:(id)sender;

@end
