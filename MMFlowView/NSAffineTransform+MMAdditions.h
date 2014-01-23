//
//  NSAffineTransform+MMAdditions.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 23.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAffineTransform (MMAdditions)

+ (instancetype)affineTransformWithCGAffineTransform:(CGAffineTransform)cgTransform;

@property (nonatomic, readonly) CGAffineTransform mm_CGAffineTransform;

@end
