/*
 Copyright (c) 2012, Markus Müller, www.isnotnil.com
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  MMFlowView.m
//  FlowView
//
//  Created by Markus Müller on 13.01.12.

#import "MMFlowView.h"

#import <Quartz/Quartz.h>
#import <QTKit/QTKit.h>

#import "MMVideoOverlayLayer.h"
#import "MMLayerAccessibilityHelper.h"
#import "MMButtonLayer.h"
#import "NSColor+MMAdditions.h"

/* representation types */
NSString * const kMMFlowViewURLRepresentationType = @"MMFlowViewURLRepresentationType";
NSString * const kMMFlowViewCGImageRepresentationType = @"MMFlowViewCGImageRepresentationType";
NSString * const kMMFlowViewPDFPageRepresentationType = @"MMFlowViewPDFPageRepresentationType";
NSString * const kMMFlowViewPathRepresentationType = @"MMFlowViewPathRepresentationType";
NSString * const kMMFlowViewNSImageRepresentationType = @"MMFlowViewNSImageRepresentationType";
NSString * const kMMFlowViewCGImageSourceRepresentationType = @"MMFlowViewPDFPageRepresentationType";
NSString * const kMMFlowViewNSDataRepresentationType = @"MMFlowViewNSDataRepresentationType";
NSString * const kMMFlowViewNSBitmapRepresentationType = @"MMFlowViewNSBitmapRepresentationType";
NSString * const kMMFlowViewQTMovieRepresentationType = @"MMFlowViewQTMovieRepresentationType";
NSString * const kMMFlowViewQTMoviePathRepresentationType = @"MMFlowViewQTMoviePathRepresentationType";
NSString * const kMMFlowViewQCCompositionRepresentationType = @"MMFlowViewQCCompositionRepresentationType";
NSString * const kMMFlowViewQCCompositionPathRepresentationType = @"MMFlowViewQCCompositionPathRepresentationType";
NSString * const kMMFlowViewQuickLookPathRepresentationType = @"MMFlowViewQuickLookPathRepresentationType";
NSString * const kMMFlowViewIconRefPathRepresentationType = @"MMFlowViewIconRefPathRepresentationType";
NSString * const kMMFlowViewIconRefRepresentationType = @"MMFlowViewIconRefRepresentationType";
/* bindings */
NSString * const kMMFlowViewImageRepresentationBinding = @"imageRepresentationKeyPath";
NSString * const kMMFlowViewImageRepresentationTypeBinding = @"imageRepresentationTypeKeyPath";
NSString * const kMMFlowViewImageUIDBinding = @"imageUIDKeyPath";
NSString * const kMMFlowViewImageTitleBinding = @"imageTitleKeyPath";
/* layer names */
static NSString * const kMMFlowViewScrollLayerName = @"MMFlowViewScrollLayerName";
static NSString * const kMMFlowViewScrollKnobLayerName = @"MMFlowViewScrollKnobLayerName";
static NSString * const kMMFlowViewScrollBarLayerName = @"MMFlowViewScrollBarLayerName";
static NSString * const kMMFlowViewOverlayLayerName = @"MMFlowViewOverlayLayerName";
/* custom layer keys */
static NSString * const kMMFlowViewItemIndexKey = @"index";
static NSString * const kMMFLowViewAccessibilityHelperKey = @"axHelper";
static NSString * const kMMFlowViewSelectedLayerKey = @"selected";
static NSString * const kMMFlowViewHiglightedLayerKey = @"highlighted";
/* default values */
static const CGFloat kTitleOffset = 50.;
static const CGFloat kDefaultTitleSize = 18.;
static const CGFloat kDefaultItemSize = 100.;
static const CGFloat kDefaultStackedAngle = 70.;
static const CGFloat kDefaultItemSpacing = 50.;
static const CGFloat kDefaultCacheCompression = .15;
static const CGFloat kDefaultCachedImageSizeThreshold = 10.;
static const CGFloat kDefaultPreviewScale = 0.25;
static const CGFloat kDefaultSelectedScale = 200.;
static const CGFloat kDefaultStackedScale = -200.;
static const CGFloat kDefaultReflectionOffset = -0.4;
static const CFTimeInterval kDefaultScrollDuration = .4;
static const NSUInteger kDefaultCacheLimit = 20;
static const CGFloat kDefaultEyeDistance = 1500.;
static const CGFloat kDefaultItemScale = 1.;
static const CGFloat kHighlightedBorderWidth = 2;

static const CGFloat kItemYMargin = 50.;
static const CGFloat kScrollBarYOffset = 10.;
static const CGFloat kScrollBarScale = 0.75;
static const CGFloat kScrollBarOpacity = 0.5;
static const CGFloat kScrollBarBorderWidth = 1.;
static const CGFloat kScrollBarCornerRadius = 10.;
static const CGFloat kScrollBarHeight = 20.;
static const CGFloat kScrollKnobMargin = 5.;
static const CGFloat kMinimumKnobWidth = 40.;
static const CGFloat kMinimumItemScale = 0.1;
static const CGFloat kMaximumItemScale = 1.;
static const CGFloat kMaximumStackedAngle = 90.;
static const NSUInteger kImageLayerIndex = 0;

static NSString * const kMMFlowViewItemContentLayerPrefix = @"MMFlowViewContentLayer";
static NSString * const kMMFlowViewTitleLayerName = @"MMFlowViewTitleLayer";
static NSString * const kMMFlowViewContainerLayerName = @"MMFlowViewContainerLayer";
static NSString * const kMMFlowViewItemLayerSuffix = @"Item";
static NSString * const kMMFlowViewImageLayerSuffix = @"Image";
static NSString * const kMMFlowViewMovieLayerSuffix = @"Movie";
static NSString * const kMMFlowViewQCCompositionLayerSuffix = @"QCComposition";
static NSString * const kUTTypeQuartzComposerComposition = @"com.apple.quartz-composer-composition";

/* notifications */
NSString * const kMMFlowViewSelectionDidChangeNotification = @"MMFlowViewSelectionDidChangeNotification";
/* key for accessing selection changes in notifications or for setting up bindings */
NSString * const kMMFlowViewSelectedIndexKey = @"selectedIndex";

static NSString * const kMMFlowViewSpacingKey = @"spacing";
static NSString * const kMMFlowViewStackedAngleKey = @"stackedAngle";
static NSString * const kMMFlowViewSelectedScaleKey = @"selectedScale";
static NSString * const kMMFlowViewStackedScaleKey = @"stackedScale";
static NSString * const kMMFlowViewReflectionOffsetKey = @"reflectionOffset";
static NSString * const kMMFlowViewShowsReflectionKey = @"showsReflection";
static NSString * const kMMFlowViewPerspectiveKey = @"perspective";
static NSString * const kMMFlowViewScrollDurationKey = @"scrollDuration";
static NSString * const kMMFlowViewItemScaleKey = @"itemScale";
static NSString * const kMMFlowViewPreviewScaleKey = @"previewScale";
static NSString * const kMMFlowViewMouseDownInScrollBarKey = @"mouseDownInScrollBarKey";
static NSString * const kMMFlowViewInitialKnobDragPositionKey = @"initialKnobDragPositionKey";
static NSString * const kMMFlowViewOverlayLayerKey = @"overlayLayerKey";
static NSString * const kMMFlowViewItemAspectRatioKey = @"aspectRatioKey";
static NSString * const kSuperlayerKey = @"superlayer";
static NSString * const kPositionKey = @"position";
static NSString * const kBoundsKey = @"bounds";
static NSString * const kStringKey = @"string";
static NSString * const kContentsKey = @"contents";

/* observation context */
static NSString * const kMMFlowViewContentArrayObservationContext = @"MMFlowViewContentArrayObservationContext";
static NSString * const kMMFlowViewIndividualItemKeyPathsObservationContext = @"kMMFlowViewIndividualItemKeyPathsObservationContext";
/* default item keys */
static NSString * const kMMFlowViewItemImageRepresentationKey = @"imageItemRepresentation";
static NSString * const kMMFlowViewItemImageRepresentationTypeKey = @"imageItemRepresentationType";
static NSString * const kMMFlowViewItemImageUIDKey = @"imageItemUID";
static NSString * const kMMFlowViewItemImageTitleKey = @"imageItemTitle";

static inline CGFloat DegreesToRadians( CGFloat angleInDegrees )
{
	return angleInDegrees * M_PI / 180.;
}

#ifndef CLAMP

#define CLAMP(value, lowerBound, upperbound) MAX( lowerBound, MIN( upperbound, value ))

#endif

#if __has_feature(objc_arc)
#define __MM_WEAK_REFERENCE __weak
#else
#define __MM_WEAK_REFERENCE __block
#endif

#pragma mark -
#pragma mark MMFLowView private declarations

@interface MMFlowView ()
/* layers */
@property (retain,readwrite) CALayer *backgroundLayer;
@property (retain,readwrite) CATextLayer *titleLayer;
@property (retain,readwrite) CAScrollLayer *scrollLayer;
@property (retain,readwrite) CALayer *containerLayer;
@property (retain,nonatomic) CALayer *selectedLayer;
@property (retain,nonatomic) CALayer *highlightedLayer;
@property (readwrite,retain) CALayer *scrollBarLayer;

/* scroll knob */
@property (assign,nonatomic) BOOL draggingKnob;
@property (assign) CGFloat mouseDownInKnob;

/* number of items in view */
@property (assign,nonatomic) NSUInteger numberOfItems;

/* indexes of all visible items */
@property (retain, readwrite) NSIndexSet *visibleItemIndexes;

/* number of potentialy visible items, taking in account selection scrolled to left- and rightmost index */
@property (readonly,nonatomic) NSUInteger maximumNumberOfStackedVisibleItems;

/* operation queue for asynchronous operations such as image and movie loading */
@property (retain) NSOperationQueue *operationQueue;

/* image cache which holds key-value pairs of image-uids (key) and CGImageRefs (value) */
@property (readwrite,retain) NSCache *imageCache;

/* CATransform3D for all items left to the selection */
@property (assign) CATransform3D leftTransform;

/* CATransform3D for all items right to the selection */
@property (assign) CATransform3D rightTransform;

/* perspective transform for all item layers */
@property (assign) CATransform3D perspective;

/* the bound content array if bindings are used */
@property (nonatomic, readonly) NSArray *contentArray;

/* the bound NSArrayController if bindings are used */
@property (nonatomic, readonly) NSArrayController *contentArrayController;

/* the keypath for the content array in the bound array-controller */
@property (nonatomic, readonly) NSString *contentArrayKeyPath;

/* dictionary holding bindings */
@property (retain,nonatomic,readwrite) NSMutableDictionary *bindingInfo;

/* dictionary holding item layer positions (key is the item-image uid, value is a NSNumber containing its index */
@property (retain,readwrite) NSMutableArray *layerQueue;

/* array of all oberved items if bindings are used */
@property (nonatomic,copy) NSArray *observedItems;

/* set of all observed keypaths on the image items, dynamically created */
@property (nonatomic,readonly) NSSet *observedItemKeyPaths;

/* indicates if bindings are enabled */
@property (nonatomic,readonly) BOOL bindingsEnabled;

/* set containing all types which are based on urls or filepaths */
+ (NSSet*)pathRepresentationTypes;

/* mapping dict for getting uris for representation types */
+ (NSDictionary*)uniformTypesDictionary;

/* default image and gradient */
+ (CGImageRef)defaultImage;
+ (NSArray*)backgroundGradientColors;
+ (NSArray*)backgroundGradientLocations;

/* image creation methods, the returned CGImageRef needs to be explicitly released with CGImageRelease */
+ (CGImageRef)newImageFromQuickLookURL:(NSURL*)anURL withSize:(CGSize)imageSize;
+ (CGImageRef)newImageFromURL:(NSURL*)anURL withSize:(CGSize)imageSize;
+ (CGImageRef)newImageFromPDFPage:(CGPDFPageRef)pdfPage withSize:(CGSize)imageSize andTransparentBackground:(BOOL)transparentBackground;
+ (CGImageRef)newImageFromPath:(NSString*)aPath withSize:(CGSize)imageSize;
+ (CGImageRef)newImageFromNSImage:(NSImage*)anImage withSize:(CGSize)imageSize;
+ (CGImageRef)newImageFromCGImageSource:(CGImageSourceRef)imageSource withSize:(CGSize)imageSize;
+ (CGImageRef)newImageFromNSBitmapImage:(NSBitmapImageRep*)bitmapImage withSize:(CGSize)imageSize;
+ (CGImageRef)newImageFromData:(NSData*)data withSize:(CGSize)imageSize;
+ (CGImageRef)newImageFromIcon:(IconRef)anIcon withSize:(CGSize)imageSize;
+ (CGImageRef)newImageFromIconRefPath:(NSString*)iconPath withSize:(CGSize)imageSize;
+ (CGImageRef)newImageFromRepresentation:(id)imageRepresentation withType:(NSString*)representationType size:(CGSize)imageSize;

/* returns an autoreleased QTMovie object */
+ (QTMovie*)movieFromRepresentation:(id)representation withType:(NSString*)representationType;

/* creates the layer tree */
- (void)setupLayers;
- (CALayer*)createBackgroundLayer;
- (CATextLayer*)createTitleLayer;
- (CAScrollLayer*)createScrollLayer;
- (CALayer*)createContainerLayer;
- (CAReplicatorLayer*)createItemLayerWithIndex:(NSUInteger)anIndex;
- (CALayer*)createImageLayer;
- (QTMovieLayer*)createMovieLayerWithMovie:(QTMovie*)aMovie atIndex:(NSUInteger)anIndex;
- (MMVideoOverlayLayer*)createMovieOverlayLayerWithIndex:(NSUInteger)anIndex;
- (CALayer*)createScrollBarLayer;

/* returns the item-rootlayer */
- (CAReplicatorLayer*)itemLayerAtIndex:(NSUInteger)anIndex;

/* returns the image layer */
- (CALayer*)imageLayerAtIndex:(NSUInteger)anIndex;

/* returns the movie layer if present, may return nil */
- (QTMovieLayer*)movieLayerAtIndex:(NSUInteger)anIndex;

/* returns overlay layer if present, may return nil */
- (CALayer*)overlayLayerAtIndex:(NSUInteger)anIndex;

/* updates the image layer: asynchronously loads the image from the datasource or provides a default image */
- (void)updateImageLayerAtIndex:(NSUInteger)index;

/* updates the movielayer for a movie-item */
- (void)updateMovieLayerAtIndex:(NSUInteger)index;

/* invoked if mouse enters the frame of a specific layer */ 
- (void)mouseEnteredLayerAtIndex:(NSUInteger)anIndex;

/* invoked if mouse exited the frame of a specific layer */
- (void)mouseExitedLayerAtIndex:(NSUInteger)anIndex;

/* invoked after changing the selection, adjust scroll knob, visible images etc */
- (void)updateSelectionInRange:(NSRange)invalidatedRange;

/* recalculates the visible items */
- (void)calculateVisibleItems;

/* updates the reflection layers for all image items, invoked after chaning the reflection related properties */
- (void)updateReflection;

/* helper method for updating the position and size of the scroll knob */
- (void)updateScrollKnob;

/* returns the scale for the angle width clamped to the following range: angle 0°: 1, angle 90° : 0, see stackedAngle */
- (CGFloat)angleScaleForAngle:(CGFloat)anAngle;

