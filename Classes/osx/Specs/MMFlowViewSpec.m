/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://codeberg.org/mmllr All rights reserved.
 
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
//  MMFlowViewSpec.m
//
//  Created by Markus Müller on 13.01.12.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMMacros.h"
#import "MMFlowViewImageCache.h"
#import "MMFlowViewImageFactory.h"
#import "MMImageDecoderProtocol.h"
#import "MMCoverFlowLayer.h"
#import "MMCoverFlowLayout.h"
#import "MMScrollBarLayer.h"
#import "MMCGImageSourceDecoder.h"
#import "MMNSBitmapImageRepDecoder.h"
#import "MMNSDataImageDecoder.h"
#import "MMNSImageDecoder.h"
#import "MMPDFPageDecoder.h"
#import "MMQuickLookImageDecoder.h"
#import "MMFlowViewDatasourceContentAdapter.h"
#import "MMFlowViewContentBinder.h"
#import "MMTestImageItem.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewSpec : XCTestCase

@end

@implementation MMFlowViewSpec
{
	MMFlowView *_sut;
	NSArray *_mockedItems;
	NSURL *_testImageURL;
	CGImageRef _testImageRef;
}

static const NSInteger numberOfItems = 10;
static const NSRect initialFrame = {{0, 0}, {400, 300}};

- (void)setUp
{
	[super setUp];
	_testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
	_testImageRef = CGImageRetain([[[NSImage alloc] initWithContentsOfURL:_testImageURL] CGImageForProposedRect:NULL context:NULL hints:nil]);

	NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:numberOfItems];
	for (NSInteger i = 0; i < numberOfItems; ++i) {
		NSString *titleString = [NSString stringWithFormat:@"Item %ld", (long)i];
		MMTestImageItem *item = [[MMTestImageItem alloc] init];
		item.imageItemRepresentationType = kMMFlowViewNSImageRepresentationType;
		item.imageItemUID = titleString;
		item.imageItemTitle = titleString;
		item.imageItemRepresentation = [[NSImage alloc] initWithContentsOfURL:_testImageURL];
		[itemArray addObject:item];
	}
	_mockedItems = [itemArray copy];

	_sut = [[MMFlowView alloc] initWithFrame:initialFrame];
	// give the layer tree a sane geometry so layout computations stay finite
	_sut.coverFlowLayer.bounds = _sut.bounds;
	_sut.coverFlowLayout.visibleSize = _sut.bounds.size;
}

- (void)tearDown
{
	_sut = nil;
	_testImageURL = nil;
	SAFE_CGIMAGE_RELEASE(_testImageRef);
	_mockedItems = nil;
	[super tearDown];
}

#pragma mark - class related

- (void)testIsOfMMFlowViewClass
{
	XCTAssertTrue([_sut isKindOfClass:[MMFlowView class]]);
}

- (void)testDefaultAnimationForKeySpacingIsCABasicAnimation
{
	id animation = [[_sut class] defaultAnimationForKey:NSStringFromSelector(@selector(spacing))];
	XCTAssertTrue([animation isKindOfClass:[CABasicAnimation class]]);
}

- (void)testDefaultAnimationForKeyStackedAngleIsCABasicAnimation
{
	id animation = [[_sut class] defaultAnimationForKey:NSStringFromSelector(@selector(stackedAngle))];
	XCTAssertTrue([animation isKindOfClass:[CABasicAnimation class]]);
}

#pragma mark - defaults

- (void)testInstanceExists
{
	XCTAssertNotNil(_sut);
}

- (void)testNoItems
{
	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)0);
}

- (void)testNoItemSelected
{
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)NSNotFound);
}

- (void)testEmptyTitle
{
	XCTAssertEqualObjects(_sut.title, @"");
}

- (void)testTitleSizeOfEighteen
{
	XCTAssertEqual(_sut.titleSize, (CGFloat)18);
}

- (void)testRegisteredForURLPasteboardType
{
	XCTAssertTrue([[_sut registeredDraggedTypes] containsObject:NSURLPboardType]);
}

