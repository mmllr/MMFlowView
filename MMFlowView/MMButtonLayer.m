//
//  MMButtonLayer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 07.05.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMButtonLayer.h"

NSString * const kMMButtonLayerHighlightedKey = @"highlighted";
NSString * const kMMButtonLayerEnabledKey = @"enabled";
NSString * const kMMButtonLayerStateKey = @"state";
NSString * const kMMButtonLayerTypeKey = @"type";

static const CGFloat kMMButtonLayerHighlightedDarkenGrayValue = 0.75;
static const CGFloat kMMButtonLayerHighlightedDarkenAlphaValue = 1;

@implementation MMButtonLayer

@synthesize action;
@synthesize target;
@synthesize image;
@synthesize alternateImage;
@dynamic highlighted;
@dynamic enabled;
@dynamic state;
@dynamic type;

#pragma mark -
#pragma mark Class methods

+ (NSSet*)keysAffectingRedisplay
{
	static NSSet *keys = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		keys = [ [NSSet alloc ] initWithObjects:kMMButtonLayerHighlightedKey,
				kMMButtonLayerEnabledKey,
				kMMButtonLayerTypeKey,
				kMMButtonLayerStateKey, nil ];
	});
	return keys;
}

+ (BOOL)needsDisplayForKey:(NSString *)aKey
{
	if ( [ [ self keysAffectingRedisplay ] containsObject:aKey ] ) {
		return YES;
	}
	else {
		return [ super needsDisplayForKey:aKey ];
	}
}

+ (NSArray*)selectedFilters
{
	static NSArray *selectedFilters = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CIFilter *filter = [ CIFilter filterWithName:@"CIColorControls" ];
		[ filter setDefaults ];
		[ filter setValue:[ NSNumber numberWithDouble:-.5 ] forKey:@"inputBrightness" ];
		selectedFilters = [ [ NSArray alloc ] initWithObjects:filter, nil ];
	});
	return selectedFilters;
}

#pragma mark -
#pragma mark Init/Cleanup

- (id)init
{
    self = [super init];
    if (self) {
		self.opaque = NO;
		self.state = NSOffState;
		self.type = NSMomentaryLightButton;
		self.highlighted = NO;
    }
    return self;
}

- (void)dealloc
{
	self.image = nil;
	self.alternateImage = nil;
	self.target = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark CALayer override

- (void)drawInContext:(CGContextRef)ctx
{
	CGImageRef buttonImage = self.state == NSOnState ? self.alternateImage : self.image;
	
	if ( self.highlighted ) {
		CGContextClipToMask( ctx, self.bounds, buttonImage );
		CGContextSetGrayFillColor( ctx, kMMButtonLayerHighlightedDarkenGrayValue, kMMButtonLayerHighlightedDarkenAlphaValue );
		CGContextFillRect( ctx, self.bounds );
	}
	CGContextSetBlendMode( ctx, self.highlighted ? kCGBlendModeMultiply : kCGBlendModeNormal );
	CGContextDrawImage( ctx, self.bounds, buttonImage );
}

#pragma mark -
#pragma mark Custom implementation

- (void)performClick:(id)sender
{
	[ self.target performSelector:self.action
					   withObject:self ];
	self.highlighted = NO;
}

@end