/* returns the rect for an image-item */
- (CGRect)rectForItem:(NSUInteger)index withItemSize:(CGSize)itemSize;

/* returns the layers frane in view-coordinate space */
- (NSRect)rectInViewForLayer:(CALayer*)aLayer;

/* returns the point which the enclosing CAScrollLayer needs to be scrolled to to show the selected layer centered */
- (CGPoint)selectedScrollPoint;

/* returns the correct items size for a specific rect, respecting layout properties */
- (CGSize)itemSizeForRect:(CGRect)visibleRect;

/* returns a bottom centered rect with a specific aspectratio for a equal-sized itemRect */
- (CGRect)boundsFromContentWithAspectRatio:(CGFloat)aspectRatio inItemRect:(CGRect)itemRect;

/* returns the horizontal offset for a specified item index, returns zero for selected index, a negative value for items in the left stack, a positive value for items in the right stack */
- (CGFloat)horizontalOffsetForItem:(NSUInteger)anIndex withItemWidth:(CGFloat)itemWidth stackedAngle:(CGFloat)aStackedAngle itemSpacing:(CGFloat)itemSpacing selectedIndex:(NSUInteger)theSelection;

/* performs hittesting and returns the modellayer at the hitpoint */
- (CALayer*)hitLayerAtPoint:(CGPoint)aPoint;

/* returns the corresponding item, which either needs to support the MMFlowViewItem-protocol (datasource) or ist the entity-type in the bound array-controller */
- (id)imageItemForIndex:(NSUInteger)anIndex;

/* returns the image uid for an item, see MMFlowViewItem protocol */
- (NSString*)imageUIDForItem:(id)anItem;

/* returns the representation type for an item, see MMFlowViewItem protocol */
- (NSString*)imageRepresentationTypeForItem:(id)anItem;

/* returns title for an item, see MMFlowViewItem protocol */
- (NSString*)imageTitleForItem:(id)anItem;

/* returns the image representation for an item, see MMFlowViewItem protocol */
- (id)imageRepresentationForItem:(id)anItem;

/* returns title for an specific index */
- (NSString*)titleAtIndex:(NSUInteger)anIndex;

/* returns an autoreleased system provided default image */
- (CGImageRef)defaultImageForItem:(id)anItem withSize:(CGSize)imageSize;

/* retuns YES if item at index is a movie */
- (BOOL)isMovieAtIndex:(NSUInteger)anIndex;

/* returns the UTI for item at index */
- (NSString*)uniformTypeIdentifierAtIndex:(NSUInteger)anIndex;

/* returns the size-difference in percent for an image */
- (CGFloat)differenceForImage:(CGImageRef)anImage forDesiredSize:(CGSize)desiredSize;

/* sets the frame and all related attributes on a itemlayer */
- (void)setFrameForLayer:(CAReplicatorLayer*)itemLayer atIndex:(NSUInteger)anIndex withItemSize:(CGSize)itemSize;

/* sets the image for an itemlayer */
- (void)setImage:(CGImageRef)anImage atIndex:(NSUInteger)anIndex;

/* invoked after selecting a layer at index and performs all necessary checking for type (such as movie, quartz composer composition etc) */
- (void)selectLayerAtIndex:(NSUInteger)anIndex;

/* invoked before deselecting a layer, performs cleanup work, such as removing content-sublayers */
- (void)deselectLayerAtIndex:(NSUInteger)anIndex;

/* creates the NSTrackingAreas for selected layer */
- (void)setupTrackingAreas;

/* checks image cache for an image with an specific uid, may return NULL */
- (CGImageRef)lookupForImageUID:(NSString*)anUID;

/* highlights a layer, invoked in dragging */
- (void)highlightLayer:(CALayer*)aLayer highlighted:(BOOL)isHighlighted cornerRadius:(CGFloat)cornerRadius highlightingColor:(CGColorRef)highlightingColor;

/* helper method for binding related meta-data */
- (void)setInfo:(NSDictionary*)infoDict forBinding:(NSString*)aBinding;

/* starts observing items in a collection */
- (void)startObservingCollection:(NSArray*)aCollection atKeyPaths:(NSSet*)keyPaths;

/* stops observing items a collection, removes all observations on sub-keypaths */
- (void)stopObservingCollection:(NSArray*)aCollection atKeyPaths:(NSSet*)keyPaths;

@end

@implementation MMFlowView

@synthesize backgroundLayer;
@synthesize titleLayer;
@synthesize scrollLayer;
@synthesize containerLayer;
@synthesize scrollBarLayer;
@synthesize dataSource;
@synthesize delegate;
@synthesize stackedAngle;
@synthesize selectedIndex;
@synthesize spacing;
@synthesize stackedScale;
@synthesize selectedScale;
@synthesize reflectionOffset;
@synthesize showsReflection;
@synthesize numberOfItems;
@synthesize visibleItemIndexes;
@synthesize operationQueue;
@synthesize imageCache;
@synthesize scrollDuration;
@synthesize draggingKnob;
@synthesize itemScale;
@synthesize mouseDownInKnob;
@synthesize leftTransform;
@synthesize rightTransform;
@synthesize perspective;
@synthesize previewScale;
@synthesize selectedLayer;
@synthesize canControlQuickLookPanel;
@synthesize highlightedLayer;
@synthesize observedItems;
@synthesize bindingInfo;
@synthesize layerQueue;
@synthesize imageRepresentationKeyPath;
@synthesize imageRepresentationTypeKeyPath;
@synthesize imageUIDKeyPath;
@synthesize imageTitleKeyPath;

#pragma mark -
#pragma mark Class methods

+ (id)defaultAnimationForKey:(NSString *)key
{
	if ( [ key isEqualToString:kMMFlowViewSpacingKey ] ||
		[ key isEqualToString:kMMFlowViewStackedAngleKey ] ) {
		return [ CABasicAnimation animation ];
	}
	else {
		return [ super defaultAnimationForKey:key ];
	}
}

+ (CGImageRef)defaultImage
{
	static CGImageRef image = NULL;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CGRect imageRect = CGRectMake( 0, 0, kDefaultItemSize, kDefaultItemSize );
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		if ( colorSpace ) {
			CGContextRef context = CGBitmapContextCreate( NULL, imageRect.size.width, imageRect.size.height, 8, imageRect.size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst );
			CGColorSpaceRelease(colorSpace);
			NSGradient *gradient = [ [ NSGradient alloc ] initWithStartingColor:[NSColor colorWithDeviceWhite:0.8 alpha:0.7] endingColor:[NSColor colorWithDeviceWhite:0.6 alpha:0.7]];
			NSGraphicsContext *nsContext = [ NSGraphicsContext graphicsContextWithGraphicsPort:context
																					   flipped:NO ];
			[ NSGraphicsContext saveGraphicsState ];
			[ NSGraphicsContext setCurrentContext:nsContext ];
			[ gradient drawInRect:NSMakeRect(0, 0, imageRect.size.width, imageRect.size.height)
						   angle:0 ];
			[ NSGraphicsContext restoreGraphicsState ];
			image = CGBitmapContextCreateImage( context );
			CGContextRelease( context );
			[ gradient release ];
		}
	});
	return image;
}

+ (NSArray*)backgroundGradientColors
{
	return [ NSArray arrayWithObjects:(__bridge id)[ [ NSColor colorWithCalibratedRed:52.f / 255.f green:55.f / 255.f blue:69.f / 255.f alpha:1.f ] CGColor ],
					(__bridge id)[ [ NSColor colorWithCalibratedRed:36.f / 255.f green:37.f / 255.f blue:48.f / 255.f alpha:1.f ] CGColor ],
					(__bridge id)[[ NSColor blackColor ] CGColor ], nil ];
}

+ (NSArray*)backgroundGradientLocations
{
	return [ NSArray arrayWithObjects:[ NSNumber numberWithDouble:0. ],
			[ NSNumber numberWithDouble:.2 ],
			[ NSNumber numberWithDouble:1. ], nil ];
}

+ (NSSet*)pathRepresentationTypes
{
	static NSSet *pathRepresentationTypes = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		pathRepresentationTypes = [ [NSSet alloc ] initWithObjects:kMMFlowViewURLRepresentationType,
								   kMMFlowViewPathRepresentationType,
								   kMMFlowViewQTMoviePathRepresentationType,
								   kMMFlowViewQCCompositionPathRepresentationType,
								   kMMFlowViewQuickLookPathRepresentationType,
								   kMMFlowViewIconRefPathRepresentationType, nil ];
	});
	return pathRepresentationTypes;
}

+ (NSDictionary*)uniformTypesDictionary
{
	static NSDictionary *utiDictionary = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		utiDictionary = [ [ NSDictionary alloc ] initWithObjectsAndKeys:kMMFlowViewCGImageRepresentationType, (NSString*)kUTTypeImage,
						 kMMFlowViewNSImageRepresentationType, (NSString*)kUTTypeImage,
						 kMMFlowViewNSBitmapRepresentationType, (NSString*)kUTTypeImage,
						 kMMFlowViewQTMovieRepresentationType, (NSString*)kUTTypeMovie,
						 kMMFlowViewQCCompositionRepresentationType, (NSString*)kUTTypeQuartzComposerComposition,
						 kMMFlowViewIconRefRepresentationType, (NSString*)kUTTypeImage,
						 kMMFlowViewPDFPageRepresentationType, (NSString*)kUTTypePDF, nil ];
	});
	return utiDictionary;
}

#pragma mark -
#pragma mark NSControl overrides

+ (void)initialize {
	if ( self == [ MMFlowView class ] ) {		// Do it once
		[ self exposeBinding:NSContentArrayBinding ];
		[ self exposeBinding:kMMFlowViewImageRepresentationBinding ];
		[ self exposeBinding:kMMFlowViewImageRepresentationTypeBinding ];
		[ self exposeBinding:kMMFlowViewImageUIDBinding ];
		[ self exposeBinding:kMMFlowViewImageTitleBinding ];
		[ self setCellClass:[ NSActionCell class ] ];
	}
}

+ (Class)cellClass
{
    return [ NSActionCell class ];
}

#pragma mark -
#pragma mark Image creation

+ (CGImageRef)newImageFromQuickLookURL:(NSURL*)anURL withSize:(CGSize)imageSize
{
	NSDictionary *quickLookOptions = [ NSDictionary dictionaryWithObjectsAndKeys:
									  (id)kCFBooleanFalse, (id)kQLThumbnailOptionIconModeKey,
									  nil ];
	CGImageRef image = QLThumbnailImageCreate(NULL, (CFURLRef)anURL, imageSize, (CFDictionaryRef)quickLookOptions );
	return image;
}

+ (CGImageRef)newImageFromURL:(NSURL*)anURL withSize:(CGSize)imageSize
{
	return [ self newImageFromQuickLookURL:anURL withSize:imageSize ];
}

+ (CGImageRef)newImageFromPDFPage:(CGPDFPageRef)pdfPage withSize:(CGSize)imageSize andTransparentBackground:(BOOL)transparentBackground
{
	size_t width = imageSize.width;
	size_t height = imageSize.height;
	size_t bytesPerLine = width * 4;
	uint64_t size = (uint64_t)height * (uint64_t)bytesPerLine;

	if ((size == 0) || (size > SIZE_MAX))
		return NULL;
	
	void *bitmapData = calloc( 1, size );
	if (!bitmapData)
		return NULL;

	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(&kCGColorSpaceSRGB ? kCGColorSpaceSRGB : kCGColorSpaceGenericRGB);

	CGContextRef context = CGBitmapContextCreate(bitmapData, width, height, 8, bytesPerLine, colorSpace, kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorSpace);

	if ( transparentBackground ) {
		CGContextClearRect( context, CGRectMake(0, 0, width, height) );
	}
	else {
		CGContextSetRGBFillColor( context, 1, 1, 1, 1 ); // white
		CGContextFillRect( context, CGRectMake(0, 0, imageSize.width, imageSize.height) );
	}
	CGRect imageRect = CGRectMake( 0, 0, imageSize.width, imageSize.height );
	CGRect boxRect = CGPDFPageGetBoxRect( pdfPage, kCGPDFCropBox );
	CGAffineTransform drawingTransform;
	if ( imageSize.width <= boxRect.size.width ) {
		drawingTransform = CGPDFPageGetDrawingTransform(pdfPage, kCGPDFCropBox, imageRect, 0, kCFBooleanTrue );
	}
	else {
		CGFloat scaleX = imageSize.width / boxRect.size.width;
		//CGFloat scaleY = imageSize.height / boxRect.size.height;

		drawingTransform = CGAffineTransformMakeTranslation( -boxRect.origin.x, -boxRect.origin.y );
		drawingTransform = CGAffineTransformScale(drawingTransform, scaleX, scaleX );
	}
	CGContextConcatCTM( context, drawingTransform );

	CGContextDrawPDFPage( context, pdfPage );
	
	CGImageRef pdfImage = CGBitmapContextCreateImage( context );

	CGContextRelease(context);
	
	free(bitmapData);
	
	return pdfImage;
}

+ (CGImageRef)newImageFromPath:(NSString*)aPath withSize:(CGSize)imageSize
{
	return [ self newImageFromURL:[ NSURL fileURLWithPath:aPath ] withSize:imageSize ];
}

+ (CGImageRef)newImageFromNSImage:(NSImage*)anImage withSize:(CGSize)imageSize
{
	NSRect proposedRect = NSMakeRect(0, 0, imageSize.width, imageSize.height);
	return CGImageRetain( [ anImage CGImageForProposedRect:&proposedRect
									context:nil
									  hints:nil ] );
}

