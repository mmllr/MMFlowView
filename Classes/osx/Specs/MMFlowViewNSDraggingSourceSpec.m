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
//  MMFlowViewNSDraggingSourceSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 19.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView+NSDraggingSource.h"

SPEC_BEGIN(MMFlowViewNSDraggingSourceSpec)

describe(@"MMFlowView+NSDraggingSource", ^{
	__block MMFlowView *sut = nil;
	__block NSDraggingSession *mockedDragSession = nil;

	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
		mockedDragSession = [NSDraggingSession nullMock];
	});
	afterEach(^{
		sut = nil;
		mockedDragSession = nil;
	});
	context(NSStringFromSelector(@selector(draggingSession:sourceOperationMaskForDraggingContext:)), ^{
		context(@"delegate not implementing flowView:draggingSession:sourceOperationMaskForDraggingContext:", ^{
			it(@"should return NSDragOperationNone for NSDraggingContextOutsideApplication", ^{
				[[theValue([sut draggingSession:mockedDragSession sourceOperationMaskForDraggingContext:NSDraggingContextOutsideApplication]) should] equal:theValue(NSDragOperationNone)];
			});
			it(@"should return NSDragOperationNone for NSDraggingContextWithinApplication", ^{
				[[theValue([sut draggingSession:mockedDragSession sourceOperationMaskForDraggingContext:NSDraggingContextWithinApplication]) should] equal:theValue(NSDragOperationNone)];
			});
		});
		context(@"delegate implementing flowView:draggingSession:sourceOperationMaskForDraggingContext:", ^{
			__block id delegateMock = nil;

			beforeEach(^{
				delegateMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewDelegate)];
				[delegateMock stub:@selector(flowView:draggingSession:sourceOperationMaskForDraggingContext:) andReturn:theValue(NSDragOperationEvery)];
				sut.delegate = delegateMock;
			});
			context(@"when context is NSDraggingContextOutsideApplication", ^{
				it(@"should ask the delegate for the operation", ^{
					[[delegateMock should] receive:@selector(flowView:draggingSession:sourceOperationMaskForDraggingContext:) withArguments:sut, mockedDragSession, theValue(NSDraggingContextOutsideApplication)];
					[sut draggingSession:mockedDragSession sourceOperationMaskForDraggingContext:NSDraggingContextOutsideApplication];
				});
				it(@"should return the value provided from the delegate", ^{
					[[theValue([sut draggingSession:mockedDragSession sourceOperationMaskForDraggingContext:NSDraggingContextOutsideApplication]) should] equal:theValue(NSDragOperationEvery)];
				});
			});
			context(@"when context is NSDraggingContextWithinApplication", ^{
				it(@"should ask the delegate for the operation", ^{
					[[delegateMock should] receive:@selector(flowView:draggingSession:sourceOperationMaskForDraggingContext:) withArguments:sut, mockedDragSession, theValue(NSDraggingContextWithinApplication)];
					[sut draggingSession:mockedDragSession sourceOperationMaskForDraggingContext:NSDraggingContextWithinApplication];
				});
				it(@"should return the value provided from the delegate", ^{
					[[theValue([sut draggingSession:mockedDragSession sourceOperationMaskForDraggingContext:NSDraggingContextOutsideApplication]) should] equal:theValue(NSDragOperationEvery)];
				});
			});
		});
	});
	context(NSStringFromSelector(@selector(draggingSession:endedAtPoint:operation:)), ^{
		__block id datasourceMock = nil;
		
		context(@"when the datasource handles removing of items", ^{
			beforeEach(^{
				datasourceMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewDataSource)];
				[datasourceMock stub:@selector(flowView:removeItemAtIndex:)];
				sut.dataSource = datasourceMock;
			});
			it(@"should ask the datasource to delete the selected item when the drag operation is NSDragOperationDelete", ^{
				[[datasourceMock should] receive:@selector(flowView:removeItemAtIndex:) withArguments:sut, theValue(sut.selectedIndex)];
				[sut draggingSession:mockedDragSession endedAtPoint:NSZeroPoint operation:NSDragOperationDelete];
			});
			it(@"should not ask the datasource to delete the selected item when the drag operation is not NSDragOperationDelete", ^{
				[[datasourceMock shouldNot] receive:@selector(flowView:removeItemAtIndex:) withArguments:sut, theValue(sut.selectedIndex)];
				[sut draggingSession:mockedDragSession endedAtPoint:NSZeroPoint operation:NSDragOperationEvery^NSDragOperationDelete];
			});
		});
		context(@"when the datasource does not handle the removing of items", ^{
			beforeEach(^{
				datasourceMock = [KWMock nullMock];
				sut.dataSource = datasourceMock;
			});
			it(@"should not ask the datasource to receive the selected item", ^{
				[[datasourceMock shouldNot] receive:@selector(flowView:removeItemAtIndex:)];
				[sut draggingSession:mockedDragSession endedAtPoint:NSZeroPoint operation:NSDragOperationDelete];
			});
		});
		
	});
});

SPEC_END;
