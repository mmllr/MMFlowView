//
//  MMCoverFlowLayer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 31.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayer.h"
#import "MMCoverFlowLayout.h"

static const CGFloat kDefaultEyeDistance = 1500.;

@interface MMCoverFlowLayer ()

@property (strong) MMCoverFlowLayout *layout;

@end

@implementation MMCoverFlowLayer

@dynamic numberOfItems;

#pragma mark - class methods

+ (instancetype)layerWithLayout:(MMCoverFlowLayout*)layout
{
	return [[self alloc] initWithLayout:layout];
}

#pragma mark - init/cleanup

- (id)init
{
	[ NSException raise:NSInternalInconsistencyException format:@"init not allowed, use designated initalizer initWithLayout: instead"];
	return nil;
}

- (id)initWithLayout:(MMCoverFlowLayout*)layout
{
    self = [super init];
    if (self) {
		self.layout = layout;
        self.scrollMode = kCAScrollHorizontally;
		self.masksToBounds = NO;
		self.inLiveResize = NO;
		self.eyeDistance = kDefaultEyeDistance;
		self.delegate = self;
		self.layoutManager = self;
		self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    }
    return self;
}

- (NSUInteger)numberOfItems
{
	return self.layout.numberOfItems;
}

- (void)setNumberOfItems:(NSUInteger)numberOfItems
{
	self.layout.numberOfItems = numberOfItems;
	[self setNeedsLayout];
}

- (void)setEyeDistance:(CGFloat)eyeDistance
{
	_eyeDistance = eyeDistance;
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = 1. / - eyeDistance;
	self.sublayerTransform = transform;
}

#pragma mark - CALayerDelegate

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	if ( layer == self && self.inLiveResize ) {
		// disable implicit animations for scrolllayer in live resize
		return (id<CAAction>)[ NSNull null ];
	}
	return nil;
}

#pragma mark - CALayoutManager

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	if ( layer == self ) {
		
	}
}

@end