+ (CGImageRef)newImageFromCGImageSource:(CGImageSourceRef)imageSource withSize:(CGSize)imageSize
{
	CFStringRef imageSourceType = CGImageSourceGetType(imageSource);
	CGImageRef image = NULL;
	if ( imageSourceType ) {
		// Ask ImageIO to create a thumbnail from the file's image data,
		// if it can't find a suitable existing thumbnail image in the file.
		// We could comment out the following line if only existing thumbnails were desired for some reason
		// (maybe to favor performance over being guaranteed a complete set of thumbnails).
		NSDictionary *options = [ NSDictionary dictionaryWithObjectsAndKeys:[ NSNumber numberWithBool:YES ], (NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent,
								 [ NSNumber numberWithInteger:MAX(imageSize.width, imageSize.height) ], (NSString *)kCGImageSourceThumbnailMaxPixelSize,
								 nil ];
		image = CGImageSourceCreateThumbnailAtIndex( imageSource, 0, (CFDictionaryRef)options );
	}
	return image;
}

+ (CGImageRef)newImageFromNSBitmapImage:(NSBitmapImageRep*)bitmapImage withSize:(CGSize)imageSize
{
	NSRect proposedRect = NSMakeRect(0, 0, imageSize.width, imageSize.height);
	return CGImageRetain( [ bitmapImage CGImageForProposedRect:&proposedRect
										context:nil
										  hints:nil ] );
}

+ (CGImageRef)newImageFromData:(NSData*)data withSize:(CGSize)imageSize
{
	NSDictionary *options = [ NSDictionary dictionaryWithObjectsAndKeys:[ NSNumber numberWithBool:YES ], (NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent,
							 [ NSNumber numberWithInteger:MAX(imageSize.width, imageSize.height) ], (NSString *)kCGImageSourceThumbnailMaxPixelSize,
							 nil ];
	CGImageRef image = NULL;
	CGImageSourceRef imageSource = CGImageSourceCreateWithData( (CFDataRef)data, (CFDictionaryRef)options );
	if ( imageSource ) {
		image = [ self newImageFromCGImageSource:imageSource
									 withSize:imageSize ];
		CFRelease(imageSource);
	}
	return image;
}

+ (CGImageRef)newImageFromIcon:(IconRef)anIcon withSize:(CGSize)imageSize
{
	NSImage *image = [ [ [ NSImage alloc ] initWithIconRef:anIcon ] autorelease ];
	return [ self newImageFromNSImage:image
						  withSize:imageSize ];
}

+ (CGImageRef)newImageFromIconRefPath:(NSString*)iconPath withSize:(CGSize)imageSize
{
	return [ self newImageFromPath:iconPath
					   withSize:imageSize ];
}

+ (CGImageRef)newImageFromRepresentation:(id)imageRepresentation withType:(NSString*)representationType size:(CGSize)imageSize
{
	CGImageRef image = NULL;
	if ( [ [ [ self class ] pathRepresentationTypes ] containsObject:representationType ] ) {
		NSURL *imageURL = [ imageRepresentation isKindOfClass:[ NSURL class ] ] ? imageRepresentation : [ NSURL fileURLWithPath:imageRepresentation ];
		image = [ self newImageFromURL:imageURL
							  withSize:imageSize ];
	}
	else if ( [ representationType isEqualToString:kMMFlowViewCGImageRepresentationType ] ) {
		image = (CGImageRef)imageRepresentation;
	}
	else if ( [ representationType isEqualToString:kMMFlowViewPDFPageRepresentationType ] ) {
		CGPDFPageRef pdfPage = [ imageRepresentation isKindOfClass:[ PDFPage class ] ] ? [ imageRepresentation pageRef ] : (CGPDFPageRef)imageRepresentation;
		image = [ self newImageFromPDFPage:(CGPDFPageRef)pdfPage
								  withSize:imageSize
				  andTransparentBackground:NO ];
	}
	else if ( [ representationType isEqualToString:kMMFlowViewNSImageRepresentationType ] ) {
		image = [ self newImageFromNSImage:(NSImage*)imageRepresentation
								  withSize:imageSize ];
	}
	else if ( [ representationType isEqualToString:kMMFlowViewCGImageSourceRepresentationType ] ) {
		image = [ self newImageFromCGImageSource:(CGImageSourceRef)imageRepresentation
										withSize:imageSize ];
	}
	else if ( [ representationType isEqualToString:kMMFlowViewNSDataRepresentationType ] ) {
		image = [ self newImageFromData:(NSData*)imageRepresentation
							   withSize:imageSize ];
	}
	else if ( [ representationType isEqualToString:kMMFlowViewNSBitmapRepresentationType ] ) {
		image = [ self newImageFromNSBitmapImage:(NSBitmapImageRep*)imageRepresentation
										withSize:imageSize ];
	}
	else if ( [ representationType isEqualToString:kMMFlowViewIconRefRepresentationType ] ) {
		image = [ self newImageFromIcon:(IconRef)imageRepresentation
							   withSize:imageSize ];
	}
	else if ( [ representationType isEqualToString:kMMFlowViewQTMovieRepresentationType ] ) {
		[ QTMovie enterQTKitOnThread ];
		QTMovie *movie = imageRepresentation;
		if ( [ movie attachToCurrentThread ] ) {
			image = [ self newImageFromNSImage:[ movie posterImage ]
									  withSize:imageSize ];
			[ movie detachFromCurrentThread ];
		}
		[ QTMovie exitQTKitOnThread ];
	}
	return image;
}

+ (QTMovie*)movieFromRepresentation:(id)representation withType:(NSString*)representationType
{
	if ( [ representationType isEqualToString:kMMFlowViewQTMovieRepresentationType ] ) {
		return representation;
	}
	else if ( [ [ [ self class ] pathRepresentationTypes ] containsObject:representationType ] ) {
		NSURL *movieURL = [ representation isKindOfClass:[ NSURL class ] ] ? representation : [ NSURL fileURLWithPath:representation ];
		
		if ( [ QTMovie canInitWithURL:movieURL ] ) {
			NSDictionary *options = [ NSDictionary dictionaryWithObjectsAndKeys:movieURL, QTMovieURLAttribute,
									 [ NSNumber numberWithBool:YES ], QTMovieOpenForPlaybackAttribute, nil ];
			NSError *error = nil;
			QTMovie *movie = [ QTMovie movieWithAttributes:options
													 error:&error ];
			if ( error ) {
				NSLog( @"Error: %@", error );
			}
			return movie;
		}
	}
	return nil;
}

+ (QCComposition*)compositionFromRepresentation:(id)representation withType:(NSString*)representationType
{
	if ( [representationType isEqualToString:kMMFlowViewQCCompositionRepresentationType ] ) {
		return representation;
	}
	else if ( [ [ [ self class ] pathRepresentationTypes ] containsObject:representationType ] ) {
		NSString *path = [ representation isKindOfClass:[ NSURL class ] ] ? [ representation path ] : representation;
		
		return [ QCComposition compositionWithFile:path ];
	}
	return nil;
}

#pragma mark -
#pragma mark Init/Cleanup

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		self.bindingInfo = [ NSMutableDictionary dictionary ];
		self.operationQueue = [[[ NSOperationQueue alloc ] init ] autorelease ];
		self.imageCache = [[[ NSCache alloc ] init ] autorelease ];
		self.layerQueue = [ NSMutableArray array ];
		[ self setDefaults ];
		[ self setupLayers ];
		self.title = @"Title";
		[ self setTitleSize:kDefaultTitleSize ];
		[ self registerForDraggedTypes:[ NSArray arrayWithObjects:NSURLPboardType, nil ] ];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [ super initWithCoder:aDecoder ];
	if ( self ) {
		self.bindingInfo = [ NSMutableDictionary dictionary ];
		self.layerQueue = [ NSMutableArray array ];
		self.operationQueue = [[[ NSOperationQueue alloc ] init ] autorelease ];
		self.imageCache = [[[ NSCache alloc ] init ] autorelease ];
		[ self.imageCache setEvictsObjectsWithDiscardedContent:YES ];
		[ self setAcceptsTouchEvents:YES ];
		selectedIndex = NSNotFound;
		if ( [ aDecoder allowsKeyedCoding ] ) {
			self.stackedAngle = [ aDecoder decodeDoubleForKey:kMMFlowViewStackedAngleKey ];
			self.spacing = [ aDecoder decodeDoubleForKey:kMMFlowViewSpacingKey ];
			self.selectedScale = [ aDecoder decodeDoubleForKey:kMMFlowViewSelectedScaleKey ];
			self.stackedScale = [ aDecoder decodeDoubleForKey:kMMFlowViewStackedScaleKey ];
			self.reflectionOffset = [ aDecoder decodeDoubleForKey:kMMFlowViewReflectionOffsetKey ];
			self.showsReflection = [ aDecoder decodeBoolForKey:kMMFlowViewShowsReflectionKey ];
			self.perspective = [ [ aDecoder decodeObjectForKey:kMMFlowViewPerspectiveKey ] CATransform3DValue ];			
			self.scrollDuration = [ aDecoder decodeDoubleForKey:kMMFlowViewScrollDurationKey ];
			self.itemScale = [ aDecoder decodeDoubleForKey:kMMFlowViewItemScaleKey ];
			self.previewScale = [ aDecoder decodeDoubleForKey:kMMFlowViewPreviewScaleKey ];
		}
		else {
			[ self setDefaults ];
			
		}
		[ self setupLayers ];
		self.title = @"";
		[ self setTitleSize:kDefaultTitleSize ];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[ super encodeWithCoder:aCoder ];
	if ( [ aCoder allowsKeyedCoding ] ) {
		[ aCoder encodeDouble:self.stackedAngle forKey:kMMFlowViewStackedAngleKey ];
		[ aCoder encodeDouble:self.spacing forKey:kMMFlowViewSpacingKey ];
		[ aCoder encodeDouble:self.selectedScale forKey:kMMFlowViewSelectedScaleKey ];
		[ aCoder encodeDouble:self.stackedScale forKey:kMMFlowViewStackedScaleKey ];
		[ aCoder encodeDouble:self.reflectionOffset forKey:kMMFlowViewReflectionOffsetKey ];
		[ aCoder encodeDouble:self.showsReflection forKey:kMMFlowViewShowsReflectionKey ];
		[ aCoder encodeObject:[ NSValue valueWithCATransform3D:self.perspective ] forKey:kMMFlowViewPerspectiveKey ];
		[ aCoder encodeDouble:self.scrollDuration forKey:kMMFlowViewScrollDurationKey ];
		[ aCoder encodeDouble:self.itemScale forKey:kMMFlowViewItemScaleKey ];
		[ aCoder encodeDouble:self.previewScale forKey:kMMFlowViewPreviewScaleKey ]; 
	}
	else {
		[ NSException raise:NSInvalidArchiveOperationException format:@"Only supports NSKeyedArchiver coders" ];
	}
}

- (void)dealloc
{
	self.visibleItemIndexes = nil;
	self.layerQueue = nil;
	self.imageRepresentationKeyPath = nil;
	self.imageRepresentationTypeKeyPath = nil;
	self.imageUIDKeyPath = nil;
	self.imageTitleKeyPath = nil;
	self.observedItems = nil;
	self.bindingInfo = nil;
	self.delegate = nil;
	self.dataSource = nil;
    self.backgroundLayer = nil;
	self.titleLayer = nil;
	self.containerLayer = nil;
	self.scrollLayer = nil;
	self.scrollBarLayer = nil;
	[ self.operationQueue cancelAllOperations ];
	self.operationQueue = nil;
	self.imageCache = nil;
	self.selectedLayer = nil;
	self.highlightedLayer = nil;
    [super dealloc];
}

- (void)setDefaults
{
	[ self.imageCache setEvictsObjectsWithDiscardedContent:YES ];
	[ self setAcceptsTouchEvents:YES ];
	self.stackedAngle = kDefaultStackedAngle;
	self.spacing = kDefaultItemSpacing;
	self.selectedScale = kDefaultSelectedScale;
	self.stackedScale = kDefaultStackedScale;
	self.reflectionOffset = kDefaultReflectionOffset;
	selectedIndex = NSNotFound;
	self.showsReflection = YES;
	CATransform3D perspTransform = CATransform3DIdentity;
	perspTransform.m34 = 1. / -kDefaultEyeDistance;
	self.perspective = perspTransform;
	
	self.scrollDuration = kDefaultScrollDuration;
	self.itemScale = kDefaultItemScale;
	self.previewScale = kDefaultPreviewScale;
}


#pragma mark -
#pragma mark Accesors

- (id)title
{
	return self.titleLayer.string;
}

- (void)setTitle:(id)aTitle
{
	self.titleLayer.string = aTitle;
}

- (void)setTitleFont:(NSFont*)aFont
{
	self.titleLayer.font = aFont;
}

- (void)setTitleSize:(CGFloat)aSize
{
	self.titleLayer.fontSize = aSize;
}

- (void)setTitleColor:(NSColor*)aColor
{
	self.titleLayer.foregroundColor = [ aColor CGColor ];
}

- (void)setStackedAngle:(CGFloat)anAngle
{
	if ( anAngle != stackedAngle ) {
		stackedAngle = CLAMP( anAngle, 0., kMaximumStackedAngle );
		self.leftTransform = CATransform3DMakeRotation( DegreesToRadians(anAngle), 0, 1, 0 );
		self.rightTransform = CATransform3DMakeRotation( -DegreesToRadians(anAngle), 0, 1, 0 );
		[ self.scrollLayer setNeedsLayout ];
	}
}

- (void)setSpacing:(CGFloat)aSpacing
{
	if ( aSpacing != spacing ) {
		spacing = aSpacing;
		[ self.scrollLayer setNeedsLayout ];
	}
}

- (void)setSelectedIndex:(NSUInteger)index
{
	if ( ( selectedIndex != index ) && ( index < self.numberOfItems ) ) {
		[ self deselectLayerAtIndex:selectedIndex ];
		selectedIndex = index;
		[ self updateSelectionInRange:NSMakeRange( MIN( index, selectedIndex ), ABS( selectedIndex - index ) ) ];
		[ self selectLayerAtIndex:index ];
		if ( [ self.delegate respondsToSelector:@selector(flowViewSelectionDidChange:) ] ) {
			[ self.delegate flowViewSelectionDidChange:self ];
		}
		if ( self.bindingsEnabled ) {
			[ self.contentArrayController setSelectionIndex:index ];
		}
	}
}

- (void)setShowsReflection:(BOOL)shouldShowReflection
{
	if ( showsReflection != shouldShowReflection ) {
		showsReflection = shouldShowReflection;
		[ self updateReflection ];
	}
}

- (void)setReflectionOffset:(CGFloat)newReflectionOpacity
{
	if ( reflectionOffset != newReflectionOpacity ) {
		reflectionOffset = CLAMP( newReflectionOpacity, -1., 0 );
		[ self updateReflection ];
	}
}

- (void)setItemScale:(CGFloat)newItemScale
{
	if ( itemScale != newItemScale ) {
		itemScale = CLAMP( newItemScale, kMinimumItemScale, kMaximumItemScale );
		[ self.scrollLayer setNeedsLayout ];
	}
}

- (void)setPreviewScale:(CGFloat)aPreviewScale
{
	if ( previewScale != aPreviewScale ) {
		previewScale = CLAMP( aPreviewScale, 0.01, 1. );
		[ self.imageCache removeAllObjects ];
		[ self updateImages ];
	}
}

- (NSUInteger)maximumNumberOfStackedVisibleItems
{
	if ( [ self.visibleItemIndexes count ] ) {
		NSUInteger first = [ self.visibleItemIndexes firstIndex ];
		NSUInteger last = [ self.visibleItemIndexes lastIndex ];

		return MAX( self.selectedIndex - first, last - self.selectedIndex ) + 1;
	}
	else {
		return 0;
	}
}

- (void)setSelectedLayer:(CALayer *)aLayer
{
	if ( aLayer != selectedLayer ) {
		// deselect old layer
		[ selectedLayer setValue:[ NSNumber numberWithBool:NO ]
						  forKey:kMMFlowViewHiglightedLayerKey ];
		[ selectedLayer release ];
		selectedLayer = [ aLayer retain ];
	}
	[ selectedLayer setValue:[ NSNumber numberWithBool:YES ]
					  forKey:kMMFlowViewHiglightedLayerKey ];
}

- (void)setCanControlQuickLookPanel:(BOOL)flag
{
	canControlQuickLookPanel = flag;
}

- (void)setDraggingKnob:(BOOL)flag
{
	if ( draggingKnob != flag ) {
		draggingKnob = flag;
		// update at end of dragging
		if ( !flag ) {
			[ self selectLayerAtIndex:self.selectedIndex ];
		}
	}
}

- (void)setHighlightedLayer:(CALayer *)aLayer
{
	if ( aLayer != highlightedLayer ) {
		[ self highlightLayer:highlightedLayer
				  highlighted:NO
				 cornerRadius:0
			highlightingColor:nil ];
		[ highlightedLayer release ];
		highlightedLayer = [ aLayer retain ];
		[ self highlightLayer:aLayer
				  highlighted:YES
				 cornerRadius:0
			highlightingColor:[ [ NSColor selectedControlColor ] CGColor ] ];
	}
}

#pragma mark -
#pragma mark Layout math

- (NSRect)rectInViewForLayer:(CALayer*)aLayer
{
	CGRect rectInHostingLayer = [ self.layer convertRect:aLayer.frame fromLayer:aLayer ];
	return NSRectFromCGRect( rectInHostingLayer );
}

- (CGSize)itemSizeForRect:(CGRect)visibleRect
{
	CGFloat height = ( visibleRect.size.height - kItemYMargin ) * self.itemScale;
	return CGSizeMake( height, height );
}

- (CGRect)boundsFromContentWithAspectRatio:(CGFloat)aspectRatio inItemRect:(CGRect)itemRect
{
	BOOL isLandscape = aspectRatio >= 1;
	CGFloat newWidth = isLandscape ? itemRect.size.width : itemRect.size.width * aspectRatio;
	CGFloat newHeight = isLandscape ? ( itemRect.size.height / aspectRatio ) : itemRect.size.height;
	return CGRectMake( 0, 0, newWidth, newHeight );
}

- (CGFloat)angleScaleForAngle:(CGFloat)anAngle
{
	return 1. - ( anAngle / kMaximumStackedAngle );
}

- (CGFloat)horizontalOffsetForItem:(NSUInteger)anIndex withItemWidth:(CGFloat)itemWidth stackedAngle:(CGFloat)aStackedAngle itemSpacing:(CGFloat)itemSpacing selectedIndex:(NSUInteger)theSelection
{
	CGFloat stackedWidth = itemWidth * [ self angleScaleForAngle:aStackedAngle ] + itemSpacing;
	CGFloat offset = stackedWidth * anIndex;

	BOOL firstItemSelected = ( theSelection == 0 );
	if ( ( anIndex == theSelection ) && !firstItemSelected ) {
		offset += itemWidth / 2.;
	}
	if ( anIndex > theSelection ) {
		offset += firstItemSelected ? itemWidth / 2. : itemWidth;
	}
	return offset;
}

- (CGRect)rectForItem:(NSUInteger)index withItemSize:(CGSize)itemSize
{
	CGPoint origin = [ self originForItem:index
								 itemSize:itemSize
							 stackedAngle:self.stackedAngle
							  itemSpacing:self.spacing
						 selectedIndex:self.selectedIndex ];
	return CGRectMake( origin.x, origin.y, itemSize.width, itemSize.height );
}

- (CGPoint)originForItem:(NSUInteger)itemIndex itemSize:(CGSize)itemSize stackedAngle:(CGFloat)aStackedAngle itemSpacing:(CGFloat)itemSpacing selectedIndex:(NSUInteger)theSelection
{
	CGPoint origin = CGPointMake( 0, CGRectGetMidY(self.scrollLayer.bounds) - itemSize.height / 2 );
	origin.x += [ self horizontalOffsetForItem:itemIndex
								 withItemWidth:itemSize.width
								  stackedAngle:aStackedAngle
								   itemSpacing:itemSpacing
								 selectedIndex:theSelection ];
	return origin;
}

- (CGPoint)selectedScrollPoint
{
	CGRect scrollRect = self.scrollLayer.bounds;
	CGSize itemSize = [ self itemSizeForRect:scrollRect ];

	CGRect selectedItemRect = [ self rectForItem:self.selectedIndex withItemSize:itemSize ];
	return CGPointMake( selectedItemRect.origin.x - scrollRect.size.width / 2 + itemSize.width / 2, 0 );
}

#pragma mark -
#pragma mark Layer getter

- (CAReplicatorLayer*)itemLayerAtIndex:(NSUInteger)anIndex
{
	return ( [ self.scrollLayer.sublayers count ] > anIndex ) ? [ self.scrollLayer.sublayers objectAtIndex:anIndex ] : nil;
}

- (CALayer*)imageLayerAtIndex:(NSUInteger)anIndex
{
	CALayer *layer = [ self itemLayerAtIndex:anIndex ];
	return [ layer.sublayers objectAtIndex:kImageLayerIndex ];
}

- (QTMovieLayer*)movieLayerAtIndex:(NSUInteger)anIndex
{
	QTMovieLayer *movieLayer = nil;

	CALayer *imageLayer = [ self imageLayerAtIndex:anIndex ];
	if ( [ imageLayer.sublayers count ] && [ [ imageLayer.sublayers objectAtIndex:0 ] isKindOfClass:[ QTMovieLayer class ] ]  ) {
		movieLayer = [ imageLayer.sublayers objectAtIndex:0 ];
	}
	return movieLayer;
}

- (CALayer*)overlayLayerAtIndex:(NSUInteger)anIndex
{
	CALayer *imageLayer = [ self imageLayerAtIndex:anIndex ];
	CALayer *overlay = [ imageLayer valueForKey:kMMFlowViewOverlayLayerKey ];
	if ( overlay == nil && imageLayer.sublayers ) {
		NSArray *overlays = [ imageLayer.sublayers valueForKey:kMMFlowViewOverlayLayerKey ];
		if ( [ overlays count ] ) {
			overlay = [ overlays objectAtIndex:0 ];
			overlay = [ overlay isKindOfClass:[ CALayer class ] ] ? overlay : nil;
		}
	}
	return overlay;
}


- (BOOL)isMovieAtIndex:(NSUInteger)anIndex
{
	return UTTypeConformsTo( (CFStringRef)[ self uniformTypeIdentifierAtIndex:anIndex ], kUTTypeMovie );
}

- (BOOL)isQCCompositionAtIndex:(NSUInteger)anIndex
{
	return UTTypeConformsTo( (CFStringRef)[ self uniformTypeIdentifierAtIndex:anIndex ], (CFStringRef)kUTTypeQuartzComposerComposition );
}

- (NSString*)uniformTypeIdentifierAtIndex:(NSUInteger)anIndex
{
	id item = [ self imageItemForIndex:anIndex ];
	NSString *imageRepresentationType = [ self imageRepresentationTypeForItem:item ];
	id imageRepresentation = [ self imageRepresentationForItem:item ];
	NSString *uti = nil;

	if ( [ [ [ self class ] pathRepresentationTypes ] containsObject:imageRepresentationType ] ) {
		NSString *path = [ imageRepresentation isKindOfClass:[ NSURL class ] ] ? [ imageRepresentation path ] : imageRepresentation;

		NSError *error = nil;
		uti = [ [ NSWorkspace sharedWorkspace ] typeOfFile:path error:&error ];
	}
	else {
		uti = [ [ [ self class ] uniformTypesDictionary ] objectForKey:imageRepresentationType ];
	}
	return uti;
}

- (CALayer*)hitLayerAtPoint:(CGPoint)aPointInView
{
	CALayer *presentationLayer = [ self.layer presentationLayer ];
	CALayer *hitLayer = [ presentationLayer hitTest:aPointInView ];
	return [ hitLayer modelLayer ];
}

- (NSUInteger)indexOfItemAtPoint:(NSPoint)aPoint
{
	CALayer *hitLayer = [ self hitLayerAtPoint:NSPointToCGPoint( aPoint ) ];
	if ( [ hitLayer.name hasPrefix:kMMFlowViewItemContentLayerPrefix ] ) {
		return [ [ hitLayer valueForKey:kMMFlowViewItemIndexKey ] unsignedIntegerValue ];
	}
	return NSNotFound;
}

- (NSRect)itemFrameAtIndex:(NSUInteger)anIndex
{
	CGRect layerFrame = [ self.layer convertRect:[ self rectForItem:anIndex
													   withItemSize:[ self itemSizeForRect:self.scrollLayer.bounds ] ]
									   fromLayer:self.scrollLayer ];
	return NSRectFromCGRect( layerFrame );
}

#pragma mark -
#pragma mark Binding releated accessors

- (NSArrayController*)contentArrayController
{
	return [ [ self infoForBinding:NSContentArrayBinding ] objectForKey:NSObservedObjectKey ];
}

- (NSString*)contentArrayKeyPath
{
	return [ [ self infoForBinding:NSContentArrayBinding ] objectForKey:NSObservedKeyPathKey ];
}

- (NSArray *)contentArray
{
	NSArray *array = [ self.contentArrayController valueForKeyPath:self.contentArrayKeyPath ];
	return array ? array : [ NSArray array ];
}

- (NSSet*)observedItemKeyPaths
{
	NSMutableSet *observedItemKeyPaths = [ NSMutableSet set ];
	if ( self.imageRepresentationKeyPath ) {
		[ observedItemKeyPaths addObject:self.imageRepresentationKeyPath ];
	}
	if ( self.imageRepresentationTypeKeyPath ) {
		[ observedItemKeyPaths addObject:self.imageRepresentationTypeKeyPath ];
	}
	if ( self.imageUIDKeyPath ) {
		[ observedItemKeyPaths addObject:self.imageUIDKeyPath ];
	}
	if ( self.imageTitleKeyPath ) {
		[ observedItemKeyPaths addObject:self.imageTitleKeyPath ];
	}
	return [ NSSet setWithSet:observedItemKeyPaths ];
}

- (BOOL)bindingsEnabled
{
	return [ self infoForBinding:NSContentArrayBinding ] != nil;
}

- (void)setImageRepresentationKeyPath:(NSString *)aKeyPath
{
	if ( aKeyPath != imageRepresentationKeyPath ) {
		if ( imageRepresentationKeyPath ) {
			[ self stopObservingCollection:self.observedItems
								atKeyPaths:[ NSSet setWithObject:imageRepresentationKeyPath ] ];
		}
		[ imageRepresentationKeyPath release ];
		imageRepresentationKeyPath = [ aKeyPath copy ];
		if ( imageRepresentationKeyPath ) {
			[ self startObservingCollection:self.observedItems
								 atKeyPaths:[ NSSet setWithObject:imageRepresentationKeyPath ] ];
		}
	}
}

- (void)setImageRepresentationTypeKeyPath:(NSString *)aKeyPath
{
	if ( aKeyPath != imageRepresentationTypeKeyPath ) {
		if ( imageRepresentationTypeKeyPath ) {
			[ self stopObservingCollection:self.observedItems
								atKeyPaths:[ NSSet setWithObject:imageRepresentationTypeKeyPath ] ];
		}
		[ imageRepresentationTypeKeyPath release ];
		imageRepresentationTypeKeyPath = [ aKeyPath copy ];
		if ( imageRepresentationTypeKeyPath ) {
			[ self startObservingCollection:self.observedItems
								 atKeyPaths:[ NSSet setWithObject:imageRepresentationTypeKeyPath ] ];
		}
	}
}

- (void)setImageUIDKeyPath:(NSString *)aKeyPath
{
	if ( aKeyPath != imageUIDKeyPath ) {
		if ( imageUIDKeyPath ) {
			[ self stopObservingCollection:self.observedItems
								atKeyPaths:[ NSSet setWithObject:imageUIDKeyPath ] ];
		}
		[ imageUIDKeyPath release ];
		imageUIDKeyPath = [ aKeyPath copy ];
		if ( imageUIDKeyPath ) {
			[ self startObservingCollection:self.observedItems
								 atKeyPaths:[ NSSet setWithObject:imageUIDKeyPath ] ];
		}
	}
}

- (void)setImageTitleKeyPath:(NSString *)aKeyPath
{
	if ( aKeyPath != imageTitleKeyPath ) {
		if ( imageTitleKeyPath ) {
			[ self stopObservingCollection:self.observedItems
								atKeyPaths:[ NSSet setWithObject:imageTitleKeyPath ] ];
		}
		[ imageTitleKeyPath release ];
		imageTitleKeyPath = [ aKeyPath copy ];
		if ( imageTitleKeyPath ) {
			[ self startObservingCollection:self.observedItems
								 atKeyPaths:[ NSSet setWithObject:imageTitleKeyPath ] ];
		}
	}
}

#pragma mark -
#pragma mark NSView overrides

- (BOOL)canBecomeKeyView
{
    return YES;
}

- (BOOL)isOpaque
{
	return YES;
}

- (BOOL)needsPanelToBecomeKey
{
	return YES;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	BOOL inWindow = [ self window ] != nil;
	BOOL willBeInWindow = newWindow != nil;
	
	if ( willBeInWindow && !inWindow ) {
		[ self setupLayers ];
		[ self setupTrackingAreas ];
		[ self setupNotifications ];
	}
	else if ( inWindow && !willBeInWindow ) {
		[ self.operationQueue cancelAllOperations ];
		[ self teardownNotifications ];
		self.layer = nil;
	}
	[ super viewWillMoveToWindow:newWindow ];
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
	BOOL willBeInSuperview = newSuperview != nil;
	BOOL inView = [ self superview ] != nil;

	if ( inView && !willBeInSuperview ) {
		[ self stopObservingCollection:self.observedItems atKeyPaths:self.observedItemKeyPaths ];
		for ( NSString *binding in [ self.bindingInfo allKeys ] ) {
			[ self unbind:binding ];
		}
	}
	else if ( willBeInSuperview && !inView ) {
		for ( NSString *binding in [ self.bindingInfo allKeys ] ) {
		}
	}
	[ super viewWillMoveToSuperview:newSuperview ];
}

- (void)viewDidEndLiveResize
{
	//[ self.scrollLayer setNeedsLayout ];
	[ self updateImages ];
}

- (void)updateTrackingAreas
{
	[ super updateTrackingAreas ];
	[ self setupTrackingAreas ];
}

#pragma mark -
#pragma mark NSResponder overrides

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint locationInWindow = [ theEvent locationInWindow ];
	CGPoint mouseInView = NSPointToCGPoint( [ self convertPoint:locationInWindow fromView:nil ] );

	CALayer *hitLayer = [ self hitLayerAtPoint:mouseInView ];
	CALayer *knob = [ self.scrollBarLayer.sublayers objectAtIndex:0 ];

	NSUInteger clickedIndex = [ self indexOfItemAtPoint:[ self convertPoint:locationInWindow fromView:nil ] ];

	// dragging only from selection
	if ( clickedIndex == self.selectedIndex ) {
		id item = [ self imageItemForIndex:clickedIndex ];
		NSString *representationType = [ self imageRepresentationTypeForItem:item ];
		id representation = [ self imageRepresentationForItem:item ];
		NSPasteboard *dragPBoard = [ NSPasteboard pasteboardWithName:NSDragPboard ];
		BOOL isURL = [ [ [ self class ] pathRepresentationTypes ] containsObject:representationType ];

		// ask imagecache for drag image
		NSImage *dragImage = [ [ [ NSImage alloc ] initWithCGImage:[ self lookupForImageUID:[ self imageUIDForItem:item ] ]
															  size:NSSizeFromCGSize(hitLayer.bounds.size) ] autorelease ];
		// double click handling
		if ( [ theEvent clickCount ] > 1 ) {
			if ( [ self.delegate respondsToSelector:@selector(flowView:itemWasDoubleClickedAtIndex:) ] ) {
				[ self.delegate flowView:self itemWasDoubleClickedAtIndex:clickedIndex ];
			}
			else if ( [ self action ] ) {
				[ self sendAction:self.action to:self.target ];
			}
			else if ( isURL ) {
				NSString *filePath = [ representation isKindOfClass:[ NSURL class ] ] ? [ representation path ] : representation;
				[ [ NSWorkspace sharedWorkspace ] openFile:filePath
												 fromImage:dragImage
														at:NSPointFromCGPoint(mouseInView)
													inView:self ];
			}
		}
		else {
			// dragging
			if ( [ self.dataSource respondsToSelector:@selector(flowView:writeDataAtIndex:toPasteboard:) ] ) {
				[ self.dataSource flowView:self
						  writeItemAtIndex:clickedIndex
							  toPasteboard:dragPBoard ];
			}
			else if ( isURL ) {
				NSURL *fileURL = [ representation isKindOfClass:[ NSURL class ] ] ? representation : [ NSURL fileURLWithPath:representation ];
				[ dragPBoard declareTypes:[ NSArray arrayWithObject:NSURLPboardType ]
									owner:nil ];
				[ fileURL writeToPasteboard:dragPBoard ];
			}
			[ self dragImage:dragImage
						  at:[ self itemFrameAtIndex:clickedIndex ].origin
					  offset:NSZeroSize
					   event:theEvent
				  pasteboard:dragPBoard
					  source:self
				   slideBack:YES ];
		}
	}
	else if ( clickedIndex != NSNotFound ) {
		self.selectedIndex = clickedIndex;
	}
	else if ( [ hitLayer.name isEqualToString:kMMFlowViewScrollBarLayerName ] ) {
		CGPoint mouseInScrollBar = [ self.layer convertPoint:mouseInView toLayer:self.scrollBarLayer ];

		if ( mouseInScrollBar.x < knob.frame.origin.x ) {
			[ self moveLeft:self ];
		}
		else {
			[ self moveRight:self ];
		}
	}
	else if ( [ hitLayer.name isEqualToString:kMMFlowViewScrollKnobLayerName ] ) {
		self.mouseDownInKnob = [ self.layer convertPoint:mouseInView toLayer:knob ].x;
		self.draggingKnob = YES;
	}
	self.selectedLayer = hitLayer;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint locationInWindow = [ theEvent locationInWindow ];
	CGPoint mouseInView = NSPointToCGPoint( [ self convertPoint:locationInWindow fromView:nil ] );

	self.selectedLayer = [ self hitLayerAtPoint:mouseInView ];

	if ( self.draggingKnob ) {
		CALayer *knob = [ self.scrollBarLayer.sublayers objectAtIndex:0 ];

		CGPoint mouseInScrollBar = [ self.layer convertPoint:mouseInView toLayer:self.scrollBarLayer ];
		CGFloat maxX = self.scrollBarLayer.bounds.size.width - knob.bounds.size.width;
		CGFloat scrollPoint = CLAMP( mouseInScrollBar.x - self.mouseDownInKnob, 0, maxX );
		self.selectedIndex = ( scrollPoint / maxX ) * self.numberOfItems;
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	self.draggingKnob = NO;
	if ( [ self.selectedLayer respondsToSelector:@selector(performClick:) ] ) {
		[ (id)self.selectedLayer performClick:self ];
	}
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
	NSPoint locationInWindow = [ theEvent locationInWindow ];
	NSUInteger clickedIndex = [ self indexOfItemAtPoint:[ self convertPoint:locationInWindow fromView:nil ] ];
	if ( [ self.delegate respondsToSelector:@selector(flowView:itemWasRightClickedAtIndex:withEvent:) ] &&
		(clickedIndex != NSNotFound ) ) {
		[ self.delegate flowView:self
	  itemWasRightClickedAtIndex:clickedIndex
					   withEvent:theEvent ];
	}
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	[ self mouseEnteredLayerAtIndex:self.selectedIndex ];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[ self mouseExitedLayerAtIndex:self.selectedIndex ];
}

- (void)keyDown:(NSEvent *)theEvent
{
	if ( self.canControlQuickLookPanel ) {
		if ( [ [ theEvent characters ] isEqualToString:@" " ] ) {
			[ self togglePreviewPanel:self ];
		}
	}
	[ super keyDown:theEvent ];
}

- (IBAction)moveLeft:(id)sender
{
	self.selectedIndex = self.selectedIndex - 1;
}

- (IBAction)moveRight:(id)sender
{
	self.selectedIndex = self.selectedIndex + 1;
}

- (void)swipeWithEvent:(NSEvent *)event
{
	self.selectedIndex = self.selectedIndex + ( fabs([ event deltaX ] )> fabs ( [ event deltaY ] ) ? [ event deltaX ] : [ event deltaY ] );
}

- (void)scrollWheel:(NSEvent *)event
{
	self.selectedIndex = self.selectedIndex + ( fabs([ event deltaX ] )> fabs ( [ event deltaY ] ) ? [ event deltaX ] : [ event deltaY ] );
}

#pragma mark -
#pragma mark IBActions

- (IBAction)togglePreviewPanel:(id)previewPanel
{
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    } else {
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
    }
}

#pragma mark -
#pragma mark Data source related methods

- (void)reloadContent
{
	// clear all layers
	//[ self.imageCache removeAllObjects ];
	
	if ( self.bindingsEnabled ) {
		self.numberOfItems = [ self.contentArray count ];
	}
	else if ( [ self.dataSource respondsToSelector:@selector(numberOfItemsInFlowView:) ] &&
		[ self.dataSource respondsToSelector:@selector(flowView:itemAtIndex:) ] ) {
		self.numberOfItems = [ self.dataSource numberOfItemsInFlowView:self ];
	}
	else {
		self.numberOfItems = 0;
	}
	[ CATransaction begin ];
	[ CATransaction setDisableActions:YES ];
	for ( CALayer *itemLayer in self.scrollLayer.sublayers ) {
		[ self enqeueItemLayer:itemLayer ];
	}
	self.scrollLayer.sublayers = [ NSArray array ];

	for ( NSUInteger itemIndex = 0; itemIndex < self.numberOfItems; ++itemIndex ) {
		CALayer *itemLayer = [ self deqeueItemLayer ];
		if ( itemLayer ) {
			[ itemLayer setValue:[ NSNumber numberWithUnsignedInteger:itemIndex ] forKey:kMMFlowViewItemIndexKey ];
			[ itemLayer setValue:[ self imageUIDForItem:[ self imageItemForIndex:itemIndex ] ] forKey:kMMFlowViewItemImageUIDKey ];
			CALayer *imageLayer = [ itemLayer.sublayers objectAtIndex:kImageLayerIndex ];
			[ self setAttributesForItemContentLayer:imageLayer
											atIndex:itemIndex ];
		}
		else {
			itemLayer = [ self createItemLayerWithIndex:itemIndex ];
		}
		[ self.scrollLayer addSublayer:itemLayer ];
	}
	[ CATransaction commit ];
	if ( self.selectedIndex > self.numberOfItems ) {
		self.selectedIndex = 0;
	};
	[ self.scrollLayer setNeedsLayout ];
	[ self updateSelectionInRange:NSMakeRange( 0, self.numberOfItems ) ];
	[ self updateScrollKnob ];
}

- (id)imageItemForIndex:(NSUInteger)anIndex
{
	if ( anIndex == NSNotFound ) {
		return nil;
	}
	if ( self.bindingsEnabled &&
		( anIndex < [ self.contentArray count ] ) ) {
		return [ self.contentArray objectAtIndex:anIndex ];
	}
	else {
		return [ self.dataSource respondsToSelector:@selector(flowView:itemAtIndex:) ] ? [ self.dataSource flowView:self itemAtIndex:anIndex ] : nil;
	}
}

- (NSString*)imageUIDForItem:(id)anItem
{
	if ( self.bindingsEnabled && self.imageUIDKeyPath ) {
		return [ anItem valueForKeyPath:self.imageUIDKeyPath ];
	}
	else {
		return [ anItem respondsToSelector:@selector(imageItemUID) ] ? [ anItem imageItemUID ] : nil;
	}
}

- (NSString*)imageRepresentationTypeForItem:(id)anItem
{
	if ( self.bindingsEnabled && self.imageRepresentationTypeKeyPath ) {
		return [ anItem valueForKeyPath:self.imageRepresentationTypeKeyPath ];
	}
	else {
		return [ anItem respondsToSelector:@selector(imageItemRepresentationType) ] ? [ anItem imageItemRepresentationType ] : nil;
	}
	
}

- (NSString*)imageTitleForItem:(id)anItem
{
	if ( self.bindingsEnabled && self.imageTitleKeyPath ) {
		return [ anItem valueForKeyPath:self.imageTitleKeyPath ];
	}
	else {
		return [ anItem respondsToSelector:@selector(imageItemTitle) ] ? [ anItem imageItemTitle ] : [ NSString stringWithFormat:NSLocalizedString(@"Untitled item", @"Default item title" ) ];
	}
}

- (id)imageRepresentationForItem:(id)anItem
{
	if ( self.bindingsEnabled && self.imageRepresentationKeyPath ) {
		return [ anItem valueForKeyPath:self.imageRepresentationKeyPath ];
	}
	else {
		return [ anItem respondsToSelector:@selector(imageItemRepresentation) ] ? [ anItem imageItemRepresentation ] : nil;
	}
}

- (NSString*)titleAtIndex:(NSUInteger)anIndex
{
	return [ self imageTitleForItem:[ self imageItemForIndex:anIndex ] ];
}

- (CGImageRef)defaultImageForItem:(id)anItem withSize:(CGSize)imageSize
{
	NSString *imageRepresentationType = [ self imageRepresentationTypeForItem:anItem ];

	CGImageRef defaultImage = NULL;

	if ( [ [ [ self class ] pathRepresentationTypes ] containsObject:imageRepresentationType ] ) {
		id imageRepresentation = [ self imageRepresentationForItem:anItem ];
		NSURL *url = [ imageRepresentation isKindOfClass:[ NSURL class ] ] ? imageRepresentation : [ NSURL fileURLWithPath:imageRepresentation ];

		// retrieve icon for filetype
		NSWorkspace *workspace = [ NSWorkspace sharedWorkspace ];
		NSImage *anImage = [ workspace iconForFileType:[ url pathExtension ] ];
		NSRect proposedRect = NSMakeRect(0, 0, imageSize.width, imageSize.height);
		defaultImage = [ anImage CGImageForProposedRect:&proposedRect
													   context:nil
														 hints:nil ];
	}
	return defaultImage;
}

#pragma mark -
#pragma mark Layer setup

- (void)setupLayers
{
	self.backgroundLayer = [ self createBackgroundLayer ];
	self.titleLayer = [ self createTitleLayer ];
	self.containerLayer = [ self createContainerLayer ];
	[ self.backgroundLayer addSublayer:self.containerLayer ];
	[ self.backgroundLayer insertSublayer:self.titleLayer above:self.containerLayer ];
	self.scrollLayer = [ self createScrollLayer ];
	self.scrollBarLayer = [ self createScrollBarLayer ];
	[ self.containerLayer addSublayer:self.scrollLayer ];
	[ self.backgroundLayer insertSublayer:self.scrollBarLayer above:self.containerLayer ];
	[ self setLayer:self.backgroundLayer ];
	[ self setWantsLayer:YES ];
	[ self.scrollLayer setNeedsLayout ];
	[ self.layer setNeedsDisplay ];
}

- (CALayer*)createBackgroundLayer
{
	CAGradientLayer *layer = [ CAGradientLayer layer ];
	layer.position = CGPointMake( 0, 0 );
	layer.bounds = CGRectMake( 0, 0, NSWidth( [ self bounds ] ), NSHeight( [ self bounds ] ) );

	layer.colors = [[ self class ] backgroundGradientColors ];
	layer.locations = [ [ self class ] backgroundGradientLocations ];
	layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	layer.layoutManager = [ CAConstraintLayoutManager layoutManager ];

	MMLayerAccessibilityHelper *axHelper = [ MMLayerAccessibilityHelper layerAccesibilityHelperWithRole:NSAccessibilityListRole
																								 parent:self
																								  layer:layer
																								   view:self ];
	axHelper.writableAttributeNames = [ NSSet setWithObject:NSAccessibilitySelectedChildrenAttribute ];
	axHelper.attributeNames = [ NSSet setWithObjects:NSAccessibilityChildrenAttribute,
							   NSAccessibilitySelectedChildrenAttribute,
							   NSAccessibilityVisibleChildrenAttribute,
							   NSAccessibilityOrientationAttribute, nil ];
	
	MMFlowView * __MM_WEAK_REFERENCE weakSelf = self;
	
	[ axHelper addHandlerForAttribute:NSAccessibilityOrientationAttribute withBlock:^id(MMLayerAccessibilityHelper *helper) {
		return (id)NSAccessibilityHorizontalOrientationValue;
	} ];
	[ axHelper addHandlerForAttribute:NSAccessibilityVisibleChildrenAttribute withBlock:^id(MMLayerAccessibilityHelper *helper) {
		return [ helper.children objectsAtIndexes:weakSelf.visibleItemIndexes ];
	} ];
	[ axHelper addHandlerForAttribute:NSAccessibilitySelectedChildrenAttribute withBlock:^id(MMLayerAccessibilityHelper *helper) {
		return [ helper.children objectAtIndex:weakSelf.selectedIndex ];
	} ];
	[ axHelper addHandlerForWritableAttribute:NSAccessibilitySelectedChildrenAttribute withBlock:^(MMLayerAccessibilityHelper *helper, id aValue ) {
		if ( [ aValue isKindOfClass:[ NSArray class ] ] && [ aValue count ] ) {
			NSNumber *index = [ aValue objectAtIndex:0 ];
			weakSelf.selectedIndex = [ index unsignedIntegerValue ];
		}
	} ];
	[ layer setValue:axHelper
			  forKey:kMMFLowViewAccessibilityHelperKey ];

	return layer;
}

- (CATextLayer*)createTitleLayer
{
	CATextLayer *layer = [ CATextLayer layer ];
	layer.name = kMMFlowViewTitleLayerName;
	layer.alignmentMode = kCAAlignmentCenter;
	layer.fontSize = kDefaultTitleSize;
	[ layer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:kSuperlayerKey attribute:kCAConstraintMinY offset:kTitleOffset ] ];
	[ layer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:kSuperlayerKey attribute:kCAConstraintMidX ] ];
	// disable animation for position
	NSMutableDictionary *customActions = [ NSMutableDictionary dictionaryWithDictionary:[ layer actions ] ];
	// add the new action for sublayers
	[customActions setObject:[NSNull null] forKey:kPositionKey ];
	[customActions setObject:[NSNull null] forKey:kBoundsKey ];
	[customActions setObject:[NSNull null] forKey:kStringKey ];
	// set theLayer actions to the updated dictionary
	layer.actions = customActions;
	return layer;
}

