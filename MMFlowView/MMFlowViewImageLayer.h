//
//  MMFlowViewImageLayer.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 29.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MMFlowViewItemLayer.h"

@interface MMFlowViewImageLayer : CALayer

@property (nonatomic) NSInteger index;

- (id)initWithIndex:(NSUInteger)index;

@end
