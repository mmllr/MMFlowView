//
//  MMFlowViewTestDoubles.m
//  MMFlowViewDemo
//
//  Created during Kiwi-to-XCTest migration.
//  Simple hand-written test doubles and recording subclasses.
//  No mocking framework involved; all assertions happen in the specs via XCTest.
//

#import "MMFlowViewTestDoubles.h"

#pragma mark - MMFlowViewDataSource

@implementation MMTestFlowViewDataSource

- (instancetype)initWithItems:(NSArray *)items
{
	self = [super init];
	if (self) {
		_items = [items copy];
		_acceptsDrop = YES;
		_dropOperation = NSDragOperationCopy;
	}
	return self;
}

- (NSUInteger)numberOfItemsInFlowView:(MMFlowView *)aFlowView
{
	_numberOfItemsCallCount++;
	return [_items count];
}

- (id<MMFlowViewItem>)flowView:(MMFlowView *)aFlowView itemAtIndex:(NSUInteger)anIndex
{
	return _items[anIndex];
}

- (BOOL)flowView:(MMFlowView *)aFlowView acceptDrop:(id<NSDraggingInfo>)info atIndex:(NSUInteger)anIndex
{
	_acceptDropCallCount++;
	return _acceptsDrop;
}

- (NSDragOperation)flowView:(MMFlowView *)aFlowView validateDrop:(id<NSDraggingInfo>)info proposedIndex:(NSUInteger)anIndex
{
	return anIndex == NSNotFound ? NSDragOperationNone : _dropOperation;
}

- (BOOL)flowView:(MMFlowView *)aFlowView writeItemAtIndex:(NSUInteger)anIndex toPasteboard:(NSPasteboard *)pboard
{
	return YES;
}

- (void)flowView:(MMFlowView *)aFlowView removeItemAtIndex:(NSUInteger)anIndex
{
	_removeItemAtIndexCallCount++;
}

@end

#pragma mark - MMFlowViewDelegate

@implementation MMTestFlowViewDelegate

- (void)flowViewSelectionDidChange:(MMFlowView *)aFlowView
{
	_selectionChangeCount++;
}

- (void)flowView:(MMFlowView *)aFlowView itemWasDoubleClickedAtIndex:(NSUInteger)anIndex
{
	_doubleClickCount++;
	_lastDoubleClickedIndex = (NSInteger)anIndex;
}

- (void)flowView:(MMFlowView *)aFlowView itemWasRightClickedAtIndex:(NSUInteger)anIndex withEvent:(NSEvent *)theEvent
{
	_rightClickCount++;
	_lastRightClickedIndex = (NSInteger)anIndex;
}

- (NSDragOperation)flowView:(MMFlowView *)aFlowView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
	return _sourceOperationMask;
}

@end

#pragma mark - MMFlowViewContentAdapter

@implementation MMTestContentAdapter

- (instancetype)initWithItems:(NSArray *)items
{
	self = [super init];
	if (self) {
		_items = [items copy];
	}
	return self;
}

- (NSUInteger)count
{
	return [_items count];
}

- (id<MMFlowViewItem>)objectAtIndexedSubscript:(NSUInteger)index
{
	return _items[index];
}

@end

#pragma mark - MMCoverFlowLayerDataSource

@implementation MMTestCoverFlowLayerDataSource

- (instancetype)init
{
	self = [super init];
	if (self) {
		_requestedIndexes = [NSMutableArray array];
	}
	return self;
}

- (CALayer *)coverFlowLayer:(MMCoverFlowLayer *)layer contentLayerForIndex:(NSUInteger)index
{
	[_requestedIndexes addObject:@(index)];
	if (index < [_requestedLayers count]) {
		return _requestedLayers[index];
	}
	if (self.contentLayerForAllItems) {
		return self.contentLayerForAllItems;
	}
	return [CALayer layer];
}

