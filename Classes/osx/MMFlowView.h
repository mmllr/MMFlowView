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
//  MMFlowView.h
//  FlowView
//
//  Created by Markus Müller on 13.01.12.

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

@class MMFlowView;

/**
 * @name Image Representation Types
 */

/**
 * Representation types for images

 @code
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
 kMMFlowViewIconRefRepresentationType
 @endcode
*/

/**
 kMMFlowViewURLRepresentationType

 An NSURL object.
 */
extern NSString * const kMMFlowViewURLRepresentationType;

/**
 kMMFlowViewCGImageRepresentationType

 A CGImageRef object.
 */
extern NSString * const kMMFlowViewCGImageRepresentationType;

/**
 kMMFlowViewPDFPageRepresentationType

 A PDFPage instance or a CGPDFPageRef.
 */
extern NSString * const kMMFlowViewPDFPageRepresentationType;

/**
 kMMFlowViewPathRepresentationType

 A path representation (NSString).
 */
extern NSString * const kMMFlowViewPathRepresentationType;

/**
 kMMFlowViewNSImageRepresentationType

 An NSImage object.
 */
extern NSString * const kMMFlowViewNSImageRepresentationType;

/**
 kMMFlowViewCGImageSourceRepresentationType

 A CGImageSourceRef object.
 */
extern NSString * const kMMFlowViewCGImageSourceRepresentationType;

/**
 kMMFlowViewNSDataRepresentationType

 An NSData object.
 */
extern NSString * const kMMFlowViewNSDataRepresentationType;

/**
 kMMFlowViewNSBitmapRepresentationType

 An NSBitmapImageRep object.
 */
extern NSString * const kMMFlowViewNSBitmapRepresentationType;

/**
 kMMFlowViewQTMovieRepresentationType

 A QTMovie object.
 @deprecated Deprecated in OS X 10.9, will be removed in a future version of MMFlowView.
 */
extern NSString * const kMMFlowViewQTMovieRepresentationType;

/**
 kMMFlowViewQTMoviePathRepresentationType

 A path (NSString) or URL (NSURL) to a QuickTime movie.
 @deprecated Deprecated in OS X 10.9, will be removed in a future version of MMFlowView.
 */
extern NSString * const kMMFlowViewQTMoviePathRepresentationType;

/**
 kMMFlowViewQCCompositionRepresentationType

 A QCComposition object.
 */
extern NSString * const kMMFlowViewQCCompositionRepresentationType;

/**
 kMMFlowViewQCCompositionPathRepresentationType

 A path (NSString) or URL (NSURL) to a Quartz Composer composition.
 */
extern NSString * const kMMFlowViewQCCompositionPathRepresentationType;

/**
 kMMFlowViewQuickLookPathRepresentationType

 A path (NSString) or URL (NSURL) to load data using QuickLook.
 */
extern NSString * const kMMFlowViewQuickLookPathRepresentationType;

/**
 kMMFlowViewIconRefPathRepresentationType

 A path (NSString) or URL (NSURL) to an icon.
 */
extern NSString * const kMMFlowViewIconRefPathRepresentationType;

/**
 kMMFlowViewIconRefRepresentationType

 An icon.
 */
extern NSString * const kMMFlowViewIconRefRepresentationType;

/**
 A binding for keypath to the image representation.
 @see MMFlowViewItem protocol.
 */
extern NSString * const kMMFlowViewImageRepresentationBinding;

/**
 A binding for keypath to the image-representationtype
 @see MMFlowViewItem protocol.
 */
extern NSString * const kMMFlowViewImageRepresentationTypeBinding;

/**
 A binding for keypath to the image uid.
 @see MMFlowViewItem protocol.
 */
extern NSString * const kMMFlowViewImageUIDBinding;

/**
 A binding for keypath to the image title.
 @see MMFlowViewItem protocol.
 */
extern NSString * const kMMFlowViewImageTitleBinding;

/**
 A notification posted after the selection did change.
 
 Get the current selection with the kMMFlowViewSelectedIndexKey from the notifcations userInfo dictionary.
 */
extern NSString * const kMMFlowViewSelectionDidChangeNotification;

/**
 The key for accessing selection changes in notifications or for setting up bindings.
 */
extern NSString * const kMMFlowViewSelectedIndexKey;

/**
 The MMFlowViewItem protocol which the image items need to implement if datasource is used or no respective keypaths in bindings are set.
 */
@protocol MMFlowViewItem <NSObject>

