//
//  MMVideoOverlayLayer.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 07.05.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class MMButtonLayer;
@class QTMovie;

extern const CGFloat kMovieOverlayPlayingRadius;

extern NSString * const kMMVideoOverlayLayerIndicatorScaleKey;
extern NSString * const kMMVideoOverlayLayerIndicatorValueKey;
extern NSString * const kMMVideoOverlayLayerIsPlayingKey;

@interface MMVideoOverlayLayer : CALayer
#ifdef __i386__
{
@private
	CGFloat indicatorScale;
	CGFloat indicatorValue;
	MMButtonLayer *buttonLayer;
	NSTimer *movieUpdateTimer;
}
#endif

@property (assign, nonatomic) CGFloat indicatorScale;
@property (assign, nonatomic) CGFloat indicatorValue;
@property (readonly, nonatomic) QTMovie *movie;
@property (readonly, retain, nonatomic) MMButtonLayer *buttonLayer;

- (void)expand;
- (void)collapse;

@end