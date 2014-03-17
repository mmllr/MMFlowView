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
		[ filter setValue:@-.5 forKey:@"inputBrightness" ];
		selectedFilters = @[filter];
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
	if ( [self.target respondsToSelector:self.action] ) {
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self.target class] instanceMethodSignatureForSelector:self.action]];
		[invocation setTarget:self.target];
		[invocation setSelector:self.action];
		[invocation invokeWithTarget:self.target];
	}
	self.highlighted = NO;
}

@end
