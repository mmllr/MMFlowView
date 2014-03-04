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
#import <Quartz/Quartz.h>
#import <QTKit/QTKit.h>

#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMVideoOverlayLayer.h"
#import "MMButtonLayer.h"
#import "MMFlowView+NSAccessibility.h"
#import "NSColor+MMAdditions.h"
#import "CALayer+NSAccessibility.h"
#import "MMCoverFlowLayoutAttributes.h"
#import "MMScrollBarLayer.h"
#import "MMFlowViewImageCache.h"
#import "MMFlowView+NSKeyValueObserving.h"
#import "MMFlowViewImageFactory.h"
#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayer.h"
#import "NSArray+MMAdditions.h"
#import "MMFlowView+MMScrollBarDelegate.h"
#import "MMMacros.h"

/* representation types */
NSString * const kMMFlowViewURLRepresentationType = @"MMFlowViewURLRepresentationType";
NSString * const kMMFlowViewCGImageRepresentationType = @"MMFlowViewCGImageRepresentationType";
NSString * const kMMFlowViewPDFPageRepresentationType = @"MMFlowViewPDFPageRepresentationType";
NSString * const kMMFlowViewPathRepresentationType = @"MMFlowViewPathRepresentationType";
NSString * const kMMFlowViewNSImageRepresentationType = @"MMFlowViewNSImageRepresentationType";
NSString * const kMMFlowViewCGImageSourceRepresentationType = @"MMFlowViewCGImageSourceRepresentationType";
NSString * const kMMFlowViewNSDataRepresentationType = @"MMFlowViewNSDataRepresentationType";
NSString * const kMMFlowViewNSBitmapRepresentationType = @"MMFlowViewNSBitmapRepresentationType";
NSString * const kMMFlowViewQTMovieRepresentationType = @"MMFlowViewQTMovieRepresentationType";
NSString * const kMMFlowViewQTMoviePathRepresentationType = @"MMFlowViewQTMoviePathRepresentationType";
NSString * const kMMFlowViewQCCompositionRepresentationType = @"MMFlowViewQCCompositionRepresentationType";
NSString * const kMMFlowViewQCCompositionPathRepresentationType = @"MMFlowViewQCCompositionPathRepresentationType";
NSString * const kMMFlowViewQuickLookPathRepresentationType = @"MMFlowViewQuickLookPathRepresentationType";
NSString * const kMMFlowViewIconRefPathRepresentationType = @"MMFlowViewIconRefPathRepresentationType";
NSString * const kMMFlowViewIconRefRepresentationType = @"MMFlowViewIconRefRepresentationType";

/* layer names */
static NSString * const kMMFlowViewScrollLayerName = @"MMFlowViewScrollLayerName";
static NSString * const kMMFlowViewScrollKnobLayerName = @"MMFlowViewScrollKnobLayerName";
static NSString * const kMMFlowViewScrollBarLayerName = @"MMFlowViewScrollBarLayerName";
static NSString * const kMMFlowViewOverlayLayerName = @"MMFlowViewOverlayLayerName";
/* custom layer keys */
static NSString * const kMMFlowViewItemIndexKey = @"index";
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
static const CGFloat kMinimumItemScale = 0.1;
static const CGFloat kMaximumItemScale = 1.;
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
static NSString * const kLayoutKey = @"layout";

@implementation MMFlowView

@dynamic numberOfItems;
@dynamic selectedIndex;
@dynamic showsReflection;
@dynamic reflectionOffset;
@dynamic visibleItemIndexes;
@dynamic selectedItemFrame;

#pragma mark -
#pragma mark Class methods

+ (id)defaultAnimationForKey:(NSString *)key
{
	if ( [ key isEqualToString:kMMFlowViewSpacingKey ] ||
		[ key isEqualToString:kMMFlowViewStackedAngleKey ] ) {
		return [ CABasicAnimation animation ];
	}
	return [ super defaultAnimationForKey:key ];
}