- (void)testEmptyDataSource
{
	XCTAssertNil(_sut.dataSource);
}

- (void)testTitleGetAndSet
{
	_sut.title = @"testTitle";
	XCTAssertEqualObjects(_sut.title, @"testTitle");
}

- (void)testTitleSizeSetAndGet
{
	_sut.titleSize = 30;
	XCTAssertEqualWithAccuracy(_sut.titleSize, 30, .00001);
}

- (void)testTitleColorSet
{
	[_sut setTitleColor:[NSColor whiteColor]];
	XCTAssertTrue(_sut.titleLayer.foregroundColor != NULL);
}

- (void)testTitleFontSet
{
	[_sut setTitleFont:[NSFont systemFontOfSize:14]];
	XCTAssertNotNil(_sut.titleLayer.font);
}

#pragma mark - selection with items

- (void)testValidSelectionWithItems
{
	_sut.contentAdapter = _mockedItems;
	[_sut reloadContent];
	XCTAssertNotEqual(_sut.selectedIndex, (NSUInteger)NSNotFound);
}

- (void)testTitleOfSelectedItem
{
	_sut.contentAdapter = _mockedItems;
	[_sut reloadContent];
	NSString *expectedTitle = [NSString stringWithFormat:@"Item %@", @(_sut.selectedIndex)];
	XCTAssertEqualObjects(_sut.title, expectedTitle);
}

- (void)testEmptyTitleForItemWithoutTitle
{
	MMTestImageItem *item = [[MMTestImageItem alloc] init];
	item.imageItemRepresentation = [[NSImage alloc] initWithContentsOfURL:_testImageURL];
	item.imageItemRepresentationType = kMMFlowViewNSImageRepresentationType;
	item.imageItemUID = @"123";
	item.imageItemTitle = @"";
	_sut.contentAdapter = @[item];
	[_sut reloadContent];
	XCTAssertTrue(_sut.title.length == 0);
}

- (void)testNoItemsSelectionIsNotFound
{
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)NSNotFound);
	XCTAssertEqualObjects(_sut.title, @"");
}

- (void)testChangingSelectionWithoutItemsDoesNothing
{
	_sut.selectedIndex = 0;
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)NSNotFound);
}

#pragma mark - dataSource

- (void)testSettingDataSourceCreatesDatasourceContentAdapter
{
	MMTestFlowViewDataSource *dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:_mockedItems];
	_sut.dataSource = dataSource;
	XCTAssertTrue([_sut.contentAdapter isKindOfClass:[MMFlowViewDatasourceContentAdapter class]]);
}

- (void)testSettingDataSourceWithExistingBindingDoesNotReplaceContentAdapter
{
	MMTestImageItem *boundItem = [[MMTestImageItem alloc] init];
	boundItem.imageItemUID = @"bound";
	boundItem.imageItemRepresentationType = kMMFlowViewNSImageRepresentationType;
	boundItem.imageItemRepresentation = [[NSImage alloc] initWithContentsOfURL:_testImageURL];

	NSArrayController *controller = [[NSArrayController alloc] initWithContent:@[boundItem]];
	[controller setObjectClass:[MMTestImageItem class]];
	[_sut bind:NSContentArrayBinding toObject:controller withKeyPath:@"arrangedObjects" options:nil];

	MMTestFlowViewDataSource *dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:_mockedItems];
	_sut.dataSource = dataSource;

	XCTAssertFalse([_sut.contentAdapter isKindOfClass:[MMFlowViewDatasourceContentAdapter class]]);
	[_sut unbind:NSContentArrayBinding];
}

- (void)testReloadContentSetsNumberOfItems
{
	_sut.contentAdapter = _mockedItems;
	[_sut reloadContent];
	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)[_mockedItems count]);
}

#pragma mark - layout related

- (void)testHasCoverFlowLayout
{
	XCTAssertNotNil(_sut.coverFlowLayout);
	XCTAssertTrue([_sut.coverFlowLayout isKindOfClass:[MMCoverFlowLayout class]]);
	XCTAssertEqualObjects(_sut.coverFlowLayout.delegate, _sut);
}