/**
 The image to display, can return nil if the item has no image to display. This method is called frequently. (required)
 
 Your image item must implement this method.
 
 @return The image representation in one of the supported types @see -imageItemRepresentationType
 */
- (id)imageItemRepresentation;

/**
 A string that specifies the image representation.
 
 Your image item must implement this method. The string must be any of the following constants:
 
 @return A string that specifies the image representation type. The string can be any of the constants defined in “Image Representation Types”.
 */
- (NSString*)imageItemRepresentationType;
/**
 A string the uniquely identifies the data source item. (required)
 
 Your image item must implement this method. The flowview uses this identifier to associate the data source item and its cache.
 
 @return The string that idenitifies the image item.
 */
- (NSString*)imageItemUID;

@optional

/**
 Returns the display title of the image.

 This method is optional.
 
 @return The string with the display title of the image.
 */
- (NSString*)imageItemTitle;

@end


/**
 The MMFlowViewDataSource protocol declares methods that an MMFLowView uses to access the contents of its datasource object.
 */
@protocol MMFlowViewDataSource <NSObject>

/** @name Getting Values */

/**
 Returns the number of images in the flow view. (required)
 
 @param aFlowView The flow view that sent the message.
 @return The number of images in aFlowView
 */
- (NSUInteger)numberOfItemsInFlowView:(MMFlowView*)aFlowView;

/**
 Returns an object for the item in a flow view that corresponds to the specified index. (required)

 The returned object must implement the required methods of the MMFlowViewItem protocol

 @param aFlowView The flow view that sent the message.
 @param anIndex   The zero based item index in aFlowView
 @return An item in the data source which must conform to the MMFLowViewItem protocol.
 @warning This method is mandatory unless your application is using Cocoa bindings for providing data to the flow view.
 */
- (id<MMFlowViewItem>)flowView:(MMFlowView*)aFlowView itemAtIndex:(NSUInteger)anIndex;

/** @name Drag and Drop */

@optional
/**
 Invoked the flow view when the mouse button is released over the specified index if the datasource validated the drop. (optional)
 
 The datasource should read the data from the dragging pasteboard provided through the NSDraggingInfo object
 @param aFlowView The flow view that sent the message.
 @param info      An object that contains more information about this dragging operation.
 @param anIndex   The index of the proposed target image item.

 @return YES if the drop operation was successful, otherwise NO.
 */
- (BOOL)flowView:(MMFlowView*)aFlowView acceptDrop:(id < NSDraggingInfo >)info atIndex:(NSUInteger)anIndex;

/**
 Used by @c aFlowView to determine a valid drop target. (optional)

 @param aFlowView The flow view that sent the message.
 @param info      An object that contains more information about this dragging operation.
 @param anIndex   The index of the proposed target image item.
 @return The dragging operation the data source will perform.
 */
- (NSDragOperation)flowView:(MMFlowView*)aFlowView validateDrop:(id < NSDraggingInfo >)info proposedIndex:(NSUInteger)anIndex;

/**
 Returns a Boolean value that indicates whether a drag operation is allowed. (optional)
 
 Invoked by the flow view when drag should begin. Return NO to abort the drag, otherwise write the data to the pasteboard.
 @param aFlowViev The flow view that sent the message.
 @param anIndex   The index of the image item.
 @param pboard    The pasteboard to which to write the drag data.

 @return YES if the drag operation is allowed, NO otherwise.
 */
- (BOOL)flowView:(MMFlowView*)aFlowViev writeItemAtIndex:(NSUInteger)anIndex toPasteboard:(NSPasteboard *)pboard;

/**
 Indicates that the specified index should be removed after a drop to the trash.

 @param aFlowView The flow view that sent the message.
 @param anIndex   The index of the item to be removed.
 */
- (void)flowView:(MMFlowView*)aFlowView removeItemAtIndex:(NSUInteger)anIndex;

@end

/**
 The MMFlowViewDelegate protocol defines the optional methods implemented by delegates of MMFlowView objects. Using a delegate allows you to customize a flow view’s behavior without creating a flow view subclass.
  */
@protocol MMFlowViewDelegate <NSObject>
@optional
/**
 Tells the delegate that the mouse button was double clicked on the specified item.

 @param aFlowView The flow view that sent the message.
 @param anIndex   The index of the image item which was double clicked.
 */
- (void)flowView:(MMFlowView *)aFlowView itemWasDoubleClickedAtIndex:(NSUInteger)anIndex;