- (CALayer*)createContainerLayer
{
	CALayer *layer = [ CALayer layer ];
	layer.name = kMMFlowViewContainerLayerName;
	[ layer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:kSuperlayerKey attribute:kCAConstraintMidX ] ];
	[ layer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:kSuperlayerKey attribute:kCAConstraintMaxY ] ];
	[ layer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintWidth relativeTo:kSuperlayerKey attribute:kCAConstraintWidth ] ];
	[ layer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:kMMFlowViewTitleLayerName attribute:kCAConstraintMaxY ] ];
	// disable animation for position
	NSMutableDictionary *customActions = [ NSMutableDictionary dictionaryWithDictionary:[ layer actions ] ];
	// add the new action for sublayers
	[customActions setObject:[NSNull null] forKey:kPositionKey ];
	[customActions setObject:[NSNull null] forKey:kBoundsKey ];
	// set theLayer actions to the updated dictionary
	layer.actions = customActions;
	return layer;
}

- (CAScrollLayer*)createScrollLayer
{
	CAScrollLayer *layer = [ CAScrollLayer layer ];
	layer.scrollMode = kCAScrollHorizontally;
	layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	layer.layoutManager = self;
	layer.sublayerTransform = perspective;
	layer.masksToBounds = NO;
	layer.delegate = self;
	return layer;
}