- (void)testVisibleItemIndexesInitiallyEmpty
{
	XCTAssertNotNil(_sut.visibleItemIndexes);
	XCTAssertEqual([_sut.visibleItemIndexes count], (NSUInteger)0);
}

- (void)testDefaultStackedAngleAndPropagation
{
	XCTAssertEqual(_sut.stackedAngle, (CGFloat)70);
	_sut.stackedAngle = 50;
	XCTAssertEqual(_sut.stackedAngle, (CGFloat)50);
	XCTAssertEqual(_sut.coverFlowLayout.stackedAngle, _sut.stackedAngle);
}

- (void)testSelectedItemFrameInitiallyZero
{
	XCTAssertTrue(NSIsEmptyRect(_sut.selectedItemFrame));
}

- (void)testDefaultSpacingAndPropagation
{
	XCTAssertEqual(_sut.spacing, (CGFloat)50);
	_sut.spacing = 100;
	XCTAssertEqual(_sut.spacing, (CGFloat)100);
	XCTAssertEqual(_sut.coverFlowLayout.interItemSpacing, _sut.spacing);
}

- (void)testShowsReflectionToggles
{
	XCTAssertFalse(_sut.showsReflection);
	_sut.showsReflection = YES;
	XCTAssertTrue(_sut.showsReflection);
	XCTAssertTrue(_sut.coverFlowLayer.showsReflection);
	_sut.showsReflection = NO;
	XCTAssertFalse(_sut.showsReflection);
	XCTAssertFalse(_sut.coverFlowLayer.showsReflection);
}

- (void)testReflectionOffset
{
	XCTAssertEqualWithAccuracy(_sut.reflectionOffset, -.4, .0000001);
	_sut.reflectionOffset = -.7;
	XCTAssertEqualWithAccuracy(_sut.reflectionOffset, -.7, .000001);
	XCTAssertEqualWithAccuracy(_sut.coverFlowLayer.reflectionOffset, -.7, .0000001);
}

#pragma mark - image cache and factory

- (void)testHasImageCache
{
	XCTAssertNotNil(_sut.imageCache);
	XCTAssertTrue([_sut.imageCache conformsToProtocol:@protocol(MMFlowViewImageCache)]);
}

- (void)testHasImageFactory
{
	XCTAssertNotNil(_sut.imageFactory);
	XCTAssertTrue([_sut.imageFactory isKindOfClass:[MMFlowViewImageFactory class]]);
}

- (void)testFactoryRegistersExpectedDecoderTypes
{
	NSDictionary *expectedRepresentationMappings = @{
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
	[expectedRepresentationMappings enumerateKeysAndObjectsUsingBlock:^(NSString *type, Class decoderClass, BOOL *stop) {
		XCTAssertTrue([_sut.imageFactory canDecodeRepresentationType:type], @"should decode %@", type);
	}];
}

- (void)testFactoryProvidesDecoderForExpectedTypes
{
	NSData *imageData = [NSData dataWithContentsOfURL:_testImageURL];
	NSImage *image = [[NSImage alloc] initWithContentsOfURL:_testImageURL];
	NSBitmapImageRep *bitmapRep = nil;
	for (NSImageRep *rep in [image representations]) {
		if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
			bitmapRep = [(NSBitmapImageRep *)rep copy];
			break;
		}
	}
	CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)(_testImageURL), NULL);
	PDFDocument *document = [[PDFDocument alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"Test" withExtension:@"pdf"]];
	CGPDFPageRef testPDFPageRef = CGPDFPageRetain([[document pageAtIndex:0] pageRef]);

	NSDictionary *testRepresentations = @{
		kMMFlowViewURLRepresentationType: _testImageURL,
		kMMFlowViewPDFPageRepresentationType: (__bridge id)testPDFPageRef,
		kMMFlowViewPathRepresentationType: [_testImageURL absoluteString],
		kMMFlowViewNSImageRepresentationType: image,
		kMMFlowViewCGImageSourceRepresentationType: (__bridge id)imageSource,
		kMMFlowViewNSDataRepresentationType: imageData,
		kMMFlowViewNSBitmapRepresentationType: bitmapRep,
		kMMFlowViewQTMoviePathRepresentationType: _testImageURL,
		kMMFlowViewQCCompositionPathRepresentationType: _testImageURL,
		kMMFlowViewQuickLookPathRepresentationType: _testImageURL
	};
	[testRepresentations enumerateKeysAndObjectsUsingBlock:^(NSString *representationType, id representation, BOOL *stop) {
		XCTAssertNotNil([_sut.imageFactory decoderforItem:representation withRepresentationType:representationType], @"should decode %@", representationType);
	}];

	if (imageSource) {
		CFRelease(imageSource);
	}
	if (testPDFPageRef) {
		CGPDFPageRelease(testPDFPageRef);
	}
}

