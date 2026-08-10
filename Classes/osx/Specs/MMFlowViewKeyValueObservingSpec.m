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
//  MMFlowViewKeyValueObservingSpec.m
//
//  Created by Markus Müller on 13.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <objc/runtime.h>

#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+NSKeyValueObserving.h"
#import "NSArray+MMAdditions.h"
#import "MMFlowViewContentBinder.h"
#import "MMTestImageItem.h"
#import "MMCoverFlowLayout.h"

static BOOL testingSuperInvoked = NO;

@interface MMFlowView (MMBindingsTests)
- (void)mmTesting_bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options;
@end

@implementation MMFlowView (MMBindingsTests)

- (void)mmTesting_bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	testingSuperInvoked = YES;
	[self mmTesting_bind:binding toObject:observable withKeyPath:keyPath options:options];
}

- (void)mmTesting_unbind:(NSString *)binding
{
	testingSuperInvoked = YES;
	[self mmTesting_unbind:binding];
}

@end

@interface MMFlowViewKeyValueObservingSpec : XCTestCase

@end

@implementation MMFlowViewKeyValueObservingSpec
{
	MMFlowView *_sut;
	NSArrayController *_arrayController;
	NSArray *_mockedItems;
}

static const NSInteger numberOfItems = 10;

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];

	NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:numberOfItems];
	for (NSInteger i = 0; i < numberOfItems; ++i) {
		[itemArray addObject:[MMTestImageItem new]];
	}
	_mockedItems = [itemArray copy];

	_arrayController = [[NSArrayController alloc] initWithContent:_mockedItems];
	[_arrayController setObjectClass:[MMTestImageItem class]];
	[_arrayController setEditable:NO];
}

- (void)tearDown
{
	[_sut unbind:NSContentArrayBinding];
	_sut = nil;
	_arrayController = nil;
	_mockedItems = nil;
	[super tearDown];
}

- (void)testTearDownObservationsUnbindsStackedAngle
{
	XCTAssertNotNil([_sut.coverFlowLayout infoForBinding:NSStringFromSelector(@selector(stackedAngle))]);
	[_sut tearDownObservations];
	XCTAssertNil([_sut.coverFlowLayout infoForBinding:NSStringFromSelector(@selector(stackedAngle))]);
}

- (void)testTearDownObservationsUnbindsInterItemSpacing
{
	XCTAssertNotNil([_sut.coverFlowLayout infoForBinding:NSStringFromSelector(@selector(interItemSpacing))]);
	[_sut tearDownObservations];
	XCTAssertNil([_sut.coverFlowLayout infoForBinding:NSStringFromSelector(@selector(interItemSpacing))]);
}

- (void)testExposesNSContentArrayBinding
{
	XCTAssertTrue([[_sut exposedBindings] containsObject:NSContentArrayBinding]);
}

- (void)testBindingContentArrayCreatesContentBinder
{
	[_sut bind:NSContentArrayBinding toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
	XCTAssertNotNil(_sut.contentBinder);
	XCTAssertEqualObjects(_sut.contentBinder.delegate, _sut);
}

- (void)testBindingContentArraySetsContentAdapterToArrangedObjects
{
	[_sut bind:NSContentArrayBinding toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
	XCTAssertEqualObjects(_sut.contentAdapter, _mockedItems);
}

- (void)testBindingContentArraySetsNumberOfItems
{
	[_sut bind:NSContentArrayBinding toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
	XCTAssertEqual(_sut.numberOfItems, (NSUInteger)[_mockedItems count]);
}

- (void)testBindingToSecondArrayControllerRebinds
{
	NSArrayController *otherController = [[NSArrayController alloc] initWithContent:@[[MMTestImageItem new]]];
	[otherController setObjectClass:[MMTestImageItem class]];
	[otherController setEditable:NO];

	[_sut bind:NSContentArrayBinding toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
	[_sut bind:NSContentArrayBinding toObject:otherController withKeyPath:@"arrangedObjects" options:nil];

	XCTAssertEqualObjects([_sut infoForBinding:NSContentArrayBinding][NSObservedObjectKey], otherController);
}

- (void)testContentArrayBindingInfo
{
	[_sut bind:NSContentArrayBinding toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
	NSDictionary *contentArrayBinding = [_sut infoForBinding:NSContentArrayBinding];
	XCTAssertNotNil(contentArrayBinding);
	XCTAssertEqualObjects(contentArrayBinding[NSObservedObjectKey], _arrayController);
	XCTAssertEqualObjects(contentArrayBinding[NSObservedKeyPathKey], @"arrangedObjects");
}

- (void)testSettingSelectionUpdatesArrayController
{
	[_sut bind:NSContentArrayBinding toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
	_sut.selectedIndex = 5;
	XCTAssertEqual([_arrayController selectionIndex], (NSInteger)5);
}

- (void)testBindingToNonArrayControllerRaises
{
	NSDictionary *dict = @{@"arrangedObjects": @[@1, @2]};
	XCTAssertThrowsSpecificNamed(([_sut bind:NSContentArrayBinding toObject:dict withKeyPath:@"arrangedObjects" options:nil]), NSException, NSInternalInconsistencyException);
}

- (void)testBindingOtherPropertyCallsSuper
{
	NSDictionary *observedDict = @{@"angle": @10};
	Method supersBindMethod = class_getInstanceMethod([_sut superclass], @selector(bind:toObject:withKeyPath:options:));
	Method testingBindMethod = class_getInstanceMethod([_sut class], @selector(mmTesting_bind:toObject:withKeyPath:options:));
	method_exchangeImplementations(supersBindMethod, testingBindMethod);

	testingSuperInvoked = NO;
	[_sut bind:@"stackedAngle" toObject:observedDict withKeyPath:@"angle" options:nil];

	XCTAssertTrue(testingSuperInvoked);
	NSDictionary *bindingInfo = [_sut infoForBinding:@"stackedAngle"];
	XCTAssertNotNil(bindingInfo);
	XCTAssertEqualObjects(bindingInfo[NSObservedObjectKey], observedDict);
	XCTAssertEqualObjects(bindingInfo[NSObservedKeyPathKey], @"angle");

	method_exchangeImplementations(testingBindMethod, supersBindMethod);
}

- (void)testUnbindClearsContentArrayBinding
{
	[_sut bind:NSContentArrayBinding toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
	[_sut unbind:NSContentArrayBinding];
	XCTAssertNil([_sut infoForBinding:NSContentArrayBinding]);
	XCTAssertNil(_sut.contentBinder);
}

- (void)testUnbindOtherPropertyCallsSuper
{
	Method supersUnbindMethod = class_getInstanceMethod([_sut superclass], @selector(unbind:));
	Method testingUnbindMethod = class_getInstanceMethod([_sut class], @selector(mmTesting_unbind:));
	method_exchangeImplementations(supersUnbindMethod, testingUnbindMethod);

	testingSuperInvoked = NO;
	[_sut unbind:@"stackedAngle"];
	XCTAssertTrue(testingSuperInvoked);

	method_exchangeImplementations(testingUnbindMethod, supersUnbindMethod);
}

@end