- (CAReplicatorLayer*)createItemLayerWithIndex:(NSUInteger)anIndex
{
	id anItem = [ self imageItemForIndex:anIndex ];
	CAReplicatorLayer *layer = [ CAReplicatorLayer layer ];
	CGRect rect = CGRectMake(0, 0, kDefaultItemSize, kDefaultItemSize );
	layer.frame = rect;
	layer.instanceCount = 2;
	layer.instanceBlueOffset = self.reflectionOffset;
	layer.instanceGreenOffset = self.reflectionOffset;
	layer.instanceRedOffset = self.reflectionOffset;
	layer.preservesDepth = YES;
	[ layer setValue:[ self imageUIDForItem:anItem ]
			  forKey:kMMFlowViewItemImageUIDKey ];
	[ layer setValue:[ NSNumber numberWithUnsignedInteger:anIndex ]
			  forKey:kMMFlowViewItemIndexKey ];
	CALayer *imageLayer = [ self createImageLayer ];
	[ self setAttributesForItemContentLayer:imageLayer
									atIndex:anIndex ];
	[ layer addSublayer:imageLayer ];
	return layer;
}

- (void)setAttributesForItemContentLayer:(CALayer*)imageLayer atIndex:(NSUInteger)anIndex
{
	[ imageLayer setValue:[ self imageUIDForItem:[ self imageItemForIndex:anIndex ] ]
				   forKey:kMMFlowViewItemImageUIDKey ];
	NSString *suffix = kMMFlowViewImageLayerSuffix;
	if ( [ self isQCCompositionAtIndex:anIndex ] ) {
		suffix = kMMFlowViewQCCompositionLayerSuffix;
	}
	else if ( [ self isMovieAtIndex:anIndex ] ) {
		suffix = kMMFlowViewMovieLayerSuffix;
	}
	imageLayer.name = [ NSString stringWithFormat:@"%@%@", kMMFlowViewItemContentLayerPrefix,  suffix ];

	[ imageLayer setValue:[ NSNumber numberWithUnsignedInteger:anIndex ]
				   forKey:kMMFlowViewItemIndexKey ];
	// disable animation for position
	NSMutableDictionary *customActions = [ NSMutableDictionary dictionaryWithDictionary:[ imageLayer actions ] ];
	// add the new action for sublayers
	CATransition *fadeTransition = [ CATransition animation ];
	fadeTransition.type = kCATransitionFade;
	fadeTransition.duration = 0.5;
	CATransition *revealTransition = [ CATransition animation ];
	revealTransition.type = kCATransitionReveal;
	revealTransition.duration = 0.5;
	//[ customActions setObject:fadeTransition forKey:@"contents" ];
	[ customActions setObject:revealTransition forKey:kCAOnOrderIn ];
	[ customActions setObject:fadeTransition forKey:kCAOnOrderOut ];
	[ customActions setObject:[ NSNull null ] forKey:kContentsKey ];
	[customActions setObject:[ NSNull null ] forKey:kBoundsKey ];
	// set theLayer actions to the updated dictionary
	imageLayer.actions = customActions;

	MMLayerAccessibilityHelper *axParent = [self.backgroundLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];
	MMLayerAccessibilityHelper *axHelper = [ MMLayerAccessibilityHelper layerAccesibilityHelperWithRole:NSAccessibilityImageRole
																								 parent:axParent
																								  layer:imageLayer
																								   view:self ];
	axHelper.writableAttributeNames = [ NSSet setWithObjects:NSAccessibilitySelectedAttribute, nil ];
	axHelper.attributeNames = [ NSSet setWithObjects:NSAccessibilityTitleAttribute, NSAccessibilitySelectedAttribute, nil ];
	MMFlowView * __MM_WEAK_REFERENCE weakSelf = self;
	[ axHelper addHandlerForAttribute:NSAccessibilityTitleAttribute withBlock:^id(MMLayerAccessibilityHelper *helper) {
		return [ weakSelf titleAtIndex:anIndex ];
	} ];
	[ axHelper addHandlerForAttribute:NSAccessibilitySelectedAttribute withBlock:^id(MMLayerAccessibilityHelper *helper) {
		return [ NSNumber numberWithBool:( weakSelf.selectedIndex == anIndex ) ];
	} ];
	[ axHelper addHandlerForWritableAttribute:NSAccessibilitySelectedAttribute withBlock:^(MMLayerAccessibilityHelper *helper, id aValue) {
		if ( [ aValue boolValue ] ) {
			weakSelf.selectedIndex = anIndex;
		}
	} ];
	[ imageLayer setValue:axHelper
				   forKey:kMMFLowViewAccessibilityHelperKey ];
	[ axParent addChildrenObject:axHelper ];
}