+ (CGImageRef)defaultImage
{
	static CGImageRef image = NULL;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CGRect imageRect = CGRectMake( 0, 0, kDefaultItemSize, kDefaultItemSize );
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		if ( colorSpace ) {
			CGContextRef context = CGBitmapContextCreate( NULL, imageRect.size.width, imageRect.size.height, 8, imageRect.size.width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst );
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
		}
	});
	return image;
}

+ (NSArray*)backgroundGradientColors
{
	return @[(__bridge id)[ [ NSColor colorWithCalibratedRed:52.f / 255.f green:55.f / 255.f blue:69.f / 255.f alpha:1.f ] CGColor ],
					(__bridge id)[ [ NSColor colorWithCalibratedRed:36.f / 255.f green:37.f / 255.f blue:48.f / 255.f alpha:1.f ] CGColor ],
					(__bridge id)[[ NSColor blackColor ] CGColor ]];
}

+ (NSArray*)backgroundGradientLocations
{
	return @[@0.,
			@.2,
			@1.];
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
		utiDictionary = @{(NSString*)kUTTypeImage: kMMFlowViewCGImageRepresentationType,
						 (NSString*)kUTTypeImage: kMMFlowViewNSImageRepresentationType,
						 (NSString*)kUTTypeImage: kMMFlowViewNSBitmapRepresentationType,
						 (NSString*)kUTTypeMovie: kMMFlowViewQTMovieRepresentationType,
						 (NSString*)kUTTypeQuartzComposerComposition: kMMFlowViewQCCompositionRepresentationType,
						 (NSString*)kUTTypeImage: kMMFlowViewIconRefRepresentationType,
						 (NSString*)kUTTypePDF: kMMFlowViewPDFPageRepresentationType};
	});
	return utiDictionary;
}

#pragma mark -
#pragma mark NSControl overrides

+ (void)initialize {
	if ( self == [MMFlowView class] ) {
		[self exposeBinding:NSContentArrayBinding];
		[self exposeBinding:kMMFlowViewImageRepresentationBinding];
		[self exposeBinding:kMMFlowViewImageRepresentationTypeBinding];
		[self exposeBinding:kMMFlowViewImageUIDBinding];
		[self exposeBinding:kMMFlowViewImageTitleBinding];
		[self setCellClass:[NSActionCell class] ];
	}
}

#pragma mark -
#pragma mark Init/Cleanup

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		_imageCache = [[MMFlowViewImageCache alloc] init];
		_imageFactory = [[MMFlowViewImageFactory alloc] init];
		_imageFactory.cache = _imageCache;
		_layout = [[MMCoverFlowLayout alloc] init];
		_imageRepresentationKeyPath = [NSStringFromSelector(@selector(imageItemRepresentation)) copy];
		_imageUIDKeyPath = [NSStringFromSelector(@selector(imageItemUID)) copy];
		_imageRepresentationTypeKeyPath = [NSStringFromSelector(@selector(imageItemRepresentationType)) copy];
		[self setInitialDefaults];
		[self setupLayers];
		self.title = @"";
		[ self setTitleSize:kDefaultTitleSize ];
		[ self registerForDraggedTypes:@[NSURLPboardType] ];
		[self setUpObservations];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [ super initWithCoder:aDecoder ];
	if ( self ) {
		_imageCache = [[MMFlowViewImageCache alloc] init];
		_imageFactory = [[MMFlowViewImageFactory alloc] init];
		_imageFactory.cache = _imageCache;
		[self setAcceptsTouchEvents:YES];
		if ( [ aDecoder allowsKeyedCoding ] ) {
			self.stackedAngle = [ aDecoder decodeDoubleForKey:kMMFlowViewStackedAngleKey ];
			self.spacing = [ aDecoder decodeDoubleForKey:kMMFlowViewSpacingKey ];
			self.stackedScale = [ aDecoder decodeDoubleForKey:kMMFlowViewStackedScaleKey ];
			self.reflectionOffset = [ aDecoder decodeDoubleForKey:kMMFlowViewReflectionOffsetKey ];
			self.showsReflection = [ aDecoder decodeBoolForKey:kMMFlowViewShowsReflectionKey ];
			self.scrollDuration = [ aDecoder decodeDoubleForKey:kMMFlowViewScrollDurationKey ];
			self.itemScale = [ aDecoder decodeDoubleForKey:kMMFlowViewItemScaleKey ];
			self.previewScale = [ aDecoder decodeDoubleForKey:kMMFlowViewPreviewScaleKey ];
			_layout = [aDecoder decodeObjectForKey:kLayoutKey];
		}
		else {
			[self setInitialDefaults];
		}
		[self setupLayers];
		[self setUpObservations];
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
		[ aCoder encodeDouble:self.stackedScale forKey:kMMFlowViewStackedScaleKey ];
		[ aCoder encodeDouble:self.reflectionOffset forKey:kMMFlowViewReflectionOffsetKey ];
		[ aCoder encodeDouble:self.showsReflection forKey:kMMFlowViewShowsReflectionKey ];
		[ aCoder encodeDouble:self.scrollDuration forKey:kMMFlowViewScrollDurationKey ];
		[ aCoder encodeDouble:self.itemScale forKey:kMMFlowViewItemScaleKey ];
		[ aCoder encodeDouble:self.previewScale forKey:kMMFlowViewPreviewScaleKey ];
		[aCoder encodeObject:self.layout forKey:kLayoutKey];
	}
	else {
		[ NSException raise:NSInvalidArchiveOperationException format:@"Only supports NSKeyedArchiver coders" ];
	}
}

