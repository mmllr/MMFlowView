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
#import "MMFlowViewImageFactory.h"

@protocol MMFlowViewImageCache;

@interface MMFlowView () <MMCoverFlowLayerDataSource>

@property (strong) MMCoverFlowLayout *layout;

@property (strong,readwrite) CALayer *backgroundLayer;
@property (strong,readwrite) CATextLayer *titleLayer;
@property (strong, nonatomic) MMCoverFlowLayer *coverFlowLayer;
@property (strong,readwrite) CALayer *containerLayer;
@property (strong,nonatomic) CALayer *selectedLayer;
@property (strong,nonatomic) CALayer *highlightedLayer;
@property (strong,readwrite) MMScrollBarLayer *scrollBarLayer;
@property (strong) MMFlowViewImageFactory *imageFactory;

@property (assign,nonatomic) BOOL draggingKnob;
@property (assign) CGFloat mouseDownInKnob;
@property (readwrite,nonatomic) NSUInteger numberOfItems;
@property (readonly,nonatomic) NSUInteger maximumNumberOfStackedVisibleItems;
@property (readwrite,strong) id<MMFlowViewImageCache> imageCache;
@property (weak, nonatomic, readonly) NSArray *contentArray;
@property (weak, nonatomic, readonly) NSArrayController *contentArrayController;
@property (weak, nonatomic, readonly) NSString *contentArrayKeyPath;
@property (strong,nonatomic,readwrite) NSMutableDictionary *bindingInfo;
@property (strong,readwrite) NSMutableArray *layerQueue;
@property (nonatomic,copy) NSArray *observedItems;
@property (weak, nonatomic,readonly) NSSet *observedItemKeyPaths;
@property (nonatomic,readonly) BOOL bindingsEnabled;

+ (NSSet*)pathRepresentationTypes;
+ (NSDictionary*)uniformTypesDictionary;
+ (CGImageRef)defaultImage;
+ (NSArray*)backgroundGradientColors;
+ (NSArray*)backgroundGradientLocations;
- (void)mouseEnteredLayerAtIndex:(NSUInteger)anIndex;
- (void)mouseExitedLayerAtIndex:(NSUInteger)anIndex;
- (void)updateSelectionInRange:(NSRange)invalidatedRange;
- (CALayer*)hitLayerAtPoint:(CGPoint)aPoint;
- (id)imageItemForIndex:(NSUInteger)anIndex;
- (NSString*)imageUIDForItem:(id)anItem;
- (NSString*)imageRepresentationTypeForItem:(id)anItem;
- (NSString*)imageTitleForItem:(id)anItem;
- (id)imageRepresentationForItem:(id)anItem;
- (NSString*)titleAtIndex:(NSUInteger)anIndex;
- (CGImageRef)defaultImageForItem:(id)anItem withSize:(CGSize)imageSize;
- (BOOL)isMovieAtIndex:(NSUInteger)anIndex;
- (NSString*)uniformTypeIdentifierAtIndex:(NSUInteger)anIndex;
- (void)highlightLayer:(CALayer*)aLayer highlighted:(BOOL)isHighlighted cornerRadius:(CGFloat)cornerRadius highlightingColor:(CGColorRef)highlightingColor;
- (void)startObservingCollection:(NSArray*)aCollection atKeyPaths:(NSSet*)keyPaths;
- (void)stopObservingCollection:(NSArray*)aCollection atKeyPaths:(NSSet*)keyPaths;

@end
