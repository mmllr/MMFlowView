//
//  NSValue+MMAdditions.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 23.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (MMAdditions)

+ (instancetype)valueWithCGAffineTransform:(CGAffineTransform)affineTransform;
- (CGAffineTransform)CGAffineTransformValue;

@end
