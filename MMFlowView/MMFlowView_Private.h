//
//  MMFlowView_Private.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 07.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <QTKit/QTKit.h>

#import "MMFlowView.h"
#import "MMButtonLayer.h"
#import "MMVideoOverlayLayer.h"

@interface MMFlowView ()

/* layers */
@property (strong,readwrite) CALayer *backgroundLayer;
@property (strong,readwrite) CATextLayer *titleLayer;
@property (strong,readwrite) CAScrollLayer *scrollLayer;
@property (strong,readwrite) CALayer *containerLayer;
@property (strong,nonatomic) CALayer *selectedLayer;
@property (strong,nonatomic) CALayer *highlightedLayer;
@property (strong,readwrite) CALayer *scrollBarLayer;

/* scroll knob */
@property (assign,nonatomic) BOOL draggingKnob;
@property (assign) CGFloat mouseDownInKnob;

/* number of items in view */
@property (assign,nonatomic) NSUInteger numberOfItems;

/* indexes of all visible items */
@property (strong, readwrite) NSIndexSet *visibleItemIndexes;

/* number of potentialy visible items, taking in account selection scrolled to left- and rightmost index */
@property (readonly,nonatomic) NSUInteger maximumNumberOfStackedVisibleItems;

/* operation queue for asynchronous operations such as image and movie loading */
@property (strong) NSOperationQueue *operationQueue;

/* image cache which holds key-value pairs of image-uids (key) and CGImageRefs (value) */
@property (readwrite,strong) NSCache *imageCache;

/* CATransform3D for all items left to the selection */
@property (assign) CATransform3D leftTransform;

/* CATransform3D for all items right to the selection */
@property (assign) CATransform3D rightTransform;

/* perspective transform for all item layers */
@property (assign) CATransform3D perspective;

/* the bound content array if bindings are used */
@property (weak, nonatomic, readonly) NSArray *contentArray;

/* the bound NSArrayController if bindings are used */
@property (weak, nonatomic, readonly) NSArrayController *contentArrayController;

/* the keypath for the content array in the bound array-controller */
@property (weak, nonatomic, readonly) NSString *contentArrayKeyPath;

/* dictionary holding bindings */
@property (strong,nonatomic,readwrite) NSMutableDictionary *bindingInfo;

/* dictionary holding item layer positions (key is the item-image uid, value is a NSNumber containing its index */
@property (strong,readwrite) NSMutableArray *layerQueue;

/* array of all oberved items if bindings are used */
@property (nonatomic,copy) NSArray *observedItems;

/* set of all observed keypaths on the image items, dynamically created */
@property (weak, nonatomic,readonly) NSSet *observedItemKeyPaths;

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
