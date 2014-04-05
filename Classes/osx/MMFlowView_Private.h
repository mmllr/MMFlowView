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
//  MMFlowView_Private.h
//
//  Created by Markus Müller on 07.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <Quartz/Quartz.h>

@protocol MMFlowViewImageCache;

@class MMCoverFlowLayout;
@class MMScrollBarLayer;
@class MMFlowViewImageFactory;
@class MMScrollBarLayer;
@class MMCoverFlowLayer;
@class MMFlowViewContentBinder;
@protocol MMFlowViewContentAdapter;
@class MMFlowView;

@interface MMFlowView ()

@property (strong) MMCoverFlowLayout *coverFlowLayout;
@property (readwrite, copy, nonatomic) NSString *title;
@property (strong,readwrite) CALayer *backgroundLayer;
@property (strong,readwrite) CATextLayer *titleLayer;
@property (strong, nonatomic) MMCoverFlowLayer *coverFlowLayer;
@property (strong,readwrite) CALayer *containerLayer;
@property (strong,nonatomic) CALayer *selectedLayer;
@property (strong,nonatomic) CALayer *highlightedLayer;
@property (strong,readwrite) MMScrollBarLayer *scrollBarLayer;
@property (strong) MMFlowViewImageFactory *imageFactory;
@property (readwrite,nonatomic) NSUInteger numberOfItems;
@property (readwrite,strong) id<MMFlowViewImageCache> imageCache;
@property (nonatomic, readonly) NSRect selectedItemFrame;
@property (nonatomic, strong) id contentAdapter;
@property (nonatomic, strong) MMFlowViewContentBinder *contentBinder;

+ (NSSet*)pathRepresentationTypes;
+ (NSDictionary*)uniformTypesDictionary;
+ (CGImageRef)defaultImage;
+ (NSArray*)backgroundGradientColors;
+ (NSArray*)backgroundGradientLocations;
- (void)mouseEnteredSelection;
- (void)mouseExitedSelection;
- (void)updateTitle;
- (CALayer*)hitLayerAtPoint:(CGPoint)aPoint;
- (NSString*)titleAtIndex:(NSUInteger)anIndex;
- (IBAction)togglePreviewPanel:(id)previewPanel;
- (void)setupTrackingAreas;

@end