- (void)dealloc
{
	[self tearDownObservations];
}

- (void)setInitialDefaults
{
	[self setAcceptsTouchEvents:YES];
	self.stackedAngle = kDefaultStackedAngle;
	self.spacing = kDefaultItemSpacing;
	self.stackedScale = kDefaultStackedScale;
	self.reflectionOffset = kDefaultReflectionOffset;
	self.selectedIndex = NSNotFound;
	self.showsReflection = NO;
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
	self.titleLayer.font = (__bridge CFTypeRef)(aFont);
}

- (CGFloat)titleSize
{
	return self.titleLayer.fontSize;
}

- (void)setTitleSize:(CGFloat)aSize
{
	self.titleLayer.fontSize = aSize;
}

- (void)setTitleColor:(NSColor*)aColor
{
	self.titleLayer.foregroundColor = [ aColor CGColor ];
}

- (void)setSelectedIndex:(NSUInteger)index
{
	if ( ( self.layout.selectedItemIndex != index ) && ( index < self.numberOfItems ) ) {
		self.layout.selectedItemIndex = index;
		[self updateSelectionInRange:NSMakeRange(index, 1)];
		if ( [self.delegate respondsToSelector:@selector(flowViewSelectionDidChange:)] ) {
			[self.delegate flowViewSelectionDidChange:self];
		}
		if ( self.bindingsEnabled ) {
			[self.contentArrayController setSelectionIndex:index];
		}
	}
}

- (NSUInteger)selectedIndex
{
	return self.layout.selectedItemIndex;
}

- (void)setItemScale:(CGFloat)newItemScale
{
	if ( _itemScale != newItemScale ) {
		_itemScale = CLAMP( newItemScale, kMinimumItemScale, kMaximumItemScale );
	}
}

- (void)setPreviewScale:(CGFloat)aPreviewScale
{
	if ( _previewScale != aPreviewScale ) {
		_previewScale = CLAMP( aPreviewScale, 0.01, 1. );
		[self.imageCache reset];
		[self updateImages];
	}
}

- (void)setSelectedLayer:(CALayer *)aLayer
{
	if ( aLayer != _selectedLayer ) {
		// deselect old layer
		[ _selectedLayer setValue:@NO
						  forKey:kMMFlowViewHiglightedLayerKey ];
		_selectedLayer = aLayer;
	}
	[ _selectedLayer setValue:@YES
					  forKey:kMMFlowViewHiglightedLayerKey ];
}

