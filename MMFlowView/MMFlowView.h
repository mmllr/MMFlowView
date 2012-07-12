/*
 Copyright (c) 2012, Markus Müller, www.isnotnil.com
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  MMFlowView.h
//  FlowView
//
//  Created by Markus Müller on 13.01.12.

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

@class MMFlowView;

/* kMMFlowViewURLRepresentationType, image representation is a NSURL */
extern NSString * const kMMFlowViewURLRepresentationType;
/* kMMFlowViewCGImageRepresentationType, image representation is a CGImageRef */
extern NSString * const kMMFlowViewCGImageRepresentationType;
/* kMMFlowViewPDFPageRepresentationType, image representation is a PDFPage or a CGPDFPageRef */
extern NSString * const kMMFlowViewPDFPageRepresentationType;
/* kMMFlowViewPathRepresentationType, image representation is a NSString holding a path */
extern NSString * const kMMFlowViewPathRepresentationType;
/* kMMFlowViewNSImageRepresentationType, image representation is a NSImage */
extern NSString * const kMMFlowViewNSImageRepresentationType;
/* kMMFlowViewCGImageSourceRepresentationType, image representation is a CGImageSourceRef */
extern NSString * const kMMFlowViewCGImageSourceRepresentationType;
/* kMMFlowViewNSDataRepresentationType, image representation is a NSData or CFDataRef containin an image-io readably format */
extern NSString * const kMMFlowViewNSDataRepresentationType;
/* kMMFlowViewNSBitmapRepresentationType, image representation is a NSBitmapImageRep */
extern NSString * const kMMFlowViewNSBitmapRepresentationType;
/* kMMFlowViewQTMovieRepresentationType, image representation is a QTMovie */
extern NSString * const kMMFlowViewQTMovieRepresentationType;
/* kMMFlowViewQTMoviePathRepresentationType, image representation is a NSURL or a NSString holding a filepath to a QTMovie */
extern NSString * const kMMFlowViewQTMoviePathRepresentationType;
/* kMMFlowViewQCCompositionRepresentationType, image representation is a QCComposition */
extern NSString * const kMMFlowViewQCCompositionRepresentationType;
/* kMMFlowViewQCCompositionPathRepresentationType, image representation is a NSURL or a NSString holding a filepath to a QCComposition */
extern NSString * const kMMFlowViewQCCompositionPathRepresentationType;
/* kMMFlowViewQuickLookPathRepresentationType, image representation is a NSURL */
extern NSString * const kMMFlowViewQuickLookPathRepresentationType;
/* kMMFlowViewIconRefPathRepresentationType, image representation is a NSURL or a NSString holding a filepath to an IconRef */
extern NSString * const kMMFlowViewIconRefPathRepresentationType;
/* kMMFlowViewIconRefRepresentationType, image representation is an IconRef */
extern NSString * const kMMFlowViewIconRefRepresentationType;

/* binding for keypath to the image-representation, see MMFlowViewItem protocol */
extern NSString * const kMMFlowViewImageRepresentationBinding;
/* binding for keypath to the image-representationtype, see MMFlowViewItem protocol */
extern NSString * const kMMFlowViewImageRepresentationTypeBinding;
/* binding for keypath to the image-uid, see MMFlowViewItem protocol */
extern NSString * const kMMFlowViewImageUIDBinding;
/* binding for keypath to the image-title, see MMFlowViewItem protocol */
extern NSString * const kMMFlowViewImageTitleBinding;

/* posted after the selection did change. Get the current selection with the kMMFlowViewSelectedIndexKey from the userInfo */
extern NSString * const kMMFlowViewSelectionDidChangeNotification;

/* key for accessing selection changes in notifications or for setting up bindings */
extern NSString * const kMMFlowViewSelectedIndexKey;