- (void)coverFlowLayerWillRelayout:(MMCoverFlowLayer *)coverFlowLayer
{
	_willRelayoutCount++;
}

- (void)coverFlowLayerDidRelayout:(MMCoverFlowLayer *)coverFlowLayer
{
	_didRelayoutCount++;
}

- (void)coverFlowLayer:(MMCoverFlowLayer *)coverFlowLayer willShowLayer:(CALayer *)contentLayer atIndex:(NSUInteger)index
{
	_willShowLayerCount++;
}

@end

#pragma mark - MMCoverFlowLayoutDelegate

@implementation MMTestCoverFlowLayoutDelegate

- (CGFloat)coverFLowLayout:(MMCoverFlowLayout *)theLayout aspectRatioForItem:(NSUInteger)itemIndex
{
	return _aspectRatio;
}

@end

#pragma mark - MMFlowViewContentBinderDelegate

@implementation MMTestContentBinderDelegate

- (void)contentArrayDidChange:(MMFlowViewContentBinder *)contentBinder
{
	_contentArrayDidChangeCount++;
}

- (void)contentBinder:(MMFlowViewContentBinder *)contentBinder itemChanged:(id<MMFlowViewItem>)anItem
{
	_itemChangedCount++;
}

@end

#pragma mark - MMScrollBarDelegate

@implementation MMTestScrollBarDelegate

- (instancetype)init
{
	self = [super init];
	if (self) {
		_draggedPositions = [NSMutableArray array];
	}
	return self;
}

- (void)scrollBarLayer:(MMScrollBarLayer *)scrollBarLayer knobDraggedToPosition:(CGFloat)positionInPercent
{
	[_draggedPositions addObject:@(positionInPercent)];
}

- (void)decrementClickedInScrollBarLayer:(MMScrollBarLayer *)scrollBarLayer
{
	_decrementCount++;
}

- (void)incrementClickedInScrollBarLayer:(MMScrollBarLayer *)scrollBarLayer
{
	_incrementCount++;
}

- (CGFloat)contentSizeForScrollBarLayer:(MMScrollBarLayer *)scrollBarLayer
{
	return _contentSize;
}

- (CGFloat)visibleSizeForScrollBarLayer:(MMScrollBarLayer *)scrollBarLayer
{
	return _visibleSize;
}

- (CGFloat)currentKnobPositionInScrollBarLayer:(MMScrollBarLayer *)scrollBarLayer
{
	return _knobPosition;
}

@end

#pragma mark - MMFlowViewImageCache

@implementation MMTestImageCache

- (instancetype)init
{
	self = [super init];
	if (self) {
		_cachedImages = [NSMutableDictionary dictionary];
	}
	return self;
}

- (CGImageRef)imageForUUID:(NSString *)anUUID
{
	if (!anUUID) {
		return NULL;
	}
	return (__bridge CGImageRef)(_cachedImages[anUUID]);
}

- (void)cacheImage:(CGImageRef)anImage withUUID:(NSString *)anUUID
{
	_cachedImages[anUUID] = (__bridge id)anImage;
}

- (void)removeImageWithUUID:(NSString *)anUUID
{
	[_cachedImages removeObjectForKey:anUUID];
}

- (void)reset
{
	_resetCount++;
	[_cachedImages removeAllObjects];
}

@end

#pragma mark - MMImageDecoderProtocol

@implementation MMTestImageDecoder

+ (instancetype)decoderWithItem:(id)item maxPixelSize:(NSUInteger)maxPixelSize image:(CGImageRef)image
{
	MMTestImageDecoder *decoder = [[MMTestImageDecoder alloc] initWithItem:item maxPixelSize:maxPixelSize];
	decoder.imageRef = image;
	return decoder;
}

- (id<MMImageDecoderProtocol>)initWithItem:(id)anItem maxPixelSize:(NSUInteger)maxPixelSize
{
	self = [super init];
	return self;
}

- (CGImageRef)CGImage
{
	return _imageRef;
}

