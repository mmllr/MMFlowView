# MMFlowView
[![Build Status](https://travis-ci.org/mmllr/MMFlowView.png?branch=master)](https://travis-ci.org/mmllr/MMFlowView)  
A full featured cover flow control for Mac OS X.
![Screenshot](https://raw.github.com/mmllr/MMFlowView/master/Resources/FlowView.png)
## Description

MMFlowView is a class designed to support the "CoverFlow" effect and it is intended to use in a similar way like IKImageBrowserView. It supports all the image types (URLs, NSImage, Icons, QuartzComposerCompositions, QTMovie) as IKImageBrowserView. If you are familiar with IKImageBrowserView you can immediately start using MMFlowView.

MMFlowView uses asynchronous image loading and caches the image content, trying to use as little memory as possible. It supports both image loading via a datasource or with Cocoa bindings. It is accessibility conform, features drag&drop und quicklook preview. Its makes use of CoreAnimation to provide smooth and fast animations.

## License

MIT-license.

## Supported OS & SDK Versions

* Supported build target - Mac OS 10.8 (Xcode 5)
* Earliest compatible deployment target - Mac OS 10.7

## Installation

MMFlowView is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

	pod "MMFlowView"

## Protocols
If you are using the datasource-approach for loading the images your data items need to implement the MMFlowViewItem (similar to IKImageBrowserItem):

	- (id)imageItemRepresentation;

The image to display, can return nil if the item has no image to display. This method is called frequently.

	- (id)imageItemRepresentationType;

A string that specifies the image representation. The string can be any of the following constants:
 
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

Describes the type of the datasource item.

	- (NSString*)imageItemUID;

A string the uniquely identifies the data source item. The flowview uses this identifier to associate the data source item and its cache.

	- (NSString*)imageItemTitle;

The display title of the image.


MMFlowView follows the Apple convention for data-driven views by providing two protocol interfaces, MMFlowViewDataSource and MMFlowViewDelegate. The MMFlowViewDataSource protocol has the following required methods

	- (NSUInteger)numberOfItemsInFlowView:(MMFlowView*)aFlowView;

Returns the number of images in the flow view.

	- (id<MMFlowViewItem>)flowView:(MMFlowView*)aFlowView itemAtIndex:(NSUInteger)anIndex;

Returns an object for the item in a flow view that corresponds to the specified index. The returned object must implement the required methods of the MMFlowViewItem protocol.

See the comments in the header of MMFlowView.h for more details.

## Bindings

To load the images via Cocoa bindings you have to set the keypaths of the image-items via the following properties:

	@property (nonatomic,copy) NSString *imageRepresentationKeyPath;

Keypath to image representation on item in observed collection, defaults to imageItemRepresentation, see MMFlowViewItem protocol.

	@property (nonatomic,copy) NSString *imageRepresentationTypeKeyPath;

Keypath to image representation type on item in observed collection, defaults to imageItemRepresentationType, see MMFlowViewItem protocol.

	@property (nonatomic,copy) NSString *imageUIDKeyPath;

Keypath to image uid on item in observed collection, defaults to imageItemUID, see MMFlowViewItem protocol.

	@property (nonatomic,copy) NSString *imageTitleKeyPath;

Keypath to image title on item in observed collection, defaults to imageItemTitle, see MMFlowViewItem protocol.

If you don´t set this keypaths, your image-items need to support the MMFlowViewItem protocol. 
Then MMFlowView exposes an NSContentArrayBinding, which must be bound to an NSArrayControllers arrangedObjects:

		[ self.flowView bind:NSContentArrayBinding
			   			toObject:self.itemArrayController
			  withKeyPath:@"arrangedObjects"
				 options:nil ];

Then you are done and the MMFlowView automatically observes your datasource.

Have a look in the MMFlowViewDemo-project, which shows how to use drag&drop and the quicklook previewpanel.