- (void)setAttributesForSublayer:(CALayer*)sublayer
{
	[ sublayer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintWidth relativeTo:kSuperlayerKey attribute:kCAConstraintWidth ] ];
	[ sublayer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintHeight relativeTo:kSuperlayerKey attribute:kCAConstraintHeight ] ];
	[ sublayer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:kSuperlayerKey attribute:kCAConstraintMidX ] ];
	[ sublayer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:kSuperlayerKey attribute:kCAConstraintMidY ] ];
	NSMutableDictionary *customActions = [ NSMutableDictionary dictionaryWithDictionary:[ sublayer actions ] ];
	// add the new action for sublayers
	[customActions setObject:[ NSNull null] forKey:kPositionKey ];
	[customActions setObject:[ NSNull null ] forKey:kBoundsKey ];
	// set theLayer actions to the updated dictionary
	sublayer.actions = customActions;
	sublayer.contentsGravity = kCAGravityResizeAspectFill;
}

- (CALayer*)createImageLayer
{
	CALayer *imageLayer = [ CALayer layer ];
	imageLayer.name = [ NSString stringWithFormat:@"%@%@", kMMFlowViewItemContentLayerPrefix, kMMFlowViewImageLayerSuffix ];
	imageLayer.contentsGravity = kCAGravityResizeAspect;
	imageLayer.layoutManager = [ CAConstraintLayoutManager layoutManager ];
	return imageLayer;
}

- (QTMovieLayer*)createMovieLayerWithMovie:(QTMovie*)aMovie atIndex:(NSUInteger)anIndex
{
	QTMovieLayer *movieLayer = [ QTMovieLayer layerWithMovie:aMovie ];
	movieLayer.name = [ NSString stringWithFormat:@"%@%@", kMMFlowViewItemContentLayerPrefix, kMMFlowViewMovieLayerSuffix ];
	[ self setAttributesForSublayer:movieLayer ];
	movieLayer.layoutManager = [ CAConstraintLayoutManager layoutManager ];
	MMVideoOverlayLayer *overlay = [ self createMovieOverlayLayerWithIndex:anIndex ];
	[ movieLayer setValue:overlay forKey:kMMFlowViewOverlayLayerKey ];
	[ movieLayer addSublayer:overlay ];
	return movieLayer;
}

- (QCCompositionLayer*)createQCCompositionLayerWithQCComposition:(QCComposition*)aComposition atIndex:(NSUInteger)anIndex
{
	QCCompositionLayer *compositionLayer = [ QCCompositionLayer compositionLayerWithComposition:aComposition ];
	compositionLayer.name = [ NSString stringWithFormat:@"%@%@", kMMFlowViewItemContentLayerPrefix, kMMFlowViewQCCompositionLayerSuffix ];
	[ self setAttributesForSublayer:compositionLayer ];
	return compositionLayer;
}

- (CALayer*)createScrollBarLayer
{
	CALayer *layer = [ CALayer layer ];
	layer.name = kMMFlowViewScrollBarLayerName;
	layer.backgroundColor = [ [ NSColor blackColor ] CGColor ];
	layer.borderColor = [ [ NSColor grayColor ] CGColor ];
	layer.opaque = YES;
	layer.borderWidth = kScrollBarBorderWidth;
	layer.cornerRadius = kScrollBarCornerRadius;
	layer.frame = CGRectMake( 0, 0, kScrollBarHeight, kScrollBarHeight );
	[ layer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:kSuperlayerKey attribute:kCAConstraintMidX ] ];
	[ layer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:kSuperlayerKey attribute:kCAConstraintMinY offset:kScrollBarYOffset ] ];
	[ layer addConstraint:[ CAConstraint constraintWithAttribute:kCAConstraintWidth relativeTo:kSuperlayerKey attribute:kCAConstraintWidth scale:kScrollBarScale offset:0 ] ];
	// disable animation for position
	NSMutableDictionary *customActions = [ NSMutableDictionary dictionaryWithDictionary:[ layer actions ] ];
	// add the new action for sublayers
	[customActions setObject:[NSNull null] forKey:kPositionKey ];
	[customActions setObject:[ NSNull null ] forKey:kBoundsKey ];
	// set theLayer actions to the updated dictionary
	layer.actions = customActions;

	MMLayerAccessibilityHelper *scrollBarAXHelper = [ MMLayerAccessibilityHelper layerAccesibilityHelperWithRole:NSAccessibilityScrollBarRole
																										  parent:self
																										   layer:layer
																											view:self ];
	scrollBarAXHelper.attributeNames = [ NSSet setWithObjects:NSAccessibilityOrientationAttribute, NSAccessibilityChildrenAttribute, nil ];
	[ scrollBarAXHelper addHandlerForAttribute:NSAccessibilityOrientationAttribute
									 withBlock:^id(MMLayerAccessibilityHelper *helper) {
		return (id)NSAccessibilityHorizontalOrientationValue;
	} ];
	[ layer setValue:scrollBarAXHelper forKey:kMMFLowViewAccessibilityHelperKey ];

	CAGradientLayer *knobLayer = [ CAGradientLayer layer ];
	knobLayer.name = kMMFlowViewScrollKnobLayerName;
	knobLayer.frame = CGRectMake( 10, 2, kScrollBarHeight*2 , kScrollBarHeight - 4 );
	//knobLayer.opaque = YES;
	//knobLayer.opacity = 1.f;
	//knobLayer.anchorPoint = CGPointMake(0.5, 0.5);
	knobLayer.needsDisplayOnBoundsChange = YES;
	knobLayer.borderColor = [ [ NSColor grayColor ] CGColor ];
	knobLayer.borderWidth = 1.f;
	knobLayer.cornerRadius = kScrollBarCornerRadius - 1;
	knobLayer.startPoint = CGPointMake( 0.5, 1. );
	knobLayer.anchorPoint = CGPointMake( 0.5, 0.5 );
	knobLayer.endPoint = CGPointMake( 0.5, 0. );
	knobLayer.colors = [ NSArray arrayWithObjects: (__bridge id)[ [ NSColor colorWithCalibratedRed:64.f / 255.f green:64.f / 255.f blue:74.f / 255.f alpha:1 ] CGColor ],
						(__bridge id)[[ NSColor colorWithCalibratedRed:46.f / 255.f green:46.f / 255.f blue:58.f / 255.f alpha:1.f ] CGColor ],
						(__bridge id)[[ NSColor colorWithCalibratedRed:37.f / 255.f green:37.f / 255.f blue:50.f / 255.f alpha:1.f ] CGColor ],
						(__bridge id)[[ NSColor colorWithCalibratedRed:51.f / 255.f green:52.f / 255.f blue:66.f / 255.f alpha:1.f ] CGColor ], nil ];
	knobLayer.locations = [ NSArray arrayWithObjects:[ NSNumber numberWithDouble:0. ],
						   [ NSNumber numberWithDouble:0.5 ],
						   [ NSNumber numberWithDouble:0.51 ],
						   [ NSNumber numberWithDouble:1. ], nil ];
	knobLayer.type = kCAGradientLayerAxial;
	[ knobLayer setNeedsDisplay ];
	// disable animation for position
	customActions = [ NSMutableDictionary dictionaryWithDictionary:[ knobLayer actions ] ];
	// add the new action for sublayers
	[customActions setObject:[NSNull null] forKey:kPositionKey ];
	[customActions setObject:[ NSNull null ] forKey:kBoundsKey ];
	// set theLayer actions to the updated dictionary
	knobLayer.actions = customActions;
	
	[ layer addSublayer:knobLayer ];

	MMLayerAccessibilityHelper *knobAXHelper = [ MMLayerAccessibilityHelper layerAccesibilityHelperWithRole:NSAccessibilityValueIndicatorRole
																									 parent:scrollBarAXHelper
																									  layer:knobLayer
																									   view:self ];
	[ scrollBarAXHelper addChildrenObject:knobAXHelper ];
	knobAXHelper.attributeNames = [ NSSet setWithObjects:NSAccessibilityValueAttribute, nil ];
	MMFlowView * __MM_WEAK_REFERENCE weakSelf = self;
	[ knobAXHelper addHandlerForAttribute:NSAccessibilityValueAttribute withBlock:^id(MMLayerAccessibilityHelper *axHelper) {
		return [ NSNumber numberWithDouble:((double)( weakSelf.selectedIndex ) ) / ( weakSelf.numberOfItems - 1 ) ];
	} ];
	[ knobLayer setValue:knobAXHelper forKey:kMMFLowViewAccessibilityHelperKey ];
	return layer;
}

- (MMVideoOverlayLayer*)createMovieOverlayLayerWithIndex:(NSUInteger)anIndex
{
	MMVideoOverlayLayer *layer = [ MMVideoOverlayLayer layer ];
	// hosting layer
	layer.name = kMMFlowViewOverlayLayerName;
	[ layer setValue:[ NSNumber numberWithUnsignedInteger:anIndex ]
					 forKey:kMMFlowViewItemIndexKey ];
	layer.frame = CGRectMake( 0., 0., kMovieOverlayPlayingRadius * 2, kMovieOverlayPlayingRadius * 2 );
	// initially hidden
	layer.hidden = YES;
	MMLayerAccessibilityHelper *axParent = [ [ self imageLayerAtIndex:anIndex ] valueForKey:kMMFLowViewAccessibilityHelperKey ];
	MMLayerAccessibilityHelper *axHelper = [ MMLayerAccessibilityHelper layerAccesibilityHelperWithRole:NSAccessibilityCheckBoxRole
																								 parent:axParent
																								  layer:layer.buttonLayer
																								   view:self ];
	axHelper.attributeNames = [ NSSet setWithObjects:NSAccessibilityTitleAttribute, NSAccessibilityValueAttribute, nil ];
	axHelper.writableAttributeNames = [ NSSet setWithObjects:NSAccessibilityValueAttribute, nil ];
	[ axHelper addHandlerForAttribute:NSAccessibilityTitleAttribute withBlock:^id(MMLayerAccessibilityHelper *helper ) {
		MMButtonLayer *buttonLayer = (MMButtonLayer*)helper.layer;
		return [ buttonLayer state ] == NSOnState ? NSLocalizedString(@"Stop movie playback", @"Stop movie playback") : NSLocalizedString(@"Start movie playback", @"Start movie playback");
	} ];
	[ axHelper addHandlerForAttribute:NSAccessibilityValueAttribute withBlock:^id(MMLayerAccessibilityHelper *helper) {
		return [ helper.layer valueForKey:kMMButtonLayerStateKey ];
	} ];
	[ axHelper addHandlerForWritableAttribute:NSAccessibilityValueAttribute withBlock:^(MMLayerAccessibilityHelper *helper, id value ) {
		[ helper.layer setValue:value forKey:kMMButtonLayerStateKey ];
	} ];
	[ axParent addChildrenObject:axHelper ];
	[ layer.buttonLayer setValue:axHelper
						  forKey:kMMFLowViewAccessibilityHelperKey ];
	return layer;
}