- (NSImage *)image
{
	return _imageRef ? [[NSImage alloc] initWithCGImage:_imageRef size:NSZeroSize] : nil;
}

@end

#pragma mark - NSDraggingInfo

@implementation MMTestDraggingInfo
{
	NSPoint _draggedImageLocation;
	NSImage *_draggedImage;
	NSDraggingFormation _draggingFormation;
	BOOL _animatesToDestination;
	NSInteger _numberOfValidItemsForDrop;
	NSSpringLoadingHighlight _springLoadingHighlight;
}

- (NSWindow *)draggingDestinationWindow { return nil; }
- (NSDragOperation)draggingSourceOperationMask { return NSDragOperationEvery; }
- (NSPoint)draggingLocation { return _draggingLocationValue; }
- (NSPoint)draggedImageLocation { return _draggedImageLocation; }
- (NSImage *)draggedImage { return _draggedImage; }
- (NSPasteboard *)draggingPasteboard { return _draggingPasteboardValue; }
- (id)draggingSource { return _draggingSourceValue; }
- (NSInteger)draggingSequenceNumber { return 0; }
- (NSDraggingFormation)draggingFormation { return _draggingFormation; }
- (void)setDraggingFormation:(NSDraggingFormation)draggingFormation { _draggingFormation = draggingFormation; }
- (BOOL)animatesToDestination { return _animatesToDestination; }
- (void)setAnimatesToDestination:(BOOL)animatesToDestination { _animatesToDestination = animatesToDestination; }
- (NSInteger)numberOfValidItemsForDrop { return _numberOfValidItemsForDrop; }
- (void)setNumberOfValidItemsForDrop:(NSInteger)numberOfValidItemsForDrop { _numberOfValidItemsForDrop = numberOfValidItemsForDrop; }
- (NSSpringLoadingHighlight)springLoadingHighlight { return _springLoadingHighlight; }
- (void)slideDraggedImageTo:(NSPoint)screenPoint { }
- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination { return @[]; }
- (void)enumerateDraggingItemsWithOptions:(NSDraggingItemEnumerationOptions)enumOpts forView:(NSView *)view classes:(NSArray<Class> *)classArray searchOptions:(NSDictionary<NSPasteboardReadingOptionKey, id> *)searchOptions usingBlock:(void (^)(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop))block { }
- (void)resetSpringLoading { }
- (NSDraggingSession *)draggingSession { return nil; }

@end

#pragma mark - QLPreviewItem

@implementation MMTestQLPreviewItem

- (NSURL *)previewItemURL
{
	return _previewItemURL;
}

- (NSString *)previewItemTitle
{
	return _previewItemTitle;
}

@end

#pragma mark - Recording subclasses

@implementation MMFlowViewRecordingSubclass

- (void)setSelectedIndex:(NSUInteger)index
{
	_setSelectedIndexCallCount++;
	_lastSelectedIndexArgument = (NSInteger)index;
	[super setSelectedIndex:index];
}

- (void)togglePreviewPanel:(id)sender
{
	_togglePreviewPanelCallCount++;
	[super togglePreviewPanel:sender];
}

- (void)reloadContent
{
	_reloadContentCallCount++;
	[super reloadContent];
}

- (void)keyDown:(NSEvent *)theEvent
{
	_keyDownCallCount++;
	_lastKeyDownEvent = theEvent;
	[super keyDown:theEvent];
}

- (NSWindow *)window
{
	if (self.windowOverride) {
		return self.windowOverride;
	}
	return [super window];
}

@end

@implementation MMCoverFlowLayerRecordingSubclass

- (void)setNeedsLayout
{
	_setNeedsLayoutCallCount++;
	[super setNeedsLayout];
}

- (void)layoutSublayers
{
	_layoutSublayersCallCount++;
	[super layoutSublayers];
}

- (void)reloadContent
{
	_reloadContentCallCount++;
	[super reloadContent];
}

@end