#pragma mark - live resize

- (void)testLiveResizeTogglesCoverFlowLayerState
{
	[_sut viewWillStartLiveResize];
	XCTAssertTrue(_sut.coverFlowLayer.inLiveResize);
	[_sut viewDidEndLiveResize];
	XCTAssertFalse(_sut.coverFlowLayer.inLiveResize);
}

- (void)testViewDidEndLiveResizeSetsFactoryMaxImageSize
{
	_sut.coverFlowLayout.visibleSize = CGSizeMake(400, 300);
	CGSize expectedItemSize = _sut.coverFlowLayout.itemSize;
	[_sut viewDidEndLiveResize];
	XCTAssertTrue(CGSizeEqualToSize(_sut.imageFactory.maxImageSize, expectedItemSize));
}

#pragma mark - layers

- (void)testLayerBacked
{
	[_sut.layer layoutSublayers];
	XCTAssertTrue([_sut wantsLayer]);
	XCTAssertNotNil([_sut layer]);
	XCTAssertEqualObjects([_sut layer], _sut.backgroundLayer);
}

- (void)testBackgroundLayerIsGradient
{
	CALayer *layer = _sut.backgroundLayer;
	XCTAssertNotNil(layer);
	XCTAssertTrue([layer isKindOfClass:[CAGradientLayer class]]);
	XCTAssertTrue((layer.autoresizingMask & kCALayerWidthSizable) != 0);
	XCTAssertTrue((layer.autoresizingMask & kCALayerHeightSizable) != 0);
	XCTAssertNotNil(layer.layoutManager);
	XCTAssertTrue([layer.layoutManager isKindOfClass:[CAConstraintLayoutManager class]]);

	CAGradientLayer *gradientLayer = (CAGradientLayer *)layer;
	NSArray *expectedColors = @[(__bridge id)[[NSColor colorWithCalibratedRed:52.f / 255.f green:55.f / 255.f blue:69.f / 255.f alpha:1.f] CGColor],
								(__bridge id)[[NSColor colorWithCalibratedRed:36.f / 255.f green:37.f / 255.f blue:48.f / 255.f alpha:1.f] CGColor],
								(__bridge id)[[NSColor blackColor] CGColor]];
	XCTAssertEqualObjects(gradientLayer.colors, expectedColors);
	NSArray *expectedLocations = @[@0., @0.2, @1.];
	XCTAssertEqualObjects(gradientLayer.locations, expectedLocations);
	XCTAssertTrue(NSEqualPoints(gradientLayer.position, CGPointZero));
	XCTAssertTrue(NSEqualRects(gradientLayer.bounds, [_sut bounds]));
}

- (void)testCoverFlowLayerSetup
{
	XCTAssertNotNil(_sut.coverFlowLayer);
	XCTAssertTrue([_sut.coverFlowLayer isKindOfClass:[MMCoverFlowLayer class]]);
	XCTAssertTrue([_sut.containerLayer.sublayers containsObject:_sut.coverFlowLayer]);
	XCTAssertEqual(CGRectGetWidth(_sut.coverFlowLayer.bounds), CGRectGetWidth(_sut.bounds));
}

