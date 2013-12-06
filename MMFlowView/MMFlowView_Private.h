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
#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayer.h"
#import "MMScrollBarLayer.h"

@interface MMFlowView () <MMCoverFlowLayerDataSource>

@property (strong) MMCoverFlowLayout *layout;

@property (strong,readwrite) CALayer *backgroundLayer;
@property (strong,readwrite) CATextLayer *titleLayer;
@property (strong, nonatomic) MMCoverFlowLayer *coverFlowLayer;
@property (strong,readwrite) CALayer *containerLayer;
@property (strong,nonatomic) CALayer *selectedLayer;
@property (strong,nonatomic) CALayer *highlightedLayer;
@property (strong,readwrite) MMScrollBarLayer *scrollBarLayer;

@property (assign,nonatomic) BOOL draggingKnob;
@property (assign) CGFloat mouseDownInKnob;

@property (readwrite,nonatomic) NSUInteger numberOfItems;

@property (strong, readwrite) NSIndexSet *visibleItemIndexes;

/* number of potentialy visible items, taking in account selection scrolled to left- and rightmost index */
@property (readonly,nonatomic) NSUInteger maximumNumberOfStackedVisibleItems;

@property (strong) NSOperationQueue *operationQueue;

/* image cache which holds key-value pairs of image-uids (key) and CGImageRefs (value) */
@property (readwrite,strong) NSCache *imageCache;

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

/* returns the layers frane in view-coordinate space */
- (NSRect)rectInViewForLayer:(CALayer*)aLayer;

/* returns the correct items size for a specific rect, respecting layout properties */
- (CGSize)itemSizeForRect:(CGRect)visibleRect;

/* returns a bottom centered rect with a specific aspectratio for a equal-sized itemRect */
- (CGRect)boundsFromContentWithAspectRatio:(CGFloat)aspectRatio inItemRect:(CGRect)itemRect;

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

/* sets the image for an itemlayer */
- (void)setImage:(CGImageRef)anImage atIndex:(NSUInteger)anIndex;

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