- (void)setNumberOfItems:(NSUInteger)numberOfItems
{
	self.layout.numberOfItems = numberOfItems;
}

- (NSUInteger)numberOfItems
{
	return self.layout.numberOfItems;
}

- (BOOL)showsReflection
{
	return self.coverFlowLayer.showsReflection;
}

- (void)setShowsReflection:(BOOL)showsReflection
{
	self.coverFlowLayer.showsReflection= showsReflection;
}

- (CGFloat)reflectionOffset
{
	return self.coverFlowLayer.reflectionOffset;
}

- (void)setReflectionOffset:(CGFloat)reflectionOffset
{
	self.coverFlowLayer.reflectionOffset = reflectionOffset;
}

- (NSIndexSet*)visibleItemIndexes
{
	return self.coverFlowLayer.visibleItemIndexes;
}

- (NSRect)selectedItemFrame
{
	CGRect selectedFrameInCoverFlowLayer = self.coverFlowLayer.selectedItemFrame;

	if (CGRectIsEmpty(selectedFrameInCoverFlowLayer)) {
		return NSZeroRect;
	}
	NSRect rectInHostingLayer = NSRectFromCGRect([self.layer convertRect:selectedFrameInCoverFlowLayer fromLayer:self.coverFlowLayer]);
	return [self convertRectFromBacking:[self convertRectFromLayer:rectInHostingLayer]];
}

#pragma mark - MMCoverFlowLayerDataSource

- (CALayer*)coverFlowLayer:(MMCoverFlowLayer *)layer contentLayerForIndex:(NSUInteger)index
{
	CALayer *contentLayer = [CALayer layer];
	contentLayer.contents = (id)[[self class] defaultImage];
	contentLayer.contentsGravity = kCAGravityResizeAspectFill;
	return contentLayer;
}

- (void)coverFlowLayerWillRelayout:(MMCoverFlowLayer *)coverFlowLayer
{
}

- (void)coverFlowLayerDidRelayout:(MMCoverFlowLayer *)coverFlowLayer
{
	self.imageFactory.maxImageSize = self.layout.itemSize;
	[self updateImages];
}

#pragma mark - other helpers

- (BOOL)isMovieAtIndex:(NSUInteger)anIndex
{
	return UTTypeConformsTo( (__bridge CFStringRef)[ self uniformTypeIdentifierAtIndex:anIndex ], kUTTypeMovie );
}

- (BOOL)isQCCompositionAtIndex:(NSUInteger)anIndex
{
	return UTTypeConformsTo( (__bridge CFStringRef)[ self uniformTypeIdentifierAtIndex:anIndex ], (__bridge CFStringRef)kUTTypeQuartzComposerComposition );
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
		uti = [ [ self class ] uniformTypesDictionary ][imageRepresentationType];
	}
	return uti;
}

- (CALayer*)hitLayerAtPoint:(CGPoint)aPointInView
{
	CALayer *hitLayer = [self.layer hitTest:aPointInView];
	return [hitLayer modelLayer];
}

- (NSUInteger)indexOfItemAtPoint:(NSPoint)aPoint
{
	CGPoint pointInContainerLayer = [[self layer] convertPoint:[self convertPointToLayer:aPoint]
													   toLayer:self.containerLayer];
	return [self.coverFlowLayer indexOfLayerAtPointInSuperLayer:pointInContainerLayer];
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
		[self.observedItems mm_removeObserver:self forKeyPaths:self.observedItemKeyPaths context:kMMFlowViewIndividualItemKeyPathsObservationContext];
		[self unbind:NSContentArrayBinding];
	}
	[ super viewWillMoveToSuperview:newSuperview ];
}

- (void)viewWillStartLiveResize
{
	[super viewWillStartLiveResize];
	self.coverFlowLayer.inLiveResize = YES;
}

- (void)viewDidEndLiveResize
{
	[super viewDidEndLiveResize];
	self.coverFlowLayer.inLiveResize = NO;
	//[ self.scrollLayer setNeedsLayout ];
	//[self updateImages];
}