/**
 Tells the delegate that a right click was performed on a specified item.
 
 @param aFlowView The flow view that sent the message.
 @param anIndex   The index of the image item which was right clicked. This is always the selected item.
 @param theEvent  The NSEvent from the click. Use it for example to ask which modifier keys where additionally pressed.
 */
- (void)flowView:(MMFlowView *)aFlowView itemWasRightClickedAtIndex:(NSUInteger)anIndex withEvent:(NSEvent *)theEvent;

/**
 Tells the delegate that the flow view’s selection has changed.
 @param aFlowView The flow view that sent the message.
 */
- (void)flowViewSelectionDidChange:(MMFlowView *)aFlowView;

/**
 Declares the types of operations the flow view allows to be performed.
 
 @param aFlowView The flow view that sent the message.
 @param session   The dragging session.
 @param context   The dragging context. @see NSDraggingContext for the supported values.
 @return The appropriate dragging operation as defined in NSDraggingContext.
 */
- (NSDragOperation)flowView:(MMFlowView *)aFlowView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context;
@end


/**
 The MMFlowView us a view for displaying images with the so called "CoverFlow" effect, as in the Finder.

 You must either provide images through a datasource, which needs to implement at a minimum the -numberOfItemsInFlowView: and -flowView:itemAtIndex: described in the @c MMFlowViewDataSource protocol. The items must conform to the @c MMFlowViewItem protocol. An alternative is to use Cocoa Bindings: bind the @c NSContentArray binding to an @c NSArrayController, which manages either a collection of objects conforming to the @c MMFlowViewItem protocol or set the flow views imageRepresentationKeyPath, imageRepresentationTypeKeyPath, imageUIDKeyPath and imageTitleKeyPath to the appropriate keys on your items.
 
 The MMFlowView aggressively caches the images and loads them asynchronously at a fitting size.
 
 @warning It uses CoreAnimation to display the images and is thus always layer backed. You must not add any subviews to the flow view.

 The class's delegate object must conform to MMFlowViewDelegate protocol.
 */
@interface MMFlowView : NSControl

/**
 The title for the currently selected item
*/
@property (readonly, copy, nonatomic) NSString *title;

/**
 A weak reference to the datasource, @see MMFlowViewDataSource protocol
 */
@property (weak) IBOutlet id<MMFlowViewDataSource> dataSource;

/**
 A weak reference to the delegate, @see MMFlowViewDelegate protocol
 */
@property (weak) IBOutlet id<MMFlowViewDelegate> delegate;

/**
 The angle in degrees around which the unselected images are rotated around the y-axis.

 The images will be rotated counter clockwise for all items left to the selected item, and clockwise for the items right to the selected item.

 The angle will be clamped in the range of 0-90 degrees.
 */
@property (nonatomic) CGFloat stackedAngle;

/**
 The spacing between images in the flow view. The minimum accepted value 1.0.
 */
@property (nonatomic) CGFloat spacing;

/**
 The value for darkening the reflection in the range of 0-1.

 A value of 0.0 is no darkening, 1.0 is completely black, displaying no reflection at all.
 */
@property (nonatomic) CGFloat reflectionOffset;

/**
 Enable or disable the reflection of the flow view.

 A value of YES enabled reflections, NO disables them.
 */
@property (nonatomic) BOOL showsReflection;

/**
 A toggle for controlling the QuickLook panel.

 If set to YES, the flow view can act as a datasource for a QLQuickLookPanel for all path representation types (all NSURL or filepath imageItemRepresentationTypes).
 Hitting space invokes the panel.
 @see MMFlowViewItem protocol.
 */
@property (nonatomic) BOOL canControlQuickLookPanel;

/**
 The currently selected index. Is NSNotFound for an emtpy flow view.
 */
@property (nonatomic) NSUInteger selectedIndex;

/**
 The number of items in the flow view.
 */
@property (readonly, nonatomic) NSUInteger numberOfItems;

/**
 The indexes of all visible items in the flow view.
 */
@property (nonatomic, readonly) NSIndexSet *visibleItemIndexes;

