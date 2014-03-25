/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://github.com/mmllr All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this
 software and associated documentation files (the "Software"), to deal in the Software
 without restriction, including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies
 or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
 
 */
//
//  MMCoverFlowLayoutAttributes.m
//
//  Created by Markus Müller on 18.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayoutAttributes.h"
#import "MMMacros.h"

NSString * const kMMCoverFlowLayoutAttributesIndexAttributeKey = @"mmCoverFlowLayerIndex";

@implementation MMCoverFlowLayoutAttributes

- (id)init
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"init not allowed, use designated initalizer initWithIndex:position:size:anchorPoint:transfrom:zPosition: instead" userInfo:nil];
}

- (id)initWithIndex:(NSUInteger)anIndex position:(CGPoint)aPosition size:(CGSize)aSize anchorPoint:(CGPoint)anAnchorPoint transfrom:(CATransform3D)aTransform zPosition:(CGFloat)aZPosition
{
    self = [super init];
    if (self) {
		_index = anIndex;
        _transform = aTransform;
		_anchorPoint = anAnchorPoint;
		_position = aPosition;
		_bounds = CGRectMake(0, 0, aSize.width, aSize.height);
		_zPosition = aZPosition;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
	if (self == object) {
		return YES;
	}
	if (![object isKindOfClass:[MMCoverFlowLayoutAttributes class]]) {
		return NO;
	}
	return [self isEqualToCoverFlowLayoutAttribute:(MMCoverFlowLayoutAttributes*)object];
}

- (BOOL)isEqualToCoverFlowLayoutAttribute:(MMCoverFlowLayoutAttributes*)other
{
	if (self.index != other.index ) {
		return NO;
	}
	if (!CATransform3DEqualToTransform(self.transform, other.transform)) {
		return NO;
	}
	if (!CGPointEqualToPoint(self.anchorPoint, other.anchorPoint)) {
		return NO;
	}
	if (!CGPointEqualToPoint(self.position, other.position)) {
		return NO;
	}
	if (!CGRectEqualToRect(self.bounds, other.bounds)) {
		return NO;
	}
	if (self.zPosition != other.zPosition) {
		return NO;
	}
	return YES;
}

- (NSUInteger)hash
{
	NSUInteger hashValue = _index;

	hashValue = NSUINTROTATE(hashValue, NSUINT_BIT / 2) ^ (NSUInteger)_zPosition;
	hashValue = NSUINTROTATE(hashValue, NSUINT_BIT / 2) ^ (NSUInteger)_bounds.size.width;
	hashValue = NSUINTROTATE(hashValue, NSUINT_BIT / 2) ^ (NSUInteger)_bounds.size.height;
	hashValue = NSUINTROTATE(hashValue, NSUINT_BIT / 2) ^ (NSUInteger)_anchorPoint.x;
	hashValue = NSUINTROTATE(hashValue, NSUINT_BIT / 2) ^ (NSUInteger)_anchorPoint.y;
	hashValue = NSUINTROTATE(hashValue, NSUINT_BIT / 2) ^ (NSUInteger)_position.x;
	hashValue = NSUINTROTATE(hashValue, NSUINT_BIT / 2) ^ (NSUInteger)_position.y;
	return NSUINTROTATE([[NSValue valueWithCATransform3D:_transform] hash], NSUINT_BIT / 2) ^ hashValue;
}

- (CGAffineTransform)anchorPointTransform
{
	return CGAffineTransformMakeTranslation(self.anchorPoint.x*CGRectGetWidth(self.bounds), self.anchorPoint.y*CGRectGetHeight(self.bounds));
}

- (void)applyToLayer:(CALayer *)aLayer
{
	aLayer.anchorPoint = self.anchorPoint;
	aLayer.zPosition = self.zPosition;
	aLayer.transform = self.transform;
	aLayer.bounds = self.bounds;
	aLayer.position = CGPointApplyAffineTransform(self.position, [self anchorPointTransform]);
	[aLayer setValue:@(self.index) forKey:kMMCoverFlowLayoutAttributesIndexAttributeKey];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"MMCoverFlowLayoutAttributes: %p, index: %@, position: %@, anchorPoint: %@, bounds: %@, zPosition: %@, transform: %@", self, @(self.index), [NSValue valueWithPoint:self.position], [NSValue valueWithPoint:self.anchorPoint], [NSValue valueWithRect:self.bounds], @(self.zPosition), [NSValue valueWithCATransform3D:self.transform]];
}

@end
