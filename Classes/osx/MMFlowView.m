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
//  MMFlowView.m
//
//  Created by Markus Müller on 13.01.12.

#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+NSAccessibility.h"
#import "CALayer+NSAccessibility.h"
#import "MMScrollBarLayer.h"
#import "MMFlowViewImageCache.h"
#import "MMFlowView+NSKeyValueObserving.h"
#import "MMFlowViewImageFactory.h"
#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayer.h"
#import "NSArray+MMAdditions.h"
#import "MMFlowView+MMScrollBarDelegate.h"
#import "MMFlowView+MMCoverFlowLayerDataSource.h"
#import "CALayer+MMAdditions.h"
#import "MMCGImageSourceDecoder.h"
#import "MMQuickLookImageDecoder.h"
#import "MMPDFPageDecoder.h"
#import "MMNSBitmapImageRepDecoder.h"
#import "MMNSDataImageDecoder.h"
#import "MMNSImageDecoder.h"
#import "MMFlowView+MMCoverFlowLayoutDelegate.h"
#import "MMFlowViewDatasourceContentAdapter.h"
#import "MMFlowViewContentBinder.h"
#import "MMFlowView+MMFlowViewContentBinderDelegate.h"

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

NSString * const kMMFlowViewSelectionDidChangeNotification = @"MMFlowViewSelectionDidChangeNotification";
NSString * const kMMFlowViewSelectedIndexKey = @"selectedIndex";

static const CGFloat kTitleOffset = 50.;
static const CGFloat kDefaultTitleSize = 18.;
static const CGFloat kDefaultItemSize = 100.;
static const CGFloat kDefaultStackedAngle = 70.;
static const CGFloat kDefaultItemSpacing = 50.;
static const CGFloat kDefaultReflectionOffset = -0.4;

static NSString * const kMMFlowViewTitleLayerName = @"MMFlowViewTitleLayer";
static NSString * const kMMFlowViewContainerLayerName = @"MMFlowViewContainerLayer";
static NSString * const kUTTypeQuartzComposerComposition = @"com.apple.quartz-composer-composition";
static NSString * const kMMFlowViewSpacingKey = @"spacing";
static NSString * const kMMFlowViewStackedAngleKey = @"stackedAngle";
static NSString * const kMMFlowViewSelectedScaleKey = @"selectedScale";
static NSString * const kMMFlowViewReflectionOffsetKey = @"reflectionOffset";
static NSString * const kMMFlowViewShowsReflectionKey = @"showsReflection";
static NSString * const kSuperlayerKey = @"superlayer";
static NSString * const kPositionKey = @"position";
static NSString * const kBoundsKey = @"bounds";
static NSString * const kStringKey = @"string";
static NSString * const kLayoutKey = @"layout";


@implementation MMFlowView

@dynamic title;
@dynamic numberOfItems;
@dynamic selectedIndex;
@dynamic showsReflection;
@dynamic reflectionOffset;
@dynamic visibleItemIndexes;
@dynamic selectedItemFrame;

#pragma mark - Class methods

+ (id)defaultAnimationForKey:(NSString *)key
{
	if ([key isEqualToString:NSStringFromSelector(@selector(spacing))] || [key isEqualToString:NSStringFromSelector(@selector(stackedAngle))] ) {
		return [CABasicAnimation animation];
	}
	return [super defaultAnimationForKey:key];
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
								   kMMFlowViewQuickLookPathRepresentationType, nil ];
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
						 (NSString*)kUTTypePDF: kMMFlowViewPDFPageRepresentationType};
	});
	return utiDictionary;
}

#pragma mark -
#pragma mark NSControl overrides

