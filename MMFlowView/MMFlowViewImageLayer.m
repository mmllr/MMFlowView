//
//  MMFlowViewImageLayer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 29.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMFlowViewImageLayer.h"

static NSString * const kLayerName = @"MMFlowViewContentLayerImage";
static NSString * const kContentsKey = @"contents";
static NSString * const kBoundsKey = @"bounds";

@implementation MMFlowViewImageLayer

@dynamic index;

#pragma mark - class methods

+ (id < CAAction >)defaultActionForKey:(NSString *)key
{
	if ([key isEqualToString:kCAOnOrderOut]) {
		CATransition *fadeTransition = [CATransition animation];
		fadeTransition.duration = .5;
		fadeTransition.type = kCATransitionFade;
		return fadeTransition;
	}
	else if ( [key isEqualToString:kCAOnOrderIn] ) {
		CATransition *transition = [CATransition animation];
		transition.duration = .5;
		transition.type = kCATransitionReveal;
		return transition;
	}
	else if ( [key isEqualToString:kContentsKey] ||
			 [key isEqualToString:kBoundsKey] ) {
		return nil;
	}
	else {
		return [super defaultActionForKey:key];
	}
}

#pragma mark - init

- (id)init
{
	[ NSException raise:NSInternalInconsistencyException format:@"init not allowed, use designated initalizer initWithIndex: instead"];
	return nil;
}

- (id)initWithIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
		self.index = index;
        self.name = kLayerName;
		self.contentsGravity = kCAGravityResizeAspect;
		self.layoutManager = [CAConstraintLayoutManager layoutManager];
    }
    return self;
}

#pragma mark - MMFlowViewContentLayerProtocol

- (void)setContentValue:(id)content
{
	self.contents = content;
}

@end
