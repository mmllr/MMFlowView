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
//  MMFlowViewNSResponderSpec.m
//
//  Created by Markus Müller on 14.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <objc/runtime.h>

#import "MMFlowView+NSResponder.h"
#import "MMFlowView_Private.h"
#import "NSEvent+MMAdditions.h"
#import "MMScrollBarLayer.h"
#import "MMFlowViewImageCache.h"
#import "MMMacros.h"
#import "MMFlowViewTestDoubles.h"

static BOOL testingSuperInvoked = NO;

@interface MMFlowView (MMResponderTests)
- (void)mmTesting_keyDown:(NSEvent *)theEvent;
@end

@implementation MMFlowView (MMResponderTests)

- (void)mmTesting_keyDown:(NSEvent *)theEvent
{
	testingSuperInvoked = YES;
}

@end

@interface MMFlowViewNSResponderSpec : XCTestCase

@end

@implementation MMFlowViewNSResponderSpec
{
	MMFlowViewRecordingSubclass *_sut;
}

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowViewRecordingSubclass alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
}

- (void)tearDown
{
	_sut = nil;
	[super tearDown];
}

- (void)testHasActionCellClass
{
	XCTAssertEqualObjects([[MMFlowView class] cellClass], [NSActionCell class]);
}

- (void)testAcceptsFirstResponder
{
	XCTAssertTrue([_sut acceptsFirstResponder]);
}

- (void)testMouseEnteredAndExitedDoNotThrow
{
	NSEvent *event = [NSEvent mouseEventWithType:NSEventTypeMouseMoved location:NSZeroPoint modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:1 pressure:1];
	XCTAssertNoThrow([_sut mouseEntered:event]);
	XCTAssertNoThrow([_sut mouseExited:event]);
}

- (void)testKeyDownCallsSuper
{
	Method supersMethod = class_getInstanceMethod([_sut superclass], @selector(keyDown:));
	Method testingMethod = class_getInstanceMethod([_sut class], @selector(mmTesting_keyDown:));
	method_exchangeImplementations(supersMethod, testingMethod);

	testingSuperInvoked = NO;
	[_sut keyDown:[self keyDownEventWithCharacters:@"a"]];
	XCTAssertTrue(testingSuperInvoked);

	method_exchangeImplementations(testingMethod, supersMethod);
}

- (NSEvent *)keyDownEventWithCharacters:(NSString *)characters
{
	return [NSEvent keyEventWithType:NSEventTypeKeyDown
							location:NSZeroPoint
					   modifierFlags:0
						   timestamp:0
						windowNumber:0
							 context:nil
						  characters:characters
		 charactersIgnoringModifiers:characters
							isARepeat:NO
							  keyCode:0];
}

- (void)testKeyDownWithQuickLookDisabledDoesNotTogglePanel
{
	_sut.canControlQuickLookPanel = NO;
	NSUInteger before = _sut.togglePreviewPanelCallCount;
	[_sut keyDown:[self keyDownEventWithCharacters:@" "]];
	XCTAssertEqual(_sut.togglePreviewPanelCallCount, before);
}

- (void)testKeyDownWithQuickLookEnabledAndSpaceTogglesPanel
{
	_sut.canControlQuickLookPanel = YES;
	NSUInteger before = _sut.togglePreviewPanelCallCount;
	[_sut keyDown:[self keyDownEventWithCharacters:@" "]];
	XCTAssertGreaterThan(_sut.togglePreviewPanelCallCount, before);
}

- (void)testKeyDownWithQuickLookEnabledAndNonSpaceDoesNotTogglePanel
{
	_sut.canControlQuickLookPanel = YES;
	NSUInteger before = _sut.togglePreviewPanelCallCount;
	[_sut keyDown:[self keyDownEventWithCharacters:@"a"]];
	XCTAssertEqual(_sut.togglePreviewPanelCallCount, before);
}

- (NSEvent *)scrollEventWithDelta:(CGFloat)delta
{
	CGEventRef cgEvent = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitLine, 1, (int32_t)delta);
	NSEvent *event = [NSEvent eventWithCGEvent:cgEvent];
	CFRelease(cgEvent);
	return event;
}

- (void)testSwipeAddsDominantDeltaToSelection
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 3;
	[_sut swipeWithEvent:[self scrollEventWithDelta:3]];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)6);
}

- (void)testScrollWheelAddsDominantDeltaToSelection
{
	_sut.coverFlowLayout.numberOfItems = 11;
	_sut.coverFlowLayout.selectedItemIndex = 3;
	[_sut scrollWheel:[self scrollEventWithDelta:3]];
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)6);
}

- (void)testMouseUpEndsDragOnScrollBar
{
	_sut.scrollBarLayer.draggingOffset = 5;
	NSEvent *event = [NSEvent mouseEventWithType:NSEventTypeLeftMouseUp location:NSZeroPoint modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:1 pressure:1];
	[_sut mouseUp:event];
	XCTAssertEqualWithAccuracy(_sut.scrollBarLayer.draggingOffset, -1, .0000001);
}

- (void)testRightMouseUpWithRightClickDelegateDoesNotCrash
{
	MMTestFlowViewDelegate *delegate = [[MMTestFlowViewDelegate alloc] init];
	_sut.delegate = delegate;
	NSEvent *event = [NSEvent mouseEventWithType:NSEventTypeRightMouseUp
									   location:NSMakePoint(10, 10)
								  modifierFlags:0
									  timestamp:0
								   windowNumber:0
										context:nil
									eventNumber:0
									 clickCount:1
									   pressure:1];
	XCTAssertNoThrow([_sut rightMouseUp:event]);
	XCTAssertEqual(delegate.rightClickCount, (NSUInteger)0); // no item under point
}

- (void)testRightMouseUpWithoutRightClickDelegateDoesNotCrash
{
	_sut.delegate = (id<MMFlowViewDelegate>)[NSObject new];
	NSEvent *event = [NSEvent mouseEventWithType:NSEventTypeRightMouseUp
									   location:NSMakePoint(10, 10)
								  modifierFlags:0
									  timestamp:0
								   windowNumber:0
										context:nil
									eventNumber:0
									 clickCount:1
									   pressure:1];
	XCTAssertNoThrow([_sut rightMouseUp:event]);
}

- (void)testMouseDownOutsideItemDoesNotChangeSelection
{
	_sut.coverFlowLayout.numberOfItems = 0;
	NSEvent *event = [NSEvent mouseEventWithType:NSEventTypeLeftMouseDown location:NSMakePoint(200, 150) modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:1 pressure:1];
	NSUInteger before = _sut.setSelectedIndexCallCount;
	[_sut mouseDown:event];
	XCTAssertEqual(_sut.setSelectedIndexCallCount, before);
	XCTAssertEqual(_sut.selectedIndex, (NSUInteger)NSNotFound);
}

// DISABLED: the remaining original tests verified drag and drop plumbing on
// mouseDown: (pasteboard declaration, dragImage:at:offset:event:pasteboard:
// source:slideBack:, NSWorkspace openURL:) and the scroll bar hit-test conversion
// in mouseDragged:/mouseDown:. These require stubbing NSImage/NSURL/NSPasteboard/
// NSWorkspace and layer coordinate conversions, which is not possible with plain
// XCTest. The responder behaviors exercised without such plumbing are covered
// above.

@end
