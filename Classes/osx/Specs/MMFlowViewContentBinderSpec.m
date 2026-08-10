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
//  MMFlowViewContentBinderSpec.m
//
//  Created by Markus Müller on 02.04.14.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowViewContentBinder.h"
#import "MMTestImageItem.h"
#import "TestingContentContainer.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewContentBinderSpec : XCTestCase

@end

@implementation MMFlowViewContentBinderSpec
{
	MMFlowViewContentBinder *_sut;
	NSArrayController *_arrayController;
	TestingContentContainer *_container;
	MMTestContentBinderDelegate *_delegate;
}

static NSString *const arrangedObjectsKey = @"arrangedObjects";
static const NSUInteger numberOfItems = 10;

- (void)setUp
{
	[super setUp];
	_container = [[TestingContentContainer alloc] init];
	NSMutableArray *items = [_container mutableArrayValueForKey:@"items"];
	for (NSUInteger i = 0; i < numberOfItems; ++i) {
		[items addObject:[MMTestImageItem new]];
	}
	_arrayController = [[NSArrayController alloc] init];
	[_arrayController setObjectClass:[MMTestImageItem class]];
	[_arrayController setEditable:YES];
	[_arrayController bind:NSContentArrayBinding toObject:_container withKeyPath:@"items" options:nil];
	_delegate = [[MMTestContentBinderDelegate alloc] init];
}

- (void)tearDown
{
	[_sut stopObservingContent];
	_sut = nil;
	_arrayController = nil;
	_container = nil;
	_delegate = nil;
	[super tearDown];
}

- (void)testThrowsWhenNotCreatedWithDesignatedInitializer
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMFlowViewContentBinder alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithNilContentArrayKeyPath
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:nil]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithNonConformingObjectClass
{
	NSArrayController *badController = [[NSArrayController alloc] init];
	badController.objectClass = [NSObject class];
	XCTAssertThrowsSpecificNamed((_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:badController withContentArrayKeyPath:arrangedObjectsKey]), NSException, NSInternalInconsistencyException);
}

- (void)testInstanceExists
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	XCTAssertNotNil(_sut);
}

- (void)testContentArrayKeyPathFromInitializer
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	XCTAssertEqualObjects(_sut.contentArrayKeyPath, arrangedObjectsKey);
}

- (void)testNoObservedItemsBeforeObserving
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	XCTAssertNil(_sut.observedItems);
}

- (void)testBindingInfo
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	XCTAssertNotNil(_sut.bindingInfo);
	XCTAssertEqualObjects(_sut.bindingInfo[NSObservedObjectKey], _arrayController);
	XCTAssertEqualObjects(_sut.bindingInfo[NSObservedKeyPathKey], arrangedObjectsKey);
	XCTAssertEqualObjects(_sut.bindingInfo[NSOptionsKey], @{});
}

- (void)testObservedItemKeys
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	NSArray *mandatoryKeys = @[NSStringFromSelector(@selector(imageItemRepresentation)),
							   NSStringFromSelector(@selector(imageItemRepresentationType)),
							   NSStringFromSelector(@selector(imageItemUID))];
	for (NSString *key in mandatoryKeys) {
		XCTAssertTrue([_sut.observedItemKeys containsObject:key]);
	}
}

- (void)testStopObservingClearsObservedItems
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	[_sut startObservingContent];
	XCTAssertNotNil(_sut.observedItems);
	[_sut stopObservingContent];
	XCTAssertNil(_sut.observedItems);
}

- (void)testStopObservingWithoutObservingDoesNotThrow
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	XCTAssertNoThrow([_sut stopObservingContent]);
}

- (void)testStartObservingSetsObservedItems
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	_sut.delegate = _delegate;
	[_sut startObservingContent];
	XCTAssertEqual([_sut.observedItems count], numberOfItems);
	XCTAssertEqualObjects(_sut.observedItems, [_arrayController arrangedObjects]);
}

- (void)testAddingItemUpdatesObservedItemsAndNotifiesDelegate
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	_sut.delegate = _delegate;
	[_sut startObservingContent];

	MMTestImageItem *anItem = [_arrayController newObject];
	[_arrayController addObject:anItem];

	XCTAssertTrue([_sut.observedItems containsObject:anItem]);
	XCTAssertGreaterThan(_delegate.contentArrayDidChangeCount, (NSUInteger)0);
}

- (void)testRemovingItemUpdatesObservedItemsAndNotifiesDelegate
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	_sut.delegate = _delegate;
	[_sut startObservingContent];

	NSUInteger removedIndex = 2;
	MMTestImageItem *anItem = [_arrayController arrangedObjects][removedIndex];
	[_arrayController removeObjectAtArrangedObjectIndex:removedIndex];

	XCTAssertFalse([_sut.observedItems containsObject:anItem]);
	XCTAssertGreaterThan(_delegate.contentArrayDidChangeCount, (NSUInteger)0);
}

- (void)testDelegateNotInformedWhenItDoesNotRespondToContentArrayDidChange
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	_sut.delegate = (id<MMFlowViewContentBinderDelegate>)[NSObject new];
	[_sut startObservingContent];

	XCTAssertNoThrow([_arrayController addObject:[_arrayController newObject]]);
}

- (void)testChangingItemPropertiesNotifiesDelegate
{
	_sut = [[MMFlowViewContentBinder alloc] initWithArrayController:_arrayController withContentArrayKeyPath:arrangedObjectsKey];
	_sut.delegate = _delegate;
	[_sut startObservingContent];

	MMTestImageItem *anItem = [_sut.observedItems firstObject];
	NSUInteger before = _delegate.itemChangedCount;
	anItem.imageItemRepresentation = @"test";
	XCTAssertGreaterThan(_delegate.itemChangedCount, before);

	before = _delegate.itemChangedCount;
	anItem.imageItemRepresentationType = @"test";
	XCTAssertGreaterThan(_delegate.itemChangedCount, before);

	before = _delegate.itemChangedCount;
	anItem.imageItemUID = @"test";
	XCTAssertGreaterThan(_delegate.itemChangedCount, before);
}

@end
