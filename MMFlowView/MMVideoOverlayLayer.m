//
//  MMVideoOverlayLayer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 07.05.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMVideoOverlayLayer.h"

#import <QuartzCore/QuartzCore.h>
#import <QTKit/QTKit.h>

#import "MMButtonLayer.h"
#import "NSColor+MMAdditions.h"

static const CGFloat kMovieOverlayButtonBorderWidth = 2.;
static const CGFloat kMovieOverlayIndicatorBorderWidth = 1.;
static const CGFloat kMovieOverlayControlInset = 13.;
static const CGFloat kMovieOverlayButtonColor = 1.;
static const CGFloat kMovieOverlayButtonAlpha = 1.;
static const CGFloat kMovieOverlayBackgroundColor = 0.1;
static const CGFloat kMovieOverlayBackgroundAlpha = 0.75;
static const CGFloat kMovieOverlayIndicatorColor = 0.75;
static const CGFloat kMovieOverlayIndicatorAlpha = 1.;
static const CGFloat kMovieOverlayPausedRadius = 20.;
static const CGFloat kMovieOverlayIndicatorSize = 10.;
static const CGFloat kMovieOverlayCollapseDuration = 0.15;
static const NSTimeInterval kMovieOverlayUpdateInterval = 0.1;

static NSString * const kMMVideoOverlayLayerHiddenKey = @"hidden";
static void * const kMMVideoOverlayLayerHiddenObservationContext = @"MMVideoOverlayLayerHiddenObservationContext";

const CGFloat kMovieOverlayPlayingRadius = 30.;

NSString * const kMMVideoOverlayLayerIndicatorScaleKey = @"indicatorScale";
NSString * const kMMVideoOverlayLayerIndicatorValueKey = @"indicatorValue";
NSString * const kMMVideoOverlayLayerIsPlayingKey = @"isPlaying";

@interface MMVideoOverlayLayer ()

@property (strong, nonatomic) MMButtonLayer *buttonLayer;
@property (weak, nonatomic) NSTimer *movieUpdateTimer;

@end

@implementation MMVideoOverlayLayer

@dynamic indicatorScale;
@dynamic indicatorValue;

#pragma mark -
#pragma mark Class methods

+ (CGImageRef)playImage
{
	static CGImageRef image = NULL;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CGRect imageRect = CGRectMake( 0, 0, kMovieOverlayPausedRadius * 2, kMovieOverlayPausedRadius * 2 );
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		if ( colorSpace ) {
			CGContextRef context = CGBitmapContextCreate( NULL, imageRect.size.width, imageRect.size.height, 8, imageRect.size.width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst );
			CGColorSpaceRelease(colorSpace);
			CGContextSetGrayFillColor( context, kMovieOverlayButtonColor, kMovieOverlayButtonAlpha );
			CGContextSetLineWidth( context, kMovieOverlayButtonBorderWidth );
			CGContextSetShouldAntialias( context, true );
			CGContextSetGrayStrokeColor( context, kMovieOverlayButtonColor, kMovieOverlayButtonAlpha );
			// button
			CGPathRef path = [ self newTrianglePathInRect:imageRect ];
			CGContextAddPath( context, path );
			CGContextDrawPath( context, kCGPathEOFill );
			CGPathRelease( path );
			image = CGBitmapContextCreateImage( context );
			CGContextRelease( context );
		}
	});
	return image;
}

+ (CGImageRef)pauseImage
{
	static CGImageRef image = NULL;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CGRect imageRect = CGRectMake( 0, 0, kMovieOverlayPausedRadius * 2, kMovieOverlayPausedRadius * 2 );
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		if ( colorSpace ) {
			CGContextRef context = CGBitmapContextCreate( NULL, imageRect.size.width, imageRect.size.height, 8, imageRect.size.width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst );
			CGColorSpaceRelease(colorSpace);
			CGContextSetGrayFillColor( context, kMovieOverlayButtonColor, kMovieOverlayButtonAlpha );
			CGContextSetLineWidth( context, kMovieOverlayButtonBorderWidth );
			CGContextSetShouldAntialias( context, true );
			CGContextSetGrayStrokeColor( context, kMovieOverlayButtonColor, kMovieOverlayButtonAlpha );
			// button
			CGPathRef path = [ self newPausePathInRect:imageRect ];
			CGContextAddPath( context, path );
			CGContextDrawPath( context, kCGPathEOFill );
			CGPathRelease( path );
			image = CGBitmapContextCreateImage( context );
			CGContextRelease( context );
		}
	});
	return image;
}

#pragma mark -
#pragma mark Path creation