- (void)setImage:(CGImageRef)anImage atIndex:(NSUInteger)anIndex
{
	if ( anImage ) {
		CAReplicatorLayer *itemLayer = [ self itemLayerAtIndex:anIndex ];
		CALayer *contentLayer = [ itemLayer.sublayers objectAtIndex:kImageLayerIndex ];
		CGFloat aspectRatio = ((CGFloat)CGImageGetWidth(anImage)) / ((CGFloat)CGImageGetHeight(anImage));
		[ contentLayer setValue:[ NSNumber numberWithDouble:aspectRatio ]
						 forKey:kMMFlowViewItemAspectRatioKey ];
		contentLayer.frame = [ self boundsFromContentWithAspectRatio:aspectRatio
														  inItemRect:itemLayer.bounds ];
		if ( ![ contentLayer isKindOfClass:[ QTMovieLayer class ] ] ) {
			contentLayer.contents = (id)anImage;
		}
	}
}

- (void)setFrameForLayer:(CAReplicatorLayer*)itemLayer atIndex:(NSUInteger)anIndex withItemSize:(CGSize)itemSize
{
	NSUInteger selection = self.selectedIndex;
	
	CALayer *imageLayer = [ [ itemLayer sublayers ] objectAtIndex:kImageLayerIndex ];

	CGRect itemFrame = [ self rectForItem:anIndex withItemSize:itemSize ];
	NSUInteger distanceFromSelection = abs( (int)(anIndex - self.selectedIndex) );

	// left stack
	if ( anIndex < selection ) {
		imageLayer.anchorPoint = CGPointMake( 0, 0);
		imageLayer.transform = self.leftTransform;
		imageLayer.zPosition = self.stackedScale;
		itemLayer.zPosition = self.stackedScale - ( distanceFromSelection ) * .5f;
	}
	// right stack
	else if ( anIndex > selection ) {
		imageLayer.anchorPoint = CGPointMake( 1, 0);
		imageLayer.transform = self.rightTransform;
		imageLayer.zPosition = self.stackedScale;
		itemLayer.zPosition = self.stackedScale - ( distanceFromSelection ) * .5f;
	}
	else {	// center
		imageLayer.anchorPoint = CGPointMake( 0.5, 0);
		imageLayer.transform = CATransform3DIdentity;
		imageLayer.zPosition = self.selectedScale;
		itemLayer.zPosition = self.stackedScale;
	}
	CGFloat aspectRatio = [ [ imageLayer valueForKey:kMMFlowViewItemAspectRatioKey ] doubleValue ];
	aspectRatio = ( aspectRatio > 0. ) ? aspectRatio : 1.;
	imageLayer.frame = [ self boundsFromContentWithAspectRatio:aspectRatio
													inItemRect:CGRectMake( 0, 0, itemFrame.size.width, itemFrame.size.height ) ];
	itemLayer.frame = itemFrame;
	itemLayer.instanceTransform = CATransform3DConcat( CATransform3DMakeScale(1, -1, 1), CATransform3DMakeTranslation(0, -itemFrame.size.height, 0) );
}

- (void)highlightLayer:(CALayer*)aLayer highlighted:(BOOL)isHighlighted cornerRadius:(CGFloat)cornerRadius highlightingColor:(CGColorRef)highlightingColor
{
	if ( isHighlighted ) {
		aLayer.cornerRadius = cornerRadius;
		aLayer.borderWidth = kHighlightedBorderWidth;
		aLayer.borderColor = highlightingColor;
	}
	else {
		aLayer.cornerRadius = 0;
		aLayer.borderWidth = 0;
		aLayer.borderColor = nil;
	}
}

#pragma mark -
#pragma mark Layer queue

- (void)enqeueItemLayer:(CALayer*)aLayer
{
	[ self.layerQueue addObject:aLayer ];
}

- (CALayer*)deqeueItemLayer
{
	CALayer *aLayer = [ [ self.layerQueue lastObject ] autorelease ];
	if ( [ self.layerQueue count ] ) {
		[ self.layerQueue removeLastObject ];
	}
	return aLayer;
}

#pragma mark -
#pragma mark CALayerDelegate protocol

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	if ( layer == self.scrollLayer && [ self inLiveResize ] ) {
		// disable implicit animations for scrolllayer in live resize
		return (id<CAAction>)[ NSNull null ];
	}
	return nil;
}

#pragma mark -
#pragma mark CALayoutManager protocol

- (void)layoutSublayersOfLayer:(CALayer *)flowViewLayer
{
	if ( ( flowViewLayer != self.scrollLayer ) ||
		( self.selectedIndex == NSNotFound ) ) {
		return;
	}

	[ CATransaction begin ];
	[ CATransaction setDisableActions:[ self inLiveResize ] ];
	[ CATransaction setAnimationDuration:self.scrollDuration ];
	[ CATransaction setAnimationTimingFunction:[ CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut ] ];
	[ CATransaction setCompletionBlock:^{
		[ self updateImages ];
		[ self setupTrackingAreas ];
	} ];
	// layout
	[ self layoutItemLayersInRange:NSMakeRange( 0, self.numberOfItems ) ];
	[ self.scrollLayer scrollToPoint:[ self selectedScrollPoint ] ];
	[ CATransaction commit ];
	[ self calculateVisibleItems ];
	[ self updateScrollKnob ];
}

- (void)layoutItemLayersInRange:(NSRange)layoutRange
{
	CGSize itemSize = [ self itemSizeForRect:self.scrollLayer.bounds ];

	NSIndexSet *updatedIndexes = [ NSIndexSet indexSetWithIndexesInRange:NSIntersectionRange( layoutRange, NSMakeRange( 0, self.numberOfItems ) ) ];

	[ updatedIndexes enumerateIndexesUsingBlock:^(NSUInteger itemIndex, BOOL *stop) {
		[ self setFrameForLayer:(CAReplicatorLayer*)[ self itemLayerAtIndex:itemIndex ]
						atIndex:itemIndex
				   withItemSize:itemSize ];
	} ];
}

- (void)calculateVisibleItems
{
	NSInteger firstVisibleItem = NSNotFound;
	NSUInteger numberOfVisibleItems = 0;

	// visibility test
	for ( CAReplicatorLayer *itemLayer in self.scrollLayer.sublayers )	{
		NSUInteger itemIndex = [ [ itemLayer valueForKey:kMMFlowViewItemIndexKey ] unsignedIntegerValue ];
		
		if ( !CGRectIsEmpty( itemLayer.visibleRect ) ) {
			if ( firstVisibleItem == NSNotFound ) {
				firstVisibleItem = itemIndex;
			}
			numberOfVisibleItems++;
		}
	}
	self.visibleItemIndexes = ( firstVisibleItem != NSNotFound ) ? [ NSIndexSet indexSetWithIndexesInRange:NSMakeRange( firstVisibleItem, numberOfVisibleItems ) ] : [ NSIndexSet indexSet ];
}

#pragma mark -
#pragma mark Layer updating

- (void)updateImages
{
	[ self.operationQueue cancelAllOperations ];
	NSIndexSet *allIndexes = [ NSIndexSet indexSetWithIndexesInRange:NSMakeRange( 0, self.numberOfItems ) ];
	CGRect visibleFrame = self.scrollLayer.visibleRect;

	[ allIndexes enumerateIndexesUsingBlock:^(NSUInteger anIndex, BOOL *stop) {
		if ( [ self.visibleItemIndexes containsIndex:anIndex ] ||
			( anIndex + 1 ) == [ self.visibleItemIndexes firstIndex ] ||
			( anIndex - 1 ) == [ self.visibleItemIndexes lastIndex ] ) {
			[ self updateImageLayerAtIndex:anIndex ];
		}
		else {
			id item = [ self imageItemForIndex:anIndex ];
			CGImageRef image = [ self lookupForImageUID:[ self imageUIDForItem:item ] ];
			if ( image == NULL ) {
				image = [ self defaultImageForItem:item withSize:[ self itemSizeForRect:visibleFrame ] ];
				if ( image == NULL ) {
					image = [ [ self class ] defaultImage ];
				}
			}
			[ self setImage:image atIndex:anIndex ];
		}
	} ];
}

- (void)updateImageLayerAtIndex:(NSUInteger)anIndex
{
	CGSize imageSize = [ self itemSizeForRect:[ self.scrollLayer frame ] ];
	imageSize = ( anIndex == self.selectedIndex ) ? imageSize : CGSizeApplyAffineTransform(imageSize, CGAffineTransformMakeScale( self.previewScale, self.previewScale ) );
	id item = [ self imageItemForIndex:anIndex ];
	NSString *imageUID = [ self imageUIDForItem:item ];
	id imageRepresentation = [ self imageRepresentationForItem:item ];
	
	CGImageRef itemImage = (CGImageRef)[ self lookupForImageUID:imageUID ];;

	BOOL shouldUpdateCache = YES;
	if ( itemImage != NULL ) {
		CGFloat differenceInPercent = [ self differenceForImage:itemImage
												 forDesiredSize:imageSize ];
		
		if ( differenceInPercent > -kDefaultCachedImageSizeThreshold ) {
			shouldUpdateCache = NO;
		}
	}
	else {
		// image not in cache, try default image
		CGImageRef defaultImage = [ self defaultImageForItem:item
													withSize:imageSize ];
		itemImage = ( defaultImage != NULL ) ? defaultImage : [ [ self class ] defaultImage ];
	}
	[ self setImage:itemImage
			atIndex:anIndex ];
	if ( shouldUpdateCache ) {
		// image not in cache or wrong size -> reload
		NSString *imageRepresentationType = [ self imageRepresentationTypeForItem:item ];
		
		[ self.operationQueue addOperationWithBlock:^{
			CGImageRef newImage = [ [ self class ] newImageFromRepresentation:imageRepresentation
																	 withType:imageRepresentationType
																		 size:imageSize ];
			if (newImage != NULL) {
				[ self cacheImage:newImage
						  withUID:imageUID ];
				CGImageRetain(newImage);
				[ [  NSOperationQueue mainQueue ] addOperationWithBlock:^{
					[ self setImage:newImage
							atIndex:anIndex ];
					CGImageRelease(newImage);
				} ];
				CGImageRelease(newImage);
			}
		} ];
	}
}

- (void)updateMovieLayerAtIndex:(NSUInteger)anIndex
{
	id item = [ self imageItemForIndex:anIndex ];
	CALayer *imageLayer = [ self imageLayerAtIndex:anIndex ];
	QTMovie *movie = [ [ self class ] movieFromRepresentation:[ self imageRepresentationForItem:item ]
													 withType:[ self imageRepresentationTypeForItem:item ] ];
	QTMovieLayer *movieLayer = [ self createMovieLayerWithMovie:movie
														atIndex:anIndex ];
	[ self setAttributesForItemContentLayer:movieLayer atIndex:anIndex ];
	[ movieLayer setValue:[ imageLayer valueForKey:kMMFlowViewItemAspectRatioKey ]
				   forKey:kMMFlowViewItemAspectRatioKey ];
	[ imageLayer addSublayer:movieLayer ];
}

- (void)updateQCCompositionLayerAtIndex:(NSUInteger)anIndex
{
	CALayer *imageLayer = [ self imageLayerAtIndex:anIndex ];

	id item = [ self imageItemForIndex:anIndex ];
	NSString *representationType = [ self imageRepresentationTypeForItem:item ];
	id representation = [ self imageRepresentationForItem:item ];

	[ self.operationQueue addOperationWithBlock:^{
		QCComposition *composition = [ [ self class ] compositionFromRepresentation:representation withType:representationType ];
		if ( composition ) {
			[ [ NSOperationQueue mainQueue ] addOperationWithBlock:^{
				QCCompositionLayer *compositionLayer = [ self createQCCompositionLayerWithQCComposition:composition atIndex:anIndex ];
				
				if ( compositionLayer ) {
					[ self setAttributesForItemContentLayer:compositionLayer
													atIndex:anIndex ];
					[ compositionLayer setValue:[ imageLayer valueForKey:kMMFlowViewItemAspectRatioKey ]
										 forKey:kMMFlowViewItemAspectRatioKey ];
					[ imageLayer addSublayer:compositionLayer ];
				}
			} ];
		}
	} ];
}


- (void)updateSelectionInRange:(NSRange)invalidatedRange
{
	//[ self.scrollLayer setNeedsLayout ];
	[ CATransaction begin ];
	[ CATransaction setDisableActions:[ self inLiveResize ] ];
	[ CATransaction setAnimationDuration:self.scrollDuration ];
	[ CATransaction setAnimationTimingFunction:[ CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut ] ];
	[ CATransaction setCompletionBlock:^{
		[ self updateImages ];
		[ self setupTrackingAreas ];
	} ];
	[ self layoutItemLayersInRange:invalidatedRange ];
	[ self.scrollLayer scrollToPoint:[ self selectedScrollPoint ] ];
	[ CATransaction commit ];
	[ self calculateVisibleItems ];
	[ self updateScrollKnob ];
	self.title = [ self titleAtIndex:self.selectedIndex ];
}

- (void)updateReflection
{
	for ( CAReplicatorLayer *layer in self.scrollLayer.sublayers ) {
		layer.instanceCount = self.showsReflection ? 2 : 1;
		layer.instanceRedOffset = self.reflectionOffset;
		layer.instanceGreenOffset = self.reflectionOffset;
		layer.instanceBlueOffset = self.reflectionOffset;
	}
}

- (void)updateScrollKnob
{
	BOOL shouldHideScrollbar = ( self.numberOfItems < 2 );
	self.scrollBarLayer.hidden = shouldHideScrollbar;
	if ( self.numberOfItems && !shouldHideScrollbar ) {
		CALayer *knob = [ self.scrollBarLayer.sublayers objectAtIndex:0 ];
		CGRect knobBounds = knob.frame;
		NSUInteger numberOfVisibleItems = self.maximumNumberOfStackedVisibleItems;
		CGFloat knobWidthProportion = ((CGFloat)numberOfVisibleItems) / (CGFloat)self.numberOfItems;
		CGFloat knobWidth = MAX( kMinimumKnobWidth, knobWidthProportion * ( self.scrollBarLayer.bounds.size.width - kScrollKnobMargin * 2 ) );
		CGFloat scrollBarSize = self.scrollBarLayer.bounds.size.width - kScrollKnobMargin * 2 - knobWidth;
		CGFloat knobIndexProportion = ( (CGFloat) self.selectedIndex ) / ( self.numberOfItems - 1 );
		knob.frame = CGRectMake( kScrollKnobMargin + knobIndexProportion * scrollBarSize, knobBounds.origin.y, knobWidth , knobBounds.size.height );
		[ knob setNeedsDisplay ];
	}
}

#pragma mark -
#pragma mark Selection

- (void)deselectLayerAtIndex:(NSUInteger)anIndex
{
	if ( anIndex == NSNotFound ) {
		return;
	}
	CALayer *imageLayer = [ self imageLayerAtIndex:anIndex ];
	if ( [ imageLayer.name hasSuffix:kMMFlowViewMovieLayerSuffix ] ) {
		QTMovieLayer *movieLayer = [ self movieLayerAtIndex:anIndex ];
		[ movieLayer.movie stop ];
	}
	[ CATransaction begin ];
	[ CATransaction setDisableActions:YES ];
	imageLayer.sublayers = nil;
	[ CATransaction commit ];
}