/* protocol which the image items need to implement if datasource is used or no respective keypaths in bindings are set */
@protocol MMFlowViewItem <NSObject>
/* The image to display, can return nil if the item has no image to display. This method is called frequently */
- (id)imageItemRepresentation;
/* A string that specifies the image representation. The string can be any of the following constants:
 
 kMMFlowViewURLRepresentationType
 kMMFlowViewCGImageRepresentationType
 kMMFlowViewPDFPageRepresentationType
 kMMFlowViewPathRepresentationType
 kMMFlowViewNSImageRepresentationType
 kMMFlowViewCGImageSourceRepresentationType
 kMMFlowViewNSDataRepresentationType
 kMMFlowViewNSBitmapRepresentationType
 kMMFlowViewQTMovieRepresentationType
 kMMFlowViewQTMoviePathRepresentationType
 kMMFlowViewQCCompositionRepresentationType
 kMMFlowViewQCCompositionPathRepresentationType
 kMMFlowViewQuickLookPathRepresentationType
 kMMFlowViewIconRefPathRepresentationType
 kMMFlowViewIconRefRepresentationType */

- (NSString*)imageItemRepresentationType;
/* A string the uniquely identifies the data source item. The flowview uses this identifier to associate the data source item and its cache */
- (NSString*)imageItemUID;
@optional
/* The display title of the image. */
- (NSString*)imageItemTitle;

@end

@protocol MMFlowViewDataSource <NSObject>
/* Returns the number of images in the flow view. */
- (NSUInteger)numberOfItemsInFlowView:(MMFlowView*)aFlowView;
/* Returns an object for the item in a flow view that corresponds to the specified index.
 The returned object must implement the required methods of the MMFlowViewItem protocol */
- (id<MMFlowViewItem>)flowView:(MMFlowView*)aFlowView itemAtIndex:(NSUInteger)anIndex;
// Drag and Drop
@optional
/* Invoked the flow view when the mouse button is released over the specified index if the datasource validated the drop.
 The datasource should read the data from the dragging pasteboard provided through the NSDraggingInfo-object */
- (BOOL)flowView:(MMFlowView*)aFlowView acceptDrop:(id < NSDraggingInfo >)info atIndex:(NSUInteger)anIndex;
/* The receiver may validate the drop at the specified index */
- (NSDragOperation)flowView:(MMFlowView*)aFlowView validateDrop:(id < NSDraggingInfo >)info proposedIndex:(NSUInteger)anIndex;
/* Invoked by the flow view when drag should begin. Return NO to abort the drag, otherwise write the data to the pasteboard */
- (BOOL)flowView:(MMFlowView*)aFlowViev writeItemAtIndex:(NSUInteger)anIndex toPasteboard:(NSPasteboard *)pboard;
/* Indicates that the specified index should be removed */
- (void)flowView:(MMFlowView*)aFlowView removeItemAtIndex:(NSUInteger)anIndex;

@end

@protocol MMFlowViewDelegate <NSObject>
@optional
/* Allows for customizing double clicks on items */
- (void)flowView:(MMFlowView *)aFlowView itemWasDoubleClickedAtIndex:(NSUInteger)anIndex;
/* Allows for customizing right clicks at indexes */
- (void)flowView:(MMFlowView *)aFlowView itemWasRightClickedAtIndex:(NSUInteger)anIndex withEvent:(NSEvent *)theEvent;
/* Invoked after a selection of the flow view changed */
- (void)flowViewSelectionDidChange:(MMFlowView *)aFlowView;

@end


@interface MMFlowView : NSControl<QLPreviewPanelDataSource, QLPreviewPanelDelegate>
#ifdef __i386__
{
@private
	CATransform3D leftTransform;
	CATransform3D rightTransform;
	CATransform3D perspective;
	CALayer *backgroundLayer;
	CATextLayer *titleLayer;
	CAScrollLayer *scrollLayer;
	CALayer *containerLayer;
	CALayer *scrollBarLayer;
	CALayer *selectedLayer;
	CALayer *highlightedLayer;
	id<MMFlowViewDataSource> dataSource;
	id<MMFlowViewDelegate> delegate;
	CGFloat stackedAngle;
	CGFloat spacing;
	CGFloat stackedScale;
	CGFloat selectedScale;
	CGFloat reflectionOffset;
	CGFloat itemScale;
	CGFloat mouseDownInKnob;
	CGFloat previewScale;
	CFTimeInterval scrollDuration;
	NSUInteger selectedIndex;
	NSUInteger numberOfItems;
	BOOL showsReflection;
	BOOL draggingKnob;
	BOOL canControlQuickLookPanel;
	NSCache *imageCache;
	NSMutableArray *layerQueue;
	NSIndexSet *visibleItemIndexes;
	NSOperationQueue *operationQueue;
	NSMutableDictionary *bindingInfo;
	NSArray *observedItems;
	NSString *imageRepresentationKeyPath;
	NSString *imageRepresentationTypeKeyPath;
	NSString *imageUIDKeyPath;
	NSString *imageTitleKeyPath;
}
#endif