+ (CGPathRef)newTrianglePathInRect:(CGRect)aRect
{
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGRect triangleRect = CGRectInset( aRect, kMovieOverlayControlInset, kMovieOverlayControlInset );
	CGPathMoveToPoint( path, NULL, CGRectGetMinX(triangleRect) + 1., CGRectGetMinY(triangleRect) );
	CGPathAddLineToPoint( path, NULL, CGRectGetMaxX(triangleRect), CGRectGetMidY(triangleRect) );
	CGPathAddLineToPoint( path, NULL, CGRectGetMinX(triangleRect) + 1., CGRectGetMaxY(triangleRect) );
	CGPathCloseSubpath(path);
	return path;
}

+ (CGPathRef)newPausePathInRect:(CGRect)aRect
{
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGRect pauseRect = CGRectInset( aRect, kMovieOverlayControlInset, kMovieOverlayControlInset );
	CGRect leftMark, rightMark;
	CGRectDivide( pauseRect, &leftMark, &rightMark, pauseRect.size.width / 2, CGRectMinXEdge );
	CGPathAddRect( path, NULL, CGRectInset( leftMark, 2, 0 ) );
	CGPathAddRect( path, NULL, CGRectInset( rightMark, 2, 0 ) );
	CGPathCloseSubpath(path);
	return path;
}

#pragma mark -
#pragma mark Init/Cleanup

- (id)init
{
    self = [super init];
    if (self) {
        MMButtonLayer *button = [ MMButtonLayer layer ];
		self.layoutManager = [ CAConstraintLayoutManager layoutManager ];
		[ self addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:@"superlayer" attribute:kCAConstraintMidX ] ];
		[ self addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:@"superlayer" attribute:kCAConstraintMidY ] ];
		button.borderColor = [[ NSColor whiteColor ] CGColor ];
		button.borderWidth = kMovieOverlayButtonBorderWidth;
		button.cornerRadius = kMovieOverlayPausedRadius;
		button.bounds = CGRectMake( 0, 0, kMovieOverlayPausedRadius * 2, kMovieOverlayPausedRadius * 2 );
		[ button addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:@"superlayer" attribute:kCAConstraintMidX ] ];
		[ button addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:@"superlayer" attribute:kCAConstraintMidY ] ];
		button.image = [ [ self class ] playImage ];
		button.alternateImage = [ [ self class ] pauseImage ];
		button.action = @selector(buttonClicked:);
		button.target = self;
		button.type = NSPushOnPushOffButton;
		[ button setNeedsDisplay ];
		self.buttonLayer = button;
		[ self addSublayer:button ];
    }
    return self;
}