+ (void)initialize {
	if ( self == [MMFlowView class] ) {
		[self exposeBinding:NSContentArrayBinding];
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
		_coverFlowLayout = [[MMCoverFlowLayout alloc] init];
		_coverFlowLayout.delegate = self;
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
		[self setAcceptsTouchEvents:YES];
		if ( [ aDecoder allowsKeyedCoding ] ) {
			self.stackedAngle = [ aDecoder decodeDoubleForKey:kMMFlowViewStackedAngleKey ];
			self.spacing = [ aDecoder decodeDoubleForKey:kMMFlowViewSpacingKey ];
			self.reflectionOffset = [ aDecoder decodeDoubleForKey:kMMFlowViewReflectionOffsetKey ];
			self.showsReflection = [ aDecoder decodeBoolForKey:kMMFlowViewShowsReflectionKey ];
			_coverFlowLayout = [aDecoder decodeObjectForKey:kLayoutKey];
			_coverFlowLayout.delegate = self;
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
	[super encodeWithCoder:aCoder];
	if ([aCoder allowsKeyedCoding]) {
		[aCoder encodeDouble:self.stackedAngle forKey:kMMFlowViewStackedAngleKey];
		[aCoder encodeDouble:self.spacing forKey:kMMFlowViewSpacingKey];
		[aCoder encodeDouble:self.reflectionOffset forKey:kMMFlowViewReflectionOffsetKey];
		[aCoder encodeDouble:self.showsReflection forKey:kMMFlowViewShowsReflectionKey];
		[aCoder encodeObject:self.coverFlowLayout forKey:kLayoutKey];
	}
	else {
		[NSException raise:NSInvalidArchiveOperationException format:@"Only supports NSKeyedArchiver coders"];
	}
}

- (void)dealloc
{
	[self tearDownObservations];
}

- (void)setInitialDefaults
{
	[self setAcceptsTouchEvents:YES];
	[self setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self initImageFactory];
	self.stackedAngle = kDefaultStackedAngle;
	self.spacing = kDefaultItemSpacing;
	self.reflectionOffset = kDefaultReflectionOffset;
	self.selectedIndex = NSNotFound;
	self.showsReflection = NO;
}

- (void)initImageFactory
{
	NSDictionary *representationMappings = @{
											 kMMFlowViewURLRepresentationType: [MMQuickLookImageDecoder class],
											 kMMFlowViewPDFPageRepresentationType: [MMPDFPageDecoder class],
											 kMMFlowViewPathRepresentationType: [MMQuickLookImageDecoder class],
											 kMMFlowViewNSImageRepresentationType: [MMNSImageDecoder class],
											 kMMFlowViewCGImageSourceRepresentationType: [MMCGImageSourceDecoder class],
											 kMMFlowViewNSDataRepresentationType: [MMNSDataImageDecoder class],
											 kMMFlowViewNSBitmapRepresentationType: [MMNSBitmapImageRepDecoder class],
											 kMMFlowViewQTMoviePathRepresentationType: [MMQuickLookImageDecoder class],
											 kMMFlowViewQCCompositionPathRepresentationType: [MMQuickLookImageDecoder class],
											 kMMFlowViewQuickLookPathRepresentationType: [MMQuickLookImageDecoder class]
											 };

	[representationMappings enumerateKeysAndObjectsUsingBlock:^(NSString *representationType, Class aClass, BOOL *stop) {
		[self.imageFactory registerClass:aClass
			   forItemRepresentationType:representationType];
	}];
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
	self.titleLayer.font = (__bridge CFTypeRef)aFont;
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
	self.titleLayer.foregroundColor = [aColor CGColor];
}

- (void)setSelectedIndex:(NSUInteger)index
{
	if ( ( self.coverFlowLayout.selectedItemIndex != index ) && ( index < self.numberOfItems ) ) {
		self.coverFlowLayout.selectedItemIndex = index;
		[self updateTitle];
		if ( [self.delegate respondsToSelector:@selector(flowViewSelectionDidChange:)] ) {
			[self.delegate flowViewSelectionDidChange:self];
		}
		id boundContentObserver = [self infoForBinding:NSContentArrayBinding][NSObservedObjectKey];
		if ([boundContentObserver respondsToSelector:@selector(setSelectionIndex:)]) {
			[boundContentObserver setSelectionIndex:index];
		}
	}
}

- (NSUInteger)selectedIndex
{
	return self.coverFlowLayout.selectedItemIndex;
}

- (void)setNumberOfItems:(NSUInteger)numberOfItems
{
	self.coverFlowLayout.numberOfItems = numberOfItems;
}

- (NSUInteger)numberOfItems
{
	return self.coverFlowLayout.numberOfItems;
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
	CGRect selectedRectInLayerSpace = [self.layer convertRect:selectedFrameInCoverFlowLayer fromLayer:self.coverFlowLayer];

	return NSRectFromCGRect([self convertRectFromLayer:selectedRectInLayerSpace]);
}

-(void)setDataSource:(id<MMFlowViewDataSource>)dataSource
{
	_dataSource = dataSource;
	if (![self infoForBinding:NSContentArrayBinding]) {
		self.contentAdapter = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:self];
	}
}


- (void)setContentBinder:(MMFlowViewContentBinder *)contentBinder
{
	if (contentBinder != _contentBinder) {
		[_contentBinder stopObservingContent];
		_contentBinder = contentBinder;
		_contentBinder.delegate = self;
		//[_contentBinder startObservingContent];
	}
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
	id<MMFlowViewItem> item = self.contentAdapter[anIndex];
	NSString *imageRepresentationType = item.imageItemRepresentationType;
	id imageRepresentation = item.imageItemRepresentation;
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
	return [self.coverFlowLayer indexOfLayerAtPoint:pointInContainerLayer];
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

- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
	BOOL willBeInSuperview = newSuperview != nil;
	BOOL inView = [self superview] != nil;

	if (inView && !willBeInSuperview) {
		[self unbind:NSContentArrayBinding];
	}
	[super viewWillMoveToSuperview:newSuperview];
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
	self.imageFactory.maxImageSize = self.coverFlowLayout.itemSize;
}

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	[self setupTrackingAreas];
}