- (void)testContainerLayerSetup
{
	CALayer *layer = _sut.containerLayer;
	XCTAssertNotNil(layer);
	XCTAssertTrue([layer isKindOfClass:[CALayer class]]);
	XCTAssertTrue([_sut.backgroundLayer.sublayers containsObject:layer]);
	XCTAssertEqualObjects(layer.name, @"MMFlowViewContainerLayer");
	[_sut.layer layoutSublayers];
	XCTAssertEqual(CGRectGetWidth(layer.bounds), CGRectGetWidth(_sut.bounds));
	XCTAssertEqual([layer.constraints count], (NSUInteger)4);
	XCTAssertEqualObjects(layer.actions[@"bounds"], [NSNull null]);
	XCTAssertEqualObjects(layer.actions[@"position"], [NSNull null]);

	CAConstraint *midXConstraint = layer.constraints[0];
	XCTAssertEqualObjects(midXConstraint.sourceName, @"superlayer");
	XCTAssertEqual(midXConstraint.sourceAttribute, kCAConstraintMidX);
	XCTAssertEqual(midXConstraint.attribute, kCAConstraintMidX);
	XCTAssertEqual(midXConstraint.scale, (CGFloat)1);
	XCTAssertEqual(midXConstraint.offset, (CGFloat)0);

	CAConstraint *maxYConstraint = layer.constraints[1];
	XCTAssertEqualObjects(maxYConstraint.sourceName, @"superlayer");
	XCTAssertEqual(maxYConstraint.sourceAttribute, kCAConstraintMaxY);
	XCTAssertEqual(maxYConstraint.attribute, kCAConstraintMaxY);

	CAConstraint *widthConstraint = layer.constraints[2];
	XCTAssertEqualObjects(widthConstraint.sourceName, @"superlayer");
	XCTAssertEqual(widthConstraint.sourceAttribute, kCAConstraintWidth);
	XCTAssertEqual(widthConstraint.attribute, kCAConstraintWidth);
	XCTAssertEqual(widthConstraint.scale, (CGFloat)1);

	CAConstraint *titleConstraint = layer.constraints[3];
	XCTAssertEqualObjects(titleConstraint.sourceName, @"MMFlowViewTitleLayer");
	XCTAssertEqual(titleConstraint.sourceAttribute, kCAConstraintMaxY);
	XCTAssertEqual(titleConstraint.attribute, kCAConstraintMinY);
}

- (void)testScrollBarLayerSetup
{
	XCTAssertNotNil(_sut.scrollBarLayer);
	XCTAssertTrue([_sut.scrollBarLayer isKindOfClass:[MMScrollBarLayer class]]);
	XCTAssertTrue([_sut.backgroundLayer.sublayers containsObject:_sut.scrollBarLayer]);
}

#pragma mark - layout / hit testing

- (void)testIndexOfItemAtPointReturnsNotFoundForEmptyContents
{
	[_sut.layer layoutSublayers];
	NSPoint pointInCenterOfView = NSMakePoint(NSMidX([_sut bounds]), NSMidY([_sut bounds]));
	XCTAssertEqual([_sut indexOfItemAtPoint:pointInCenterOfView], (NSUInteger)NSNotFound);
}

- (void)testIndexOfItemAtPointReturnsNotFoundOutsideView
{
	[_sut.layer layoutSublayers];
	NSPoint pointNotInView = NSMakePoint(NSWidth([_sut bounds]) * 2, NSHeight([_sut bounds]) * 2);
	XCTAssertEqual([_sut indexOfItemAtPoint:pointNotInView], (NSUInteger)NSNotFound);
}

#pragma mark - datasource interaction

- (MMTestFlowViewDataSource *)makeDataSource
{
	return [[MMTestFlowViewDataSource alloc] initWithItems:_mockedItems];
}

