//
//  MMFlowViewTestDoubles.h
//  MMFlowViewDemo
//
//  Created during Kiwi-to-XCTest migration.
//  Simple hand-written test doubles and recording subclasses.
//  No mocking framework involved; all assertions happen in the specs via XCTest.
//

#import <Cocoa/Cocoa.h>
#import <QuickLook/QuickLook.h>

#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMCoverFlowLayer.h"
#import "MMCoverFlowLayout.h"
#import "MMScrollBarLayer.h"
#import "MMFlowViewContentBinder.h"
#import "MMFlowViewContentAdapter.h"
#import "MMFlowViewImageCache.h"
#import "MMImageDecoderProtocol.h"

#pragma mark - MMFlowViewDataSource

@interface MMTestFlowViewDataSource : NSObject <MMFlowViewDataSource>

@property (nonatomic, strong) NSArray *items;
@property (nonatomic) BOOL acceptsDrop;
@property (nonatomic) NSDragOperation dropOperation;
@property (nonatomic, readonly) NSUInteger numberOfItemsCallCount;
@property (nonatomic, readonly) NSUInteger acceptDropCallCount;
@property (nonatomic, readonly) NSUInteger removeItemAtIndexCallCount;

- (instancetype)initWithItems:(NSArray *)items;

@end

#pragma mark - MMFlowViewDelegate

@interface MMTestFlowViewDelegate : NSObject <MMFlowViewDelegate>

@property (nonatomic, readonly) NSUInteger selectionChangeCount;
@property (nonatomic, readonly) NSUInteger doubleClickCount;
@property (nonatomic, readonly) NSInteger lastDoubleClickedIndex;
@property (nonatomic, readonly) NSUInteger rightClickCount;
@property (nonatomic, readonly) NSInteger lastRightClickedIndex;
@property (nonatomic) NSDragOperation sourceOperationMask;

@end

#pragma mark - MMFlowViewContentAdapter

@interface MMTestContentAdapter : NSObject <MMFlowViewContentAdapter>

@property (nonatomic, strong) NSArray *items;

- (instancetype)initWithItems:(NSArray *)items;

@end

#pragma mark - MMCoverFlowLayerDataSource

@interface MMTestCoverFlowLayerDataSource : NSObject <MMCoverFlowLayerDataSource>

@property (nonatomic, strong) CALayer *contentLayerForAllItems;
@property (nonatomic, strong) NSArray *requestedLayers;
@property (nonatomic, strong, readonly) NSMutableArray *requestedIndexes;
@property (nonatomic, readonly) NSUInteger willRelayoutCount;
@property (nonatomic, readonly) NSUInteger didRelayoutCount;
@property (nonatomic, readonly) NSUInteger willShowLayerCount;

@end

#pragma mark - MMCoverFlowLayoutDelegate

@interface MMTestCoverFlowLayoutDelegate : NSObject <MMCoverFlowLayoutDelegate>

@property (nonatomic) CGFloat aspectRatio;

@end

#pragma mark - MMFlowViewContentBinderDelegate

@interface MMTestContentBinderDelegate : NSObject <MMFlowViewContentBinderDelegate>

@property (nonatomic, readonly) NSUInteger contentArrayDidChangeCount;
@property (nonatomic, readonly) NSUInteger itemChangedCount;

@end

#pragma mark - MMScrollBarDelegate

@interface MMTestScrollBarDelegate : NSObject <MMScrollBarDelegate>

@property (nonatomic) CGFloat contentSize;
@property (nonatomic) CGFloat visibleSize;
@property (nonatomic) CGFloat knobPosition;
@property (nonatomic, strong, readonly) NSMutableArray *draggedPositions;
@property (nonatomic, readonly) NSUInteger decrementCount;
@property (nonatomic, readonly) NSUInteger incrementCount;

@end

#pragma mark - MMFlowViewImageCache

@interface MMTestImageCache : NSObject <MMFlowViewImageCache>

@property (nonatomic, strong, readonly) NSMutableDictionary *cachedImages; // UUID -> CGImage (bridged)
@property (nonatomic, readonly) NSUInteger resetCount;

@end

#pragma mark - MMImageDecoderProtocol

@interface MMTestImageDecoder : NSObject <MMImageDecoderProtocol>

@property (nonatomic) CGImageRef imageRef;

+ (instancetype)decoderWithItem:(id)item maxPixelSize:(NSUInteger)maxPixelSize image:(CGImageRef)image;

@end

#pragma mark - NSDraggingInfo

@interface MMTestDraggingInfo : NSObject <NSDraggingInfo>

@property (nonatomic) NSPoint draggingLocationValue;
@property (nonatomic, strong) id draggingSourceValue;
@property (nonatomic, strong) NSPasteboard *draggingPasteboardValue;

@end

#pragma mark - QLPreviewItem

@interface MMTestQLPreviewItem : NSObject <QLPreviewItem>

@property (nonatomic, strong) NSURL *previewItemURL;
@property (nonatomic, strong) NSString *previewItemTitle;

@end

#pragma mark - Recording subclasses

@interface MMFlowViewRecordingSubclass : MMFlowView

@property (nonatomic, readonly) NSUInteger setSelectedIndexCallCount;
@property (nonatomic, readonly) NSInteger lastSelectedIndexArgument;
@property (nonatomic, readonly) NSUInteger togglePreviewPanelCallCount;
@property (nonatomic, readonly) NSUInteger reloadContentCallCount;
@property (nonatomic, readonly) NSUInteger keyDownCallCount;
@property (nonatomic, strong) NSEvent *lastKeyDownEvent;
@property (nonatomic, strong) NSWindow *windowOverride;

@end

@interface MMCoverFlowLayerRecordingSubclass : MMCoverFlowLayer

@property (nonatomic, readonly) NSUInteger setNeedsLayoutCallCount;
@property (nonatomic, readonly) NSUInteger layoutSublayersCallCount;
@property (nonatomic, readonly) NSUInteger reloadContentCallCount;

@end