- (NSSize)intrinsicContentSize
{
	return NSMakeSize(NSViewNoInstrinsicMetric, NSViewNoInstrinsicMetric);
}

#pragma mark -
#pragma mark IBActions

- (IBAction)togglePreviewPanel:(id)sender
{
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:self];
    } else {
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:self];
    }
}

#pragma mark -
#pragma mark Data source related methods

- (void)reloadContent
{
	self.numberOfItems = [self.contentAdapter count];
	if (self.numberOfItems) {
		self.selectedIndex = 0;
	};
	[self updateTitle
	 ];
	[self setupTrackingAreas];
}

- (id)imageItemForIndex:(NSUInteger)anIndex
{
	if (anIndex == NSNotFound) {
		return nil;
	}
	if (self.bindingsEnabled &&
		(anIndex < [self.contentArray count])) {
		return (self.contentArray)[anIndex];
	}
	return [self.dataSource respondsToSelector:@selector(flowView:itemAtIndex:)] ? [self.dataSource flowView:self itemAtIndex:anIndex] : nil;
}

- (NSString*)titleAtIndex:(NSUInteger)anIndex
{
	id<MMFlowViewItem> item = self.contentAdapter[anIndex];

	if ([item respondsToSelector:@selector(imageItemTitle)]) {
		return item.imageItemTitle;
	}
	return @"";
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
	self.coverFlowLayer = [MMCoverFlowLayer layerWithLayout:self.coverFlowLayout];
	self.coverFlowLayer.dataSource = self;
	self.scrollBarLayer = [[MMScrollBarLayer alloc] init];
	self.scrollBarLayer.scrollBarDelegate = self;
	
	[self.containerLayer addSublayer:self.coverFlowLayer];
	[self.backgroundLayer insertSublayer:self.scrollBarLayer above:self.containerLayer ];
	[self setAccessiblityEnabledLayer:self.backgroundLayer];
	[self.coverFlowLayer setNeedsLayout];
	[self.layer setNeedsDisplay];
}

- (CALayer*)createBackgroundLayer
{
	CAGradientLayer *layer = [CAGradientLayer layer];
	layer.position = CGPointMake( 0, 0 );
	layer.bounds = CGRectMake( 0, 0, NSWidth([self bounds]), NSHeight([self bounds]));

	layer.colors = [[ self class ] backgroundGradientColors ];
	layer.locations = [ [ self class ] backgroundGradientLocations ];
	layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	layer.layoutManager = [ CAConstraintLayoutManager layoutManager ];
	return layer;
}

- (CATextLayer*)createTitleLayer
{
	CATextLayer *layer = [CATextLayer layer];
	layer.name = kMMFlowViewTitleLayerName;
	layer.alignmentMode = kCAAlignmentCenter;
	layer.fontSize = kDefaultTitleSize;
	[layer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY
													relativeTo:kSuperlayerKey
													 attribute:kCAConstraintMinY
														offset:kTitleOffset]];
	[layer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX
													relativeTo:kSuperlayerKey
													 attribute:kCAConstraintMidX]];
	[layer mm_disableImplicitAnimationForKey:kStringKey];
	[layer mm_disableImplicitAnimationForKey:kPositionKey];
	[layer mm_disableImplicitAnimationForKey:kBoundsKey];
	return layer;
}

- (CALayer*)createContainerLayer
{
	CALayer *layer = [CALayer layer];
	layer.name = kMMFlowViewContainerLayerName;
	[layer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX
													relativeTo:kSuperlayerKey
													 attribute:kCAConstraintMidX]];
	[layer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY
													relativeTo:kSuperlayerKey
													 attribute:kCAConstraintMaxY]];
	[layer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth
													relativeTo:kSuperlayerKey
													 attribute:kCAConstraintWidth]];
	[layer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY
													relativeTo:kMMFlowViewTitleLayerName
													 attribute:kCAConstraintMaxY]];
	[layer mm_disableImplicitAnimationForKey:kPositionKey];
	[layer mm_disableImplicitAnimationForKey:kBoundsKey];
	return layer;
}

#pragma mark - selection

- (void)updateTitle
{
	if (self.selectedIndex == NSNotFound) {
		self.title = @"";
		return;
	}
	self.title = [self titleAtIndex:self.selectedIndex];
	NSAccessibilityPostNotification(self, NSAccessibilityValueChangedNotification);
}

#pragma mark -
#pragma mark Private implementation

- (void)setupTrackingAreas
{
	for (NSTrackingArea *trackingArea in [self trackingAreas]) {
		[self removeTrackingArea:trackingArea];
	}
	if (self.selectedIndex != NSNotFound) {
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


@end