/* title for currently selected index */
@property (copy,nonatomic) id title;
/* weak reference to the datasource, see MMFlowViewDataSource protocol */ 
@property (assign) IBOutlet id<MMFlowViewDataSource> dataSource;
/* weak reference to the delegate, see MMFlowViewDelegate protocol */
@property (assign) IBOutlet id<MMFlowViewDelegate> delegate;
/* the angle in degrees around which the unselected images are rotated around the y-axis (counter clockwise for the left-stack, clockwise for the right-stack) */
@property (assign, nonatomic) CGFloat stackedAngle;
/* spacing between images in stack */
@property (assign, nonatomic) CGFloat spacing;
/* scaling used for stacked (aka non-selected images */
@property (assign, nonatomic) CGFloat stackedScale;
/* scaling for selected image */
@property (assign, nonatomic) CGFloat selectedScale;
/* CGFloat value for darkening the reflection in the range of 0-1. 0 means no darkening, 1 is completly black, meaning no reflection at all */
@property (assign, nonatomic) CGFloat reflectionOffset;
/* scaling factor for image-items */
@property (assign, nonatomic) CGFloat itemScale;
/* scale value for cached image resolution in the range of 0-1, 0 means smaller cached images, 1 is images in the size of the actual image-tile */
@property (assign, nonatomic) CGFloat previewScale;
/* duration of a scroll in changing the selection */
@property (assign, nonatomic) CFTimeInterval scrollDuration;
/* flag to indicate wheter reflections are shown or not */
@property (assign, nonatomic) BOOL showsReflection;
/* if set to YES, MMFlowView can act as a datasource for QLQuickLookPanel for all path-representation types (all NSURL or filepath-NSStrings), hitting space invokes the panel */
@property (assign, nonatomic) BOOL canControlQuickLookPanel;
/* the selected index */
@property (assign, nonatomic) NSUInteger selectedIndex;
/* number of items in view */
@property (readonly, nonatomic) NSUInteger numberOfItems;
/* indexes of all visible items */
@property (retain, readonly) NSIndexSet *visibleItemIndexes;
/* keypath to image representation on item in observed collection, defaults to imageItemRepresentation, see MMFlowViewItem protocol */
@property (nonatomic,copy) NSString *imageRepresentationKeyPath;
/* keypath to image representation type on item in observed collection, defaults to imageItemRepresentationType, see MMFlowViewItem protocol */
@property (nonatomic,copy) NSString *imageRepresentationTypeKeyPath;
/* keypath to image uid on item in observed collection, defaults to imageItemUID, see MMFlowViewItem protocol */
@property (nonatomic,copy) NSString *imageUIDKeyPath;
/* keypath to image title on item in observed collection, defaults to imageItemTitle, see MMFlowViewItem protocol */
@property (nonatomic,copy) NSString *imageTitleKeyPath;

/* sets the font of the title */
- (void)setTitleFont:(NSFont*)aFont;
/* sets the font size of the title */
- (void)setTitleSize:(CGFloat)aSize;
/* sets the color for the title */
- (void)setTitleColor:(NSColor*)aColor;
/* returns the index of the image item if the aPoint is above it, otherwise NSNotFound */
- (NSUInteger)indexOfItemAtPoint:(NSPoint)aPoint;
/* returns the frame for the image-item at a specific index */
- (NSRect)itemFrameAtIndex:(NSUInteger)anIndex;
/* reloads the content from the datasource, see MMFlowViewDataSource protocol */
- (void)reloadContent;

@end
