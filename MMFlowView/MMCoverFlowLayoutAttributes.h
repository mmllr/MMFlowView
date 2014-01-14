//
//  MMCoverFlowLayoutAttributes.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMCoverFlowLayoutAttributes : NSObject

@property NSUInteger index;
@property CATransform3D transform;
@property CGRect bounds;
@property CGPoint position;
@property CGPoint anchorPoint;
@property CGFloat zPosition;

- (id)initWithIndex:(NSUInteger)anIndex position:(CGPoint)aPosition size:(CGSize)aSize anchorPoint:(CGPoint)anAnchorPoint transfrom:(CATransform3D)aTransform zPosition:(CGFloat)aZPosition;

@end