- (void)updateTrackingAreas
{
	[ super updateTrackingAreas ];
	[ self setupTrackingAreas ];
}

#pragma mark -
#pragma mark NSResponder overrides



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
		self.numberOfItems = [self.dataSource numberOfItemsInFlowView:self];
	}
	else {
		self.numberOfItems = 0;
	}
	[ CATransaction begin ];
	[ CATransaction setDisableActions:YES ];
	[ CATransaction commit ];
	if ( self.selectedIndex > self.numberOfItems ) {
		self.selectedIndex = 0;
	};
	[ self updateSelectionInRange:NSMakeRange( 0, self.numberOfItems ) ];
}

- (id)imageItemForIndex:(NSUInteger)anIndex
{
	if ( anIndex == NSNotFound ) {
		return nil;
	}
	if ( self.bindingsEnabled &&
		( anIndex < [ self.contentArray count ] ) ) {
		return (self.contentArray)[anIndex];
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
	return [ anItem respondsToSelector:@selector(imageItemUID) ] ? [ anItem imageItemUID ] : nil;
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
	return [ anItem respondsToSelector:@selector(imageItemTitle) ] ? [ anItem imageItemTitle ] : [ NSString stringWithFormat:NSLocalizedString(@"Untitled item", @"Default item title" ) ];
}

- (id)imageRepresentationForItem:(id)anItem
{
	if ( self.bindingsEnabled && self.imageRepresentationKeyPath ) {
		return [ anItem valueForKeyPath:self.imageRepresentationKeyPath ];
	}
	return [ anItem respondsToSelector:@selector(imageItemRepresentation) ] ? [ anItem imageItemRepresentation ] : nil;
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
	self.backgroundLayer = [self createBackgroundLayer];
	self.titleLayer = [ self createTitleLayer ];
	self.containerLayer = [self createContainerLayer];
	[self.backgroundLayer addSublayer:self.containerLayer];
	[self.backgroundLayer insertSublayer:self.titleLayer above:self.containerLayer];
	self.coverFlowLayer = [MMCoverFlowLayer layerWithLayout:self.layout];
	self.coverFlowLayer.dataSource = self;
	self.scrollBarLayer = [self createScrollBarLayer];
	
	[self.containerLayer addSublayer:self.coverFlowLayer];
	[self.backgroundLayer insertSublayer:self.scrollBarLayer above:self.containerLayer ];
	[self setAccessiblityEnabledLayer:self.backgroundLayer];
	[self.coverFlowLayer setNeedsLayout];
	[self.layer setNeedsDisplay];
}

- (CALayer*)createBackgroundLayer
{
	CAGradientLayer *layer = [ CAGradientLayer layer ];
	layer.position = CGPointMake( 0, 0 );
	layer.bounds = CGRectMake( 0, 0, NSWidth([self bounds]), NSHeight([self bounds]) );

	layer.colors = [[ self class ] backgroundGradientColors ];
	layer.locations = [ [ self class ] backgroundGradientLocations ];
	layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	layer.layoutManager = [ CAConstraintLayoutManager layoutManager ];
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
	customActions[kPositionKey] = [NSNull null];
	customActions[kBoundsKey] = [NSNull null];
	customActions[kStringKey] = [NSNull null];
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
	customActions[kPositionKey] = [NSNull null];
	customActions[kBoundsKey] = [NSNull null];
	// set theLayer actions to the updated dictionary
	layer.actions = customActions;
	return layer;
}

- (MMScrollBarLayer*)createScrollBarLayer
{
	MMScrollBarLayer *layer = [[MMScrollBarLayer alloc] initWithScrollLayer:self.coverFlowLayer];
	__weak MMFlowView *weakSelf = self;
	[layer setWritableAccessibilityAttribute:NSAccessibilityValueAttribute
								   readBlock:^id{
									   MMFlowView *strongSelf = weakSelf;
									   return @(((double)(strongSelf.selectedIndex)) / (strongSelf.numberOfItems - 1));
								   }
								  writeBlock:^(id value) {
									  MMFlowView *strongSelf = weakSelf;
									  NSInteger index = [value doubleValue] * (MAX( 0, strongSelf.numberOfItems - 1));
									  strongSelf.selectedIndex = index;
								  }];

	CALayer *knobLayer = [layer.sublayers firstObject];
	[knobLayer setReadableAccessibilityAttribute:NSAccessibilityValueAttribute withBlock:^id{
		MMFlowView *strongSelf = weakSelf;
		return @(((double)(strongSelf.selectedIndex)) / (strongSelf.numberOfItems - 1));
	}];
	layer.scrollBarDelegate = self;
	return layer;
}

- (MMVideoOverlayLayer*)createMovieOverlayLayerWithIndex:(NSUInteger)anIndex
{
	MMVideoOverlayLayer *layer = [ MMVideoOverlayLayer layer ];
	// hosting layer
	layer.name = kMMFlowViewOverlayLayerName;
	[ layer setValue:@(anIndex)
					 forKey:kMMFlowViewItemIndexKey ];
	layer.frame = CGRectMake( 0., 0., kMovieOverlayPlayingRadius * 2, kMovieOverlayPlayingRadius * 2 );
	// initially hidden
	layer.hidden = YES;

	MMButtonLayer *buttonLayer = layer.buttonLayer;
	__weak MMButtonLayer *weakLayer = buttonLayer;
	[buttonLayer setReadableAccessibilityAttribute:NSAccessibilityRoleAttribute withBlock:^id{
		return NSAccessibilityCheckBoxRole;
	}];
	[buttonLayer setReadableAccessibilityAttribute:NSAccessibilityTitleAttribute withBlock:^id{
		return [ weakLayer state ] == NSOnState ? NSLocalizedString(@"Stop movie playback", @"Stop movie playback") : NSLocalizedString(@"Start movie playback", @"Start movie playback");
	}];
	[buttonLayer setWritableAccessibilityAttribute:NSAccessibilityValueAttribute readBlock:^id{
		return [ weakLayer valueForKey:kMMButtonLayerStateKey ];
	} writeBlock:^(id value) {
		[ weakLayer setValue:value forKey:kMMButtonLayerStateKey ];
	}];
	return layer;
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
#pragma mark Layer updating

- (void)updateImages
{
	[self.coverFlowLayer.contentLayers enumerateObjectsAtIndexes:self.visibleItemIndexes options:0 usingBlock:^(CALayer *contentLayer, NSUInteger idx, BOOL *stop) {
		[self.imageFactory createCGImageForItem:[self imageItemForIndex:idx]
							  completionHandler:^(CGImageRef image) {
			contentLayer.contents = (__bridge id)(image);
		}];
	}];
}

- (void)updateSelectionInRange:(NSRange)invalidatedRange
{
	self.title = [ self titleAtIndex:self.selectedIndex ];
	// ax
	NSAccessibilityPostNotification(self, NSAccessibilityValueChangedNotification);
}

#pragma mark -
#pragma mark Private implementation

- (void)setupTrackingAreas
{
	for ( NSTrackingArea *trackingArea in [self trackingAreas] ) {
		[self removeTrackingArea:trackingArea];
	}
	if ( self.selectedIndex != NSNotFound ) {
		NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.selectedItemFrame
																		 options:NSTrackingActiveInActiveApp | NSTrackingActiveWhenFirstResponder | NSTrackingMouseEnteredAndExited | NSTrackingAssumeInside
																		   owner:self
																		userInfo:nil];
		[self addTrackingArea:trackingArea];
	}
}

#pragma mark -
#pragma mark Overlay code

- (void)mouseEnteredSelection
{
}

- (void)mouseExitedSelection
{
}

#pragma mark -
#pragma mark Notifications

- (void)setupNotifications
{
}

- (void)teardownNotifications
{
}

@end