/**
 he keypath on the individual items for the image representation. @see MMFlowViewItem protocol

 The default value is @"imageItemRepresentation", matching the method -imageItemRepresentation in the MMFlowViewItem protocol.
 
 You only need to set this property if you are using Cocoa Bindings for the content of the flow view and the items do not conform to the @c MMFlowViewItem protocol.
 If your items don't conform to the @c MMFlowViewItem protocol but can provide an image, you can specify the keypath on the item. Suppose you have an item class with an imageValue getter:
 @code
 @interface YourItem : NSObject
    - (NSImage*)imageValue;
 @end
 @endcode
 Set the flow views @c imageRepresentationKeyPath to *imageValue*:
 @code
    MMFlowView *flowView = ... // a flow view using Cocoa Bindings through an array controller
    flowView.imageRepresentationKeyPath = @"imageValue";
  @endcode
 */
@property (copy) NSString *imageRepresentationKeyPath;

/**
 The keypath on the individual items for the image representation type. @see MMFlowViewItem

 The default value is @"imageItemRepresentationType", matching the method -imageItemRepresentationType in the MMFlowViewItem protocol.

 You only need to set this property if you are using Cocoa Bindings for the content of the flow view and the items do not conform to the @c MMFlowViewItem protocol.
 If your items don't conform to the @c MMFlowViewItem protocol but can provide an image representation type, you can specify the keypath on the item.
 Suppose you have an item class with an imageType getter:
 @code
 @interface YourItem : NSObject
    - (NSString*)imageType;
 @end
 @endcode
 Set the flow views imageRepresentationTypeKeyPath to *imageType*:
 @code
	MMFlowView *flowView = ... // a flow view using Cocoa Bindings through an array controller
	flowView.imageRepresentationTypeKeyPath = @"imageType";
 @endcode
 */
@property (copy) NSString *imageRepresentationTypeKeyPath;

/**
 The keypath on the individual items for the image UID. @see MMFlowViewItem

 The default value is @"imageItemUID", matching the method -imageItemUID in the MMFlowViewItem protocol.
 
 You only need to set this property if you are using Cocoa Bindings for the content of the flow view and the items do not conform to the @c MMFlowViewItem protocol.
 If your items don't conform to the @c MMFlowViewItem protocol but can provide an image UID, you can specify the keypath on the item.
 Suppose you have an item class with an uniqueID getter:
 @code
 @interface YourItem : NSObject
    - (NSString*)uniqueID;
 @end
 @endcode
 Set the flow views @c imageUIDKeyPath to *uniqueID*:
 @code
	MMFlowView *flowView = ... // a flow view using Cocoa Bindings through an array controller
	flowView.imageUIDKeyPath = @"uniqueID";
 @endcode
 */
@property (copy) NSString *imageUIDKeyPath;

/**
 The keypath on the individual items for the image title. @see MMFlowViewItem

 The default value is @"imageItemTitle", matching the method -imageItemTitle in the MMFlowViewItem protocol.

 You only need to set this property if you are using Cocoa Bindings for the content of the flow view and the items do not conform to the @c MMFlowViewItem protocol.
 If your items don't conform to the @c MMFlowViewItem protocol but can provide an title, you can specify the keypath on the item.
 Suppose you have an item class with an itemUID getter:
 @code
 @interface YourItem : NSObject
    - (NSString*)title;
 @end
 @endcode
 Set the flow views @c imageUIDKeyPath to *title*:
 @code
	MMFlowView *flowView = ... // a flow view using Cocoa Bindings through an array controller
	imageTitleKeyPath = @"title";
 @endcode
 */
@property (copy) NSString *imageTitleKeyPath;

/**
 Set the font for the title string. The default value is Helvetica.
 
 @param aFont The font for the title.
 */
- (void)setTitleFont:(NSFont*)aFont;

/**
 Returns the font size of the title.
 
 @return The size of the title. Defaults to 18.
 */
- (CGFloat)titleSize;

/**
 Sets the size of the title.

 @param aSize The new size of the title.
 */
- (void)setTitleSize:(CGFloat)aSize;

/**
 Set the color of the title.

 The default title color is white.
 @param aColor The color for the title.
 */
- (void)setTitleColor:(NSColor*)aColor;

/**
 The index of the image at the point in the flow views coordinate space.

 @param aPoint A point in the flow views coordinate space.
 @return The index of the image if there is an image at the specified location, otherwise @c NSNotFound.
 */
- (NSUInteger)indexOfItemAtPoint:(NSPoint)aPoint;

/**
 Marks the flow view as needing redisplay, so it will reload the data for visible items and draw the new values.

  @note This method will invalidate the internal image cache.
 
  @warning You don't need to use this method if you provide the flow views content with Cocoa Bindings as the flow view will automatically discover changes on the bound NSArrayControllers contentArray.
 */
- (void)reloadContent;

@end
