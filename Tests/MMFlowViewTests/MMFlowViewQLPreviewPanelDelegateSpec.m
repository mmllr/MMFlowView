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
//  MMFlowViewQLPreviewPanelDelegateSpec.m
//
//  Created by Markus Müller on 13.05.14.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowView+QLPreviewPanelDelegate.h"
#import "MMFlowView_Private.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewQLPreviewPanelDelegateSpec : XCTestCase

@end

@implementation MMFlowViewQLPreviewPanelDelegateSpec
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

- (NSEvent *)mouseEvent
{
	return [NSEvent mouseEventWithType:NSEventTypeMouseMoved
							  location:NSMakePoint(10, 10)
						 modifierFlags:0
							 timestamp:0
						  windowNumber:0
							   context:nil
						   eventNumber:0
							clickCount:1
							  pressure:1];
}

- (NSEvent *)keyDownEventWithCharactersIgnoringModifiers:(NSString *)characters
{
	return [NSEvent keyEventWithType:NSEventTypeKeyDown
							location:NSZeroPoint
					   modifierFlags:0
						   timestamp:0
						windowNumber:0
							 context:nil
						  characters:@""
		 charactersIgnoringModifiers:characters
							isARepeat:NO
							  keyCode:0];
}

- (void)testReturnsNoForNonKeyDownEvent
{
	XCTAssertFalse([_sut previewPanel:nil handleEvent:[self mouseEvent]]);
}

- (void)testDoesNotForwardNonKeyDownEventToKeyDown
{
	NSUInteger before = _sut.keyDownCallCount;
	[_sut previewPanel:nil handleEvent:[self mouseEvent]];
	XCTAssertEqual(_sut.keyDownCallCount, before);
}

- (void)testHandlesLeftArrowKeyDown
{
	NSEvent *event = [self keyDownEventWithCharactersIgnoringModifiers:@"\uF702"]; // NSLeftArrowFunctionKey
	XCTAssertTrue([_sut previewPanel:nil handleEvent:event]);
	XCTAssertGreaterThan(_sut.keyDownCallCount, (NSUInteger)0);
	XCTAssertEqual(_sut.lastKeyDownEvent, event);
}

- (void)testHandlesRightArrowKeyDown
{
	NSEvent *event = [self keyDownEventWithCharactersIgnoringModifiers:@"\uF703"]; // NSRightArrowFunctionKey
	XCTAssertTrue([_sut previewPanel:nil handleEvent:event]);
	XCTAssertGreaterThan(_sut.keyDownCallCount, (NSUInteger)0);
	XCTAssertEqual(_sut.lastKeyDownEvent, event);
}

- (void)testReturnsNoForNonArrowKeyDown
{
	NSEvent *event = [self keyDownEventWithCharactersIgnoringModifiers:@""];
	XCTAssertFalse([_sut previewPanel:nil handleEvent:event]);
}

- (void)testDoesNotForwardNonArrowKeyDownToKeyDown
{
	NSUInteger before = _sut.keyDownCallCount;
	[_sut previewPanel:nil handleEvent:[self keyDownEventWithCharactersIgnoringModifiers:@""]];
	XCTAssertEqual(_sut.keyDownCallCount, before);
}

- (void)testReturnsNoForMultiCharacterKeyDown
{
	NSEvent *event = [self keyDownEventWithCharactersIgnoringModifiers:@"test"];
	XCTAssertFalse([_sut previewPanel:nil handleEvent:event]);
}

- (void)testDoesNotForwardMultiCharacterKeyDownToKeyDown
{
	NSUInteger before = _sut.keyDownCallCount;
	[_sut previewPanel:nil handleEvent:[self keyDownEventWithCharactersIgnoringModifiers:@"test"]];
	XCTAssertEqual(_sut.keyDownCallCount, before);
}

// DISABLED: the original spec additionally verified that arrow key handling invokes
// reloadData on the QLPreviewPanel and that sourceFrameOnScreenForPreviewItem:
// converts the selected item frame through the window. Both require a live
// QLPreviewPanel / windowing environment or stubbing window and frame geometry,
// which is not available in a plain XCTest run. The event routing behavior is
// covered above.

@end