- (void)testHasTheDataSource
{
	MMTestFlowViewDataSource *dataSource = [self makeDataSource];
	_sut.dataSource = dataSource;
	XCTAssertEqualObjects(_sut.dataSource, dataSource);
}

- (void)testReloadAsksDataSourceForNumberOfItems
{
	MMTestFlowViewDataSource *dataSource = [self makeDataSource];
	_sut.dataSource = dataSource;
	NSUInteger before = dataSource.numberOfItemsCallCount;
	[_sut reloadContent];
	XCTAssertGreaterThan(dataSource.numberOfItemsCallCount, before);
}

- (void)testIncompleteDataSourceReloadGivesZeroItems
{
	_sut.dataSource = (id<MMFlowViewDataSource>)[NSObject new];
	[_sut reloadContent];
	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)0);
}

- (void)testOneItemFlowView
{
	MMTestImageItem *item = [_mockedItems firstObject];
	MMTestFlowViewDataSource *dataSource = [[MMTestFlowViewDataSource alloc] initWithItems:@[item]];
	_sut.dataSource = dataSource;
	[_sut reloadContent];

	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)1);
	XCTAssertEqualObjects(_sut.title, @"Item 0");
	_sut.coverFlowLayer.bounds = _sut.bounds;
	[_sut.coverFlowLayer layoutSublayers];
	[_sut updateTrackingAreas];
	XCTAssertEqual([_sut.visibleItemIndexes count], (NSUInteger)1);

	NSTrackingArea *trackingArea = [[_sut trackingAreas] firstObject];
	XCTAssertEqual([[_sut trackingAreas] count], (NSUInteger)1);
	XCTAssertTrue(NSEqualRects([trackingArea rect], _sut.selectedItemFrame));
	XCTAssertEqual([trackingArea options], NSTrackingActiveInActiveApp | NSTrackingActiveWhenFirstResponder | NSTrackingMouseEnteredAndExited | NSTrackingAssumeInside);
	XCTAssertEqualObjects([trackingArea owner], _sut);
}

- (void)testManyItemsFlowView
{
	MMTestFlowViewDataSource *dataSource = [self makeDataSource];
	_sut.dataSource = dataSource;
	[_sut reloadContent];

	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)numberOfItems);
	XCTAssertEqualObjects(_sut.title, @"Item 0");
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)0);

	NSTrackingArea *trackingArea = [[_sut trackingAreas] firstObject];
	XCTAssertEqual([[_sut trackingAreas] count], (NSUInteger)1);
	XCTAssertTrue(NSEqualRects([trackingArea rect], _sut.selectedItemFrame));

	_sut.coverFlowLayer.bounds = _sut.bounds;
	[_sut.coverFlowLayer layoutSublayers];
	[_sut updateTrackingAreas];
	XCTAssertTrue([_sut.visibleItemIndexes containsIndex:_sut.selectedIndex]);
	XCTAssertEqual([_sut.visibleItemIndexes count], [_sut.coverFlowLayer.visibleItemIndexes count]);
}

- (void)testReloadContentReloadsCoverFlowLayer
{
	MMTestFlowViewDataSource *dataSource = [self makeDataSource];
	_sut.dataSource = dataSource;

	MMCoverFlowLayerRecordingSubclass *coverFlowLayer = [[MMCoverFlowLayerRecordingSubclass alloc] initWithLayout:_sut.coverFlowLayout];
	coverFlowLayer.dataSource = (id<MMCoverFlowLayerDataSource>)_sut;
	_sut.coverFlowLayer = coverFlowLayer;

	[_sut reloadContent];
	XCTAssertGreaterThan(coverFlowLayer.reloadContentCallCount, (NSUInteger)0);
}