- (id)initWithLayer:(id)aLayer
{
	self = [ super initWithLayer:aLayer ];
	if ( self && [ aLayer isKindOfClass:[ MMVideoOverlayLayer class ] ] ) {
		MMVideoOverlayLayer *overlayLayer = (MMVideoOverlayLayer*)aLayer;
		self.indicatorValue = overlayLayer.indicatorValue;
		self.indicatorScale = overlayLayer.indicatorScale;
	}
	return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setTarget:(id)aTarget
{
	self.buttonLayer.target = aTarget;
}

- (id)target
{
	return self.buttonLayer.target;
}

- (void)setAction:(SEL)anAction
{
	self.buttonLayer.action = anAction;
}

- (SEL)action
{
	return self.buttonLayer.action;
}

- (QTMovie*)movie
{
	if ( [ self.superlayer isKindOfClass:[ QTMovieLayer class ] ] ) {
		QTMovieLayer *movieLayer = (QTMovieLayer*)self.superlayer;
		return movieLayer.movie;
	}
	return nil;
}

#pragma mark -
#pragma mark CALayer overrides

+ (BOOL)needsDisplayForKey:(NSString *)aKey
{
	if ( [ aKey isEqualToString:kMMVideoOverlayLayerIndicatorScaleKey ] ||
		[ aKey isEqualToString:kMMVideoOverlayLayerIndicatorValueKey ] ) {
		return YES;
	}
	else {
		return [ super needsDisplayForKey:aKey ];
	}
}

- (void)drawInContext:(CGContextRef)aContext
{
	BOOL isPlaying = self.indicatorScale > 0.;
	CGRect layerRect = CGRectInset( self.bounds, kMovieOverlayIndicatorBorderWidth, kMovieOverlayIndicatorBorderWidth );
	// center button in layer
	CGRect buttonRect = CGRectInset( layerRect, CGRectGetMidX(layerRect) - kMovieOverlayPausedRadius, CGRectGetMidY(layerRect) - kMovieOverlayPausedRadius );
	// scale outwards buttonrect with indicatorScale
	CGRect indicatorRect = CGRectInset( buttonRect, -( self.indicatorScale * kMovieOverlayIndicatorSize ), -( self.indicatorScale * kMovieOverlayIndicatorSize ) );
	CGContextSetShouldAntialias( aContext, true );
	// background circle
	CGContextSetGrayFillColor( aContext, kMovieOverlayBackgroundColor, kMovieOverlayBackgroundAlpha );
	CGContextFillEllipseInRect( aContext, isPlaying ? indicatorRect : buttonRect );
	// indicator
	if ( isPlaying ) {
		CGMutablePathRef indicatorPath = CGPathCreateMutable();
		
		CGFloat radius = CGRectGetWidth(indicatorRect) / 2. - ( kMovieOverlayIndicatorSize / 2. * self.indicatorScale );
		CGPathAddArc( indicatorPath, NULL, CGRectGetMidX(indicatorRect), CGRectGetMidY(indicatorRect), radius, M_PI_2, M_PI_2 - M_PI * 2 * self.indicatorValue, true );
		CGContextSetGrayStrokeColor( aContext, kMovieOverlayIndicatorColor, kMovieOverlayIndicatorAlpha );
		CGContextAddPath( aContext, indicatorPath );
		CGContextSetLineWidth( aContext, kMovieOverlayIndicatorSize * self.indicatorScale );
		CGContextDrawPath( aContext, kCGPathStroke );
		CGPathRelease( indicatorPath );
		// border circle
		CGContextSetLineWidth( aContext, kMovieOverlayIndicatorBorderWidth );
		CGContextSetGrayStrokeColor( aContext, kMovieOverlayButtonColor, kMovieOverlayButtonAlpha );
		CGContextStrokeEllipseInRect( aContext, indicatorRect );
	}
}

- (void)removeFromSuperlayer
{
	[ self teardownNotifications ];
	[ super removeFromSuperlayer ];
}

#pragma mark -
#pragma mark Actions

- (void)buttonClicked:(MMButtonLayer*)button
{
	// is movie playing?
	BOOL isMoviePlaying = ( [ self.movie rate ] > 0. );
	if ( isMoviePlaying ) {
		[ self collapse ];
	}
	else {
		[ self expand ];
	}
}

#pragma mark -
#pragma mark Custom implementation

- (void)expand
{
	CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath:kMMVideoOverlayLayerIndicatorScaleKey ];
	animation.duration = kMovieOverlayCollapseDuration;
	animation.fromValue = @0.;
	animation.toValue = @1.;
	animation.timingFunction = [ CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut ];
	[ self addAnimation:animation forKey:kMMVideoOverlayLayerIndicatorScaleKey ];
	self.indicatorScale = 1.;
	[ self startMovieUpdateTimer ];
	//[ self.movie autoplay ];
	self.buttonLayer.state = NSOnState;
}

- (void)collapse
{
	CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath:kMMVideoOverlayLayerIndicatorScaleKey ];
	animation.duration = kMovieOverlayCollapseDuration;
	animation.fromValue = @1.;
	animation.toValue = @0.;
	animation.timingFunction = [ CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut ];
	[ self addAnimation:animation forKey:kMMVideoOverlayLayerIndicatorScaleKey ];
	self.indicatorScale = 0.;
	[ self.movie stop ];
	[ self stopMovieUpdateTimer ];
	self.buttonLayer.state = NSOffState;
}

#pragma mark -
#pragma mark Notifications

- (void)setupNotifications
{
	[ self addObserver:self
			forKeyPath:kMMVideoOverlayLayerHiddenKey
			   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
			   context:kMMVideoOverlayLayerHiddenObservationContext ];
}

- (void)teardownNotifications
{
	[ self removeObserver:self
			   forKeyPath:kMMVideoOverlayLayerHiddenKey ];
}

#pragma mark -
#pragma mark Timer

- (void)startMovieUpdateTimer
{
	[ self.movieUpdateTimer invalidate ];
	self.movieUpdateTimer = [ NSTimer scheduledTimerWithTimeInterval:kMovieOverlayUpdateInterval
															  target:self
															selector:@selector(updateMovieOverlay:)
															userInfo:nil
															 repeats:YES ];
}

- (void)stopMovieUpdateTimer
{
	[ self.movieUpdateTimer invalidate ];
	self.movieUpdateTimer = nil;
}

- (void)updateMovieOverlay:(NSTimer*)theTimer
{
	NSTimeInterval currentTime = 0.;
	NSTimeInterval duration = 0.;
	if ( QTGetTimeInterval( self.movie.currentTime, &currentTime ) && QTGetTimeInterval( self.movie.duration, &duration ) ) {
		self.indicatorValue = currentTime / duration;
	}
	if ( [ self.movie rate ] <= 0. ) {
		[ self collapse ];
	}
}

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == kMMVideoOverlayLayerHiddenObservationContext ) {
        if ( self.hidden ) {
			[ self stopMovieUpdateTimer ];
		}
		else {
			[ self startMovieUpdateTimer ];
		}
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end