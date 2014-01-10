//
//  CALayer+MMAdditions.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 10.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (MMAdditions)

- (void)disableImplicitPositionAndBoundsAnimations;
- (void)enableImplicitPositionAndBoundsAnimations;

@end