- (void)selectLayerAtIndex:(NSUInteger)anIndex
{
	if ( self.draggingKnob ) {
		return;
	}
	CALayer *imageLayer = [ self imageLayerAtIndex:anIndex ];

	if ( [ imageLayer.sublayers count ] == 0 ) {
		// update only if needed
		if ( [ imageLayer.name hasSuffix:kMMFlowViewMovieLayerSuffix ] ) {
			[ self updateMovieLayerAtIndex:anIndex ];
		}
		else if ( [ imageLayer.name hasSuffix:kMMFlowViewQCCompositionLayerSuffix ] ) {
			[ self updateQCCompositionLayerAtIndex:anIndex ];
		}
	}
}

#pragma mark -
#pragma mark Private implementation

- (void)setupTrackingAreas
{
	for ( NSTrackingArea *trackingArea in [ self trackingAreas ] ) {
		[ self removeTrackingArea:trackingArea ];
	}
	if ( self.selectedIndex != NSNotFound ) {
		NSTrackingArea *trackingArea = [ [ [ NSTrackingArea alloc ] initWithRect:[ self rectInViewForLayer:[ self imageLayerAtIndex:self.selectedIndex ] ]
																		 options:NSTrackingActiveInActiveApp | NSTrackingActiveWhenFirstResponder | NSTrackingMouseEnteredAndExited | NSTrackingAssumeInside
																		   owner:self
																		userInfo:nil ] autorelease ];
		[ self addTrackingArea:trackingArea ];
	}
}

#pragma mark -
#pragma mark Overlay code

- (void)mouseEnteredLayerAtIndex:(NSUInteger)anIndex
{
	CALayer *overlayLayer = [ self overlayLayerAtIndex:anIndex ];
	overlayLayer.hidden = NO;
	[ overlayLayer setNeedsDisplay ];
}

- (void)mouseExitedLayerAtIndex:(NSUInteger)anIndex
{
	CALayer *overlayLayer = [ self overlayLayerAtIndex:anIndex ];
	overlayLayer.hidden = YES;
}

#pragma mark -
#pragma mark Image cache

- (void)cacheImage:(CGImageRef)anImage withUID:(NSString*)anUID
{
	[ self.imageCache setObject:(id)anImage forKey:anUID ];
}

- (CGImageRef)lookupForImageUID:(NSString*)anUID
{
	CGImageRef cachedImage = (CGImageRef)[ self.imageCache objectForKey:anUID ];
	return cachedImage;
}

- (CGFloat)differenceForImage:(CGImageRef)anImage forDesiredSize:(CGSize)desiredSize
{
	if ( anImage ) {
		CGFloat imageWidth = CGImageGetWidth( anImage );
		CGFloat difference = imageWidth - desiredSize.width;
		CGFloat differenceInPercent = ( difference / desiredSize.width ) * 100.;
		return differenceInPercent;
	}
	else {
		return FLT_MAX;
	}
}

#pragma mark -
#pragma mark Notifications

- (void)setupNotifications
{
}

- (void)teardownNotifications
{
}

#pragma mark -
#pragma mark NSAccessibility protocol

- (BOOL)accessibilityIsIgnored
{
	return NO;
}

- (NSArray*)accessibilityAttributeNames
{
	static NSArray *attributes = nil;
	if ( attributes == nil ) {
	    attributes = [ [ [ super accessibilityAttributeNames ] arrayByAddingObjectsFromArray:[ NSArray arrayWithObjects:NSAccessibilityContentsAttribute,
																							  nil ] ] retain ];
	}
	return attributes;
}

- (id)accessibilityAttributeValue:(NSString *)anAttribute
{
	if ( [ anAttribute isEqualToString:NSAccessibilityRoleAttribute ] ) {
		return NSAccessibilityScrollAreaRole;
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityRoleDescriptionAttribute ] ) {
		return NSAccessibilityRoleDescriptionForUIElement(self);
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityChildrenAttribute ] ) {
		MMLayerAccessibilityHelper *axListHelper = [ self.backgroundLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];
		MMLayerAccessibilityHelper *axScrollBarHelper = [ self.scrollBarLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];

		return NSAccessibilityUnignoredChildren( [ NSArray arrayWithObjects:axListHelper, axScrollBarHelper, nil ]  );
    }
	else if ( [ anAttribute isEqualToString:NSAccessibilityContentsAttribute ] ) {
		MMLayerAccessibilityHelper *axListHelper = [ self.backgroundLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];
		MMLayerAccessibilityHelper *axScrollBarHelper = [ self.scrollBarLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];
		
		return [ NSArray arrayWithObjects:axListHelper, axScrollBarHelper, nil ];
	}
	else {
		return [ super accessibilityAttributeValue:anAttribute ];
    }
}

- (id)accessibilityHitTest:(NSPoint)aPoint
{
	NSPoint windowPoint = [ [ self window ] convertScreenToBase:aPoint ];
    CGPoint localPoint = NSPointToCGPoint([ self convertPoint:windowPoint
													 fromView:nil ] );
	
	CALayer *hitLayer = [ self hitLayerAtPoint:localPoint ];
	MMLayerAccessibilityHelper *axHelper = [ hitLayer valueForKey:kMMFLowViewAccessibilityHelperKey ];
	return axHelper ? axHelper : self;
}

#pragma mark -
#pragma mark QLPreviewPanelController protocol

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
{
	id item = [ self imageItemForIndex:self.selectedIndex ];
	return [ [ [ self class ] pathRepresentationTypes ] containsObject:[ self imageRepresentationTypeForItem:item ] ];
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
	panel.dataSource = self;
	panel.delegate = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
}

#pragma mark -
#pragma mark QLPreviewPanelDataSource

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
	return 1;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
	id item = [ self imageItemForIndex:self.selectedIndex ];
	if ( [ [ [ self class ] pathRepresentationTypes ] containsObject:[ self imageRepresentationTypeForItem:item ] ] ) {
		id representation = [ self imageRepresentationForItem:item ];
		NSURL *previewURL = [ representation isKindOfClass:[ NSURL class ] ] ? representation : [ NSURL fileURLWithPath:representation ];
		return previewURL;
	}
	return nil;
}

#pragma mark -
#pragma mark QLPreviewPanelDelegate

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
	if ( [event type] == NSKeyDown ) {
		[ self keyDown:event ];
        [ panel reloadData ];
        return YES;
    }
	else {
		return NO;
	}
}

- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item
{
	NSRect selectedItemRectInWindow = [ self convertRect:[ self rectInViewForLayer:[ self imageLayerAtIndex:self.selectedIndex ] ] toView:nil ];
	selectedItemRectInWindow.origin = [ [ self window ] convertBaseToScreen:selectedItemRectInWindow.origin ];
	return selectedItemRectInWindow;
}

#pragma mark -
#pragma mark NSDraggingSource protocol

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return isLocal ? NSDragOperationMove : NSDragOperationCopy;
}

- (void)draggedImage:(NSImage *)anImage beganAt:(NSPoint)aPoint
{
}

- (void)draggedImage:(NSImage *)draggedImage movedTo:(NSPoint)screenPoint
{
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	if ( operation == NSDragOperationDelete && [ self.dataSource respondsToSelector:@selector(flowView:removeItemAtIndex:) ] ) {
		[ self.dataSource flowView:self
				 removeItemAtIndex:self.selectedIndex ];
	}
}

#pragma mark -
#pragma mark NSDraggingDestination protocol 

- (BOOL)wantsPeriodicDraggingUpdates
{
	return NO;
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)dragInfo
{
	return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)dragInfo
{
	NSPoint pointInView = [ self convertPointFromBase:[ dragInfo draggingLocation ] ];
	NSUInteger draggedIndex = [ self indexOfItemAtPoint:pointInView ];

	if ( ( draggedIndex != NSNotFound ) &&
		[ self.dataSource respondsToSelector:@selector(flowView:acceptDrop:atIndex:) ] ) {
		return [ self.dataSource flowView:self
							   acceptDrop:dragInfo
								  atIndex:draggedIndex ];
	}
	return NO;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)dragInfo
{
	self.highlightedLayer = nil;
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)dragInfo
{
	if ( ( [ dragInfo draggingSource ] == self ) ) {
		return NSDragOperationNone;
	}
	self.highlightedLayer = self.backgroundLayer;
	return NSDragOperationNone;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	self.highlightedLayer = nil;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)dragInfo
{
	NSPoint pointInView = [ self convertPointFromBase:[ dragInfo draggingLocation ] ];
	NSUInteger draggedIndex = [ self indexOfItemAtPoint:pointInView ];

	BOOL dragFromSelf = [ dragInfo draggingSource ] == self;
	if ( draggedIndex != NSNotFound ) {
		// no drag from self to selected index
		if ( dragFromSelf && draggedIndex == self.selectedIndex ) {
			return NSDragOperationNone;
		}
		self.highlightedLayer = [ self imageLayerAtIndex:draggedIndex ];
		if ( [ self.dataSource respondsToSelector:@selector(flowView:validateDrop:proposedIndex:) ] ) {
			return [ self.dataSource flowView:self
								 validateDrop:dragInfo
								proposedIndex:draggedIndex ];
		}
	}
	else if ( !dragFromSelf ) {
		self.highlightedLayer = self.backgroundLayer;
	}
	return NSDragOperationNone;
}

#pragma mark -
#pragma mark NSKeyValueBindingCreation overrides

- (NSDictionary *)infoForBinding:(NSString *)binding
{
	NSDictionary *info = [ self.bindingInfo valueForKey:binding ];
	return info ? info : [ super infoForBinding:binding ];
}

- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	if ( [ binding isEqualToString:NSContentArrayBinding ] ) {
		NSAssert( [ observableController isKindOfClass:[ NSArrayController class ] ], @"NSContentArrayBinding needs to be bound to an NSArrayController!" );
		
		// already set?
		if ( [ [ self infoForBinding:binding ] objectForKey:NSObservedKeyPathKey ] != nil ) {
			[ self unbind:NSContentArrayBinding ];
		}
		// Register what object and what keypath are
		// associated with this binding
		NSDictionary *bindingsData = [ NSDictionary dictionaryWithObjectsAndKeys:
									  observableController, NSObservedObjectKey,
									  [ [ keyPath copy ] autorelease ], NSObservedKeyPathKey,
									  [ [ options copy ] autorelease ], NSOptionsKey, nil];
		[ self setInfo:bindingsData
			forBinding:binding ];

		[ observableController addObserver:self
								forKeyPath:keyPath
								   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
								   context:kMMFlowViewContentArrayObservationContext ];
		// set keypaths to MMFlowViewItem defaults
		if ( !self.imageRepresentationKeyPath ) {
			self.imageRepresentationKeyPath = kMMFlowViewItemImageRepresentationKey;
		}
		if ( !self.imageRepresentationTypeKeyPath ) {
			self.imageRepresentationTypeKeyPath = kMMFlowViewItemImageRepresentationTypeKey;
		}
		if ( !self.imageUIDKeyPath ) {
			self.imageUIDKeyPath = kMMFlowViewItemImageUIDKey;
		}
		
	}
	else {
		[ super bind:binding
			toObject:observableController
		 withKeyPath:keyPath
			 options:options ];
	}
}

- (void)unbind:(NSString*)binding
{
	if ( [ binding isEqualToString:NSContentArrayBinding ] && [ self infoForBinding:NSContentArrayBinding ] ) {
		[ self.contentArrayController removeObserver:self forKeyPath:self.contentArrayKeyPath ];
		[ self stopObservingCollection:self.contentArray atKeyPaths:self.observedItemKeyPaths ];
		[ self.layer setNeedsDisplay ];
		[ self.bindingInfo removeObjectForKey:binding ];
	}
	else {
		[ super unbind:binding ];
	}
}

#pragma mark -
#pragma mark NSKeyValueObserving protocol

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)observedObject change:(NSDictionary *)change context:(void *)context
{
	if ( context == kMMFlowViewContentArrayObservationContext ) {
		// Have items been removed from the bound-to container?
		/*
		 Should be able to use
		 NSArray *oldItems = [change objectForKey:NSKeyValueChangeOldKey];
		 etc. but the dictionary doesn't contain old and new arrays.
		 */
		NSArray *newItems = [ observedObject valueForKeyPath:keyPath ];
		
		NSMutableArray *onlyNew = [ NSMutableArray arrayWithArray:newItems ];
		[ onlyNew removeObjectsInArray:self.observedItems ];
		[ self startObservingCollection:onlyNew atKeyPaths:self.observedItemKeyPaths ];
		
		NSMutableArray *removed = [ [ self.observedItems mutableCopy ] autorelease ];
		[ removed removeObjectsInArray:newItems ];
		[ self stopObservingCollection:removed atKeyPaths:self.observedItemKeyPaths ];
		self.observedItems = newItems;

		[ self reloadContent ];
	}
	else if ( context == kMMFlowViewIndividualItemKeyPathsObservationContext ) {
		// tracks individual item-properties and resets observations
		if ( [ keyPath isEqualToString:self.imageUIDKeyPath ] ||
			[ keyPath isEqualToString:self.imageRepresentationKeyPath ] ||
			[ keyPath isEqualToString:self.imageRepresentationTypeKeyPath ] ) {
			[ self.imageCache removeObjectForKey:[ observedObject valueForKeyPath:self.imageUIDKeyPath ] ];
			[ self.scrollLayer setNeedsLayout ];
		}
		else if ( [ keyPath isEqualToString:self.imageTitleKeyPath ] ) {
			self.title = [ observedObject valueForKeyPath:keyPath ];
		}
	}
	else {
		[ super observeValueForKeyPath:keyPath
							  ofObject:observedObject
								change:change
							   context:context ];
	}
}

#pragma mark -
#pragma mark Bindings helper methods

- (void)setInfo:(NSDictionary*)infoDict forBinding:(NSString*)aBinding
{
	NSDictionary *info = [ self.bindingInfo valueForKey:aBinding ];
	if ( info ) {
		[ self.bindingInfo removeObjectForKey:aBinding ];
		[ self unbind:aBinding ];
	}
	[ self.bindingInfo setValue:infoDict forKey:aBinding ];
}

- (void)startObservingCollection:(NSArray*)items atKeyPaths:(NSArray*)keyPaths
{
	if ( [ items isEqual:[ NSNull null ] ] || ![ items count ] ) {
		return;
	}
	NSIndexSet *allItemIndexes = [ NSIndexSet indexSetWithIndexesInRange:NSMakeRange( 0, [ items count ] ) ];
	for ( NSString *keyPath in keyPaths ) {
		[ items addObserver:self
		 toObjectsAtIndexes:allItemIndexes
				 forKeyPath:keyPath
					options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial )
					context:kMMFlowViewIndividualItemKeyPathsObservationContext ];
	}
}

- (void)stopObservingCollection:(NSArray*)items atKeyPaths:(NSArray*)keyPaths
{
	if ( !items || [ items isEqual:[ NSNull null ] ] || ![ items count ] ) {
		return;
	}
	NSIndexSet *allItemIndexes = [ NSIndexSet indexSetWithIndexesInRange:NSMakeRange( 0, [ items count ] ) ];
	for ( NSString *keyPath in keyPaths ) {
		[ items removeObserver:self
		  fromObjectsAtIndexes:allItemIndexes
					forKeyPath:keyPath ];
	}
}

@end