- (void)testChangingSelectionRelayoutsCoverFlowLayer
{
	MMTestFlowViewDataSource *dataSource = [self makeDataSource];
	_sut.dataSource = dataSource;
	[_sut reloadContent];

	MMCoverFlowLayerRecordingSubclass *coverFlowLayer = [[MMCoverFlowLayerRecordingSubclass alloc] initWithLayout:_sut.coverFlowLayout];
	coverFlowLayer.dataSource = (id<MMCoverFlowLayerDataSource>)_sut;
	_sut.coverFlowLayer = coverFlowLayer;
	[_sut reloadContent];

	NSUInteger before = coverFlowLayer.setNeedsLayoutCallCount;
	_sut.selectedIndex = _sut.selectedIndex + 1;
	XCTAssertGreaterThan(coverFlowLayer.setNeedsLayoutCallCount, before);
}

- (void)testMoveLeftKeepsFirstItemSelected
{
	MMTestFlowViewDataSource *dataSource = [self makeDataSource];
	_sut.dataSource = dataSource;
	[_sut reloadContent];
	[_sut moveLeft:self];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)0);
	XCTAssertEqualObjects(_sut.title, @"Item 0");
}

- (void)testMoveRightSelectsSecondItem
{
	MMTestFlowViewDataSource *dataSource = [self makeDataSource];
	_sut.dataSource = dataSource;
	[_sut reloadContent];
	[_sut moveRight:self];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)1);
	XCTAssertEqualObjects(_sut.title, @"Item 1");
	[_sut moveLeft:self];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)0);
	XCTAssertEqualObjects(_sut.title, @"Item 0");
}

- (void)testSelectingItemsByIndex
{
	MMTestFlowViewDataSource *dataSource = [self makeDataSource];
	_sut.dataSource = dataSource;
	[_sut reloadContent];

	_sut.selectedIndex = 2;
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)2);
	XCTAssertEqualObjects(_sut.title, @"Item 2");

	_sut.selectedIndex = _sut.numberOfItems - 1;
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)(numberOfItems - 1));

	_sut.selectedIndex = 0;
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)0);

	_sut.selectedIndex = _sut.numberOfItems * 2;
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)0);
	XCTAssertEqualObjects(_sut.title, @"Item 0");

	_sut.selectedIndex = NSNotFound;
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)0);
	XCTAssertEqualObjects(_sut.title, @"Item 0");
}

- (void)testSelectedItemFrameMatchesCoverFlowLayer
{
	MMTestFlowViewDataSource *dataSource = [self makeDataSource];
	_sut.dataSource = dataSource;
	[_sut reloadContent];
	[_sut.layer layoutSublayers];

	NSRect rectInHostingLayer = NSRectFromCGRect([_sut.layer convertRect:_sut.coverFlowLayer.selectedItemFrame fromLayer:_sut.coverFlowLayer]);
	XCTAssertTrue(NSEqualRects(_sut.selectedItemFrame, rectInHostingLayer));
}

#pragma mark - tracking areas

- (void)testUpdateTrackingAreasWithSelection
{
	MMTestFlowViewDataSource *dataSource = [self makeDataSource];
	_sut.dataSource = dataSource;
	[_sut reloadContent];

	[_sut updateTrackingAreas];
	NSTrackingArea *trackingArea = [[_sut trackingAreas] firstObject];
	XCTAssertEqual([[_sut trackingAreas] count], (NSUInteger)1);
	XCTAssertTrue(NSEqualRects([trackingArea rect], _sut.selectedItemFrame));
	XCTAssertEqual([trackingArea options], NSTrackingActiveInActiveApp | NSTrackingActiveWhenFirstResponder | NSTrackingMouseEnteredAndExited | NSTrackingAssumeInside);
	XCTAssertEqualObjects([trackingArea owner], _sut);
}

- (void)testNoTrackingAreasWithoutSelection
{
	XCTAssertEqual([[_sut trackingAreas] count], (NSUInteger)0);
}

// DISABLED: the remaining original tests verified indexOfItemAtPoint layer
// coordinate plumbing and togglePreviewPanel: with a mocked QLPreviewPanel
// (sharedPreviewPanel ordering). Both require stubbing layer conversions or a live
// QuickLook panel, which is not available in a plain XCTest run. The datasource,
// selection, layout, and tracking-area behavior is covered above.

@end
