//
//  NSEvent+MMAdditions.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 23.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSEvent (MMAdditions)

@property (nonatomic, readonly) CGFloat dominantDeltaInXYSpace;

@end
