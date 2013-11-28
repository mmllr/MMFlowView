//
//  MMFlowViewItemLayer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 29.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMFlowViewItemLayer.h"
#import "MMFlowViewImageLayer.h"

static CGFloat kDefaultItemSize = 50.;
static const CGFloat kDefaultReflectionOffset = -.4;
static NSString * const kIndexKey = @"index";

@interface MMFlowViewItemLayer ()

@property (nonatomic, weak, readwrite) MMFlowViewImageLayer *imageLayer;

@end

@implementation MMFlowViewItemLayer

@dynamic reflectionOffset;
@dynamic index;
@dynamic imageUID;

#pragma mark - class methods

+ (instancetype)layerWithImageUID:(NSString*)anImageUID andIndex:(NSUInteger)index
{
	return [[self alloc] initWithUID:anImageUID andIndex:index];
}

#pragma mark - init/cleanup

- (id)init
{
	[ NSException raise:NSInternalInconsistencyException format:@"init not allowed, use designated initalizer initWithUID:atIndex: instead"];
	return nil;
}

- (id)initWithUID:(NSString*)anImageUID andIndex:(NSUInteger)anIndex
{
    self = [super init];
    if (self) {
		self.frame = CGRectMake(0, 0, kDefaultItemSize, kDefaultItemSize );;
        self.instanceCount = 2;
		self.preservesDepth = YES;
		self.imageUID = anImageUID;
		self.index = anIndex;
		self.reflectionOffset = kDefaultReflectionOffset;
		MMFlowViewImageLayer *imageLayer = [[MMFlowViewImageLayer alloc] initWithIndex:anIndex];
		[self addSublayer:imageLayer];
		self.imageLayer = imageLayer;
    }
    return self;
}

#pragma mark - accessors

- (void)setReflectionOffset:(CGFloat)reflectionOffset
{
	self.instanceBlueOffset = reflectionOffset;
	self.instanceGreenOffset = reflectionOffset;
	self.instanceRedOffset = reflectionOffset;
}

- (CGFloat)reflectionOffset
{
	return self.instanceBlueOffset;
}

- (void)setImage:(CGImageRef)anImage
{
	CGFloat aspectRatio = CGImageGetWidth(anImage) / CGImageGetHeight(anImage);
	BOOL isLandscape = (aspectRatio >= 1);

	CGFloat width = isLandscape ? CGRectGetWidth(self.bounds) : CGRectGetWidth(self.bounds) * aspectRatio;
	CGFloat height = isLandscape ? ( CGRectGetHeight(self.bounds) / aspectRatio ) : CGRectGetHeight(self.bounds);

	self.imageLayer.contents = (__bridge id)anImage;
	self.imageLayer.frame = CGRectMake(0, 0, width, height);
}

- (CGRect)boundsFromContentWithAspectRatio:(CGFloat)aspectRatio inItemRect:(CGRect)itemRect
{
	BOOL isLandscape = aspectRatio >= 1;
	CGFloat newWidth = isLandscape ? itemRect.size.width : itemRect.size.width * aspectRatio;
	CGFloat newHeight = isLandscape ? ( itemRect.size.height / aspectRatio ) : itemRect.size.height;
	return CGRectMake( 0, 0, newWidth, newHeight );
}

@end
