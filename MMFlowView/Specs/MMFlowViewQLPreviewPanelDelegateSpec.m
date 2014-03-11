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
//  MMFlowViewQLPreviewPanelDelegateSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView+QLPreviewPanelDelegate.h"
#import "MMFlowView_Private.h"

SPEC_BEGIN(MMFlowViewQLPreviewPanelDelegateSpec)

describe(@"MMFlowView+QLPreviewPanelDelegate", ^{
	__block MMFlowView *sut = nil;
	__block QLPreviewPanel *mockedPanel = nil;

	beforeAll(^{
		mockedPanel = [QLPreviewPanel nullMock];
	});
	afterAll(^{
		mockedPanel = nil;
	});
	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	});
	afterEach(^{
		sut = nil;
	});
	context(@"previewPanel:handleEvent:", ^{
		__block NSEvent *mockedEvent = nil;
		
		beforeEach(^{
			mockedEvent = [NSEvent nullMock];
		});
		it(@"should return NO when event is not a NSKeyDown event", ^{
			[[theValue([sut previewPanel:mockedPanel handleEvent:mockedEvent]) should] beNo];
		});
		context(@"not a NSKeyDown event", ^{
			it(@"should not forward the event to its keyDown: method", ^{
				[[sut shouldNot] receive:@selector(keyDown:) withArguments:mockedEvent];
				[sut previewPanel:mockedPanel handleEvent:mockedEvent];
			});
			it(@"should return NO", ^{
				[[theValue([sut previewPanel:mockedPanel handleEvent:mockedEvent]) should] beNo];
			});
		});
		context(@"NSKeyDown event", ^{
			beforeEach(^{
				[mockedEvent stub:@selector(type) andReturn:theValue(NSKeyDown)];
			});
			context(@"left arrow pressed", ^{
				beforeEach(^{
					unichar leftArrow = NSLeftArrowFunctionKey;
					NSString *leftArrowString = [NSString stringWithCharacters:&leftArrow length:1];
					[mockedEvent stub:@selector(charactersIgnoringModifiers) andReturn:leftArrowString];
				});
				it(@"should invoke reload on the panel", ^{
					[[mockedPanel should] receive:@selector(reloadData)];
					[sut previewPanel:mockedPanel handleEvent:mockedEvent];
				});
				it(@"should return YES", ^{
					[[theValue([sut previewPanel:mockedPanel handleEvent:mockedEvent]) should] beYes];
				});
				it(@"should forward the event to its keyDown: method", ^{
					[[sut should] receive:@selector(keyDown:) withArguments:mockedEvent];
					[sut previewPanel:mockedPanel handleEvent:mockedEvent];
				});
			});
			context(@"right arrow pressed", ^{
				beforeEach(^{
					unichar rightArrow = NSRightArrowFunctionKey;
					NSString *rightArrowString = [NSString stringWithCharacters:&rightArrow length:1];
					[mockedEvent stub:@selector(charactersIgnoringModifiers) andReturn:rightArrowString];
				});
				it(@"should invoke reload on the panel", ^{
					[[mockedPanel should] receive:@selector(reloadData)];
					[sut previewPanel:mockedPanel handleEvent:mockedEvent];
				});
				it(@"should return YES", ^{
					[[theValue([sut previewPanel:mockedPanel handleEvent:mockedEvent]) should] beYes];
				});
				it(@"should forward the event to its keyDown: method", ^{
					[[sut should] receive:@selector(keyDown:) withArguments:mockedEvent];
					[sut previewPanel:mockedPanel handleEvent:mockedEvent];
				});
			});
			context(@"no arrows pressed", ^{
				beforeEach(^{
					[mockedEvent stub:@selector(charactersIgnoringModifiers) andReturn:@""];
				});
				it(@"should not invoke reload on the panel", ^{
					[[mockedPanel shouldNot] receive:@selector(reloadData)];
					[sut previewPanel:mockedPanel handleEvent:mockedEvent];
				});
				it(@"should return NO", ^{
					[[theValue([sut previewPanel:mockedPanel handleEvent:mockedEvent]) should] beNo];
				});
				it(@"should not forward the event to its keyDown: method", ^{
					[[sut shouldNot] receive:@selector(keyDown:) withArguments:mockedEvent];
					[sut previewPanel:mockedPanel handleEvent:mockedEvent];
				});
			});
			context(@"more than one key pressed", ^{
				beforeEach(^{
					[mockedEvent stub:@selector(charactersIgnoringModifiers) andReturn:@"test"];
				});
				it(@"should not invoke reload on the panel", ^{
					[[mockedPanel shouldNot] receive:@selector(reloadData)];
					[sut previewPanel:mockedPanel handleEvent:mockedEvent];
				});
				it(@"should return NO", ^{
					[[theValue([sut previewPanel:mockedPanel handleEvent:mockedEvent]) should] beNo];
				});
				it(@"should not forward the event to its keyDown: method", ^{
					[[sut shouldNot] receive:@selector(keyDown:) withArguments:mockedEvent];
					[sut previewPanel:mockedPanel handleEvent:mockedEvent];
				});
			});
		});
	});
	context(@"previewPanel:sourceFrameOnScreenForPreviewItem:", ^{
		NSRect expectedRect = NSMakeRect(30, 30, 400, 400);
		NSRect selectedItemRect = NSMakeRect(10, 10, 400, 400);
		__block NSWindow *mockedWindow = nil;
		
		beforeEach(^{
			mockedWindow = [NSWindow mock];
			[mockedWindow stub:@selector(convertRectToScreen:) andReturn:theValue(expectedRect)];
			[sut stub:@selector(selectedItemFrame) andReturn:theValue(selectedItemRect)];
			[sut stub:@selector(window) andReturn:mockedWindow];
		});
		it(@"should convert the selectedItemRect to window coordinates", ^{
			[[sut should] receive:@selector(convertRect:toView:) withArguments:theValue(selectedItemRect), [KWNull null]];
			[sut previewPanel:mockedPanel sourceFrameOnScreenForPreviewItem:[KWMock nullMockForProtocol:@protocol(QLPreviewItem)]];
		});
		it(@"should ask the window to convert the selectedItemRect to screen coordinates", ^{
			[sut stub:@selector(window) andReturn:mockedWindow];
			[[mockedWindow should] receive:@selector(convertRectToScreen:) withArguments:theValue(selectedItemRect)];
			[sut previewPanel:mockedPanel sourceFrameOnScreenForPreviewItem:[KWMock nullMockForProtocol:@protocol(QLPreviewItem)]];
		});
		it(@"should return the selected item rect in screen coorinates", ^{
			[[[NSValue valueWithRect:[sut previewPanel:mockedPanel sourceFrameOnScreenForPreviewItem:[KWAny any]]] should] equal:[NSValue valueWithRect:expectedRect]];
		});
	});
});

SPEC_END
