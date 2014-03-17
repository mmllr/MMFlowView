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
//  MMFlowViewNSDraggingDestinationSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 15.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView.h"
#import "MMFlowView+NSDraggingDestination.h"
#import "MMFlowView_Private.h"

SPEC_BEGIN(MMFlowViewNSDraggingDestinationSpec)

describe(@"NSDraggingDestination", ^{

	context(@"a new instance", ^{
		__block MMFlowView *sut = nil;
		__block id datasourceMock = nil;
		__block id dragInfoMock = nil;

		beforeAll(^{
			datasourceMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewDataSource)];
		});
		afterAll(^{
			datasourceMock = nil;
		});
		beforeEach(^{
			sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
			dragInfoMock = [KWMock nullMockForProtocol:@protocol(NSDraggingInfo)];
			sut.dataSource = datasourceMock;
		});
		afterEach(^{
			sut = nil;
			dragInfoMock = nil;
		});
		it(@"should not want periodic dragging updates", ^{
			[[theValue([sut wantsPeriodicDraggingUpdates]) should] beNo];
		});
		it(@"should return yes for prepareForDragOperation:", ^{
			[[theValue([sut prepareForDragOperation:[KWMock nullMockForProtocol:@protocol(NSDraggingInfo)]]) should] beYes];
		});
		context(@"performDragOperation:", ^{
			context(@"when dragging from the selected item", ^{
				beforeEach(^{
					NSRect itemRect = sut.selectedItemFrame;
					NSPoint pointOverSelectedFrame = NSMakePoint(NSMidX(itemRect), NSMidY(itemRect));
					[dragInfoMock stub:@selector(draggingLocation) andReturn:theValue(pointOverSelectedFrame)];
					[sut stub:@selector(indexOfItemAtPoint:) andReturn:theValue(0) withArguments:theValue(pointOverSelectedFrame)];
				});
				context(@"when the datasource implents -flowView:acceptDrop:atIndex:", ^{
					beforeEach(^{
						[datasourceMock stub:@selector(flowView:acceptDrop:atIndex:) andReturn:theValue(YES)];
					});
					it(@"should ask the datasource if it accepts the drop", ^{
						[[datasourceMock should] receive:@selector(flowView:acceptDrop:atIndex:) andReturn:theValue(YES)];
						[sut performDragOperation:dragInfoMock];
					});
					it(@"should return yes when asked to perform a drag operation", ^{
						[[theValue([sut performDragOperation:dragInfoMock]) should] beYes];
					});
				});
				context(@"when the datasource doesnt implement -flowView:acceptDrop:atIndex:", ^{
					it(@"should return NO when asked to perform a drag operation", ^{
						id emptyDatasourceMock = [KWMock nullMock];
						sut.dataSource = emptyDatasourceMock;
						[[theValue([sut performDragOperation:dragInfoMock]) should] equal:theValue(NO)];
					});
				});
			});
		});
		context(@"draggingEntered:", ^{
			context(@"when dragging from flowview", ^{
				beforeEach(^{
					[dragInfoMock stub:@selector(draggingSource) andReturn:sut];
				});
				it(@"should return NSDragOperationNone", ^{
					[[theValue([sut draggingEntered:dragInfoMock]) should] equal:theValue(NSDragOperationNone)];
				});
				
			});
		});
		context(@"draggingExited:", ^{
			it(@"should reset the highlighted layer", ^{
				[[sut should] receive:@selector(setHighlightedLayer:) withArguments:nil];
				[sut draggingExited:dragInfoMock];
				[[sut.highlightedLayer should] beNil];
			});
		});
		context(@"draggingUpdated:", ^{
			context(@"datasource interaction", ^{
				NSDragOperation expectedOperation = NSDragOperationPrivate;

				beforeEach(^{
					[datasourceMock stub:@selector(flowView:validateDrop:proposedIndex:) andReturn:theValue(expectedOperation)];
					[dragInfoMock stub:@selector(draggingSource) andReturn:[KWAny any]];
				});
				it(@"should ask the datasource if the drag is valid", ^{
					[[datasourceMock should] receive:@selector(flowView:validateDrop:proposedIndex:)
									   withArguments:sut, dragInfoMock, [KWAny any]];
					[[theValue([sut draggingUpdated:dragInfoMock]) should] equal:theValue(expectedOperation)];
				});
				context(@"when dragging from the selected item to the selected item", ^{
					beforeEach(^{
						[dragInfoMock stub:@selector(draggingSource) andReturn:sut];
						[sut stub:@selector(selectedIndex) andReturn:theValue(0)];
						[sut stub:@selector(indexOfItemAtPoint:) andReturn:theValue(0)];
					});
					it(@"should return NSDragOperationNone", ^{
						[[theValue([sut draggingUpdated:dragInfoMock]) should] equal:theValue(NSDragOperationNone)];
					});
				});
				context(@"highlighting the layers", ^{
					beforeEach(^{
						[sut stub:@selector(selectedIndex) andReturn:theValue(0)];
						sut.highlightedLayer = [CALayer layer];
					});
					context(@"dragging on an item", ^{
						beforeEach(^{
							[sut stub:@selector(indexOfItemAtPoint:) andReturn:theValue(1)];
						});
						context(@"when the datasource returns NSDragOperationNone", ^{
							beforeEach(^{
								[datasourceMock stub:@selector(flowView:validateDrop:proposedIndex:) andReturn:theValue(NSDragOperationNone)];
							});
							it(@"should not highlight a layer when dragging to an item", ^{
								[sut draggingUpdated:dragInfoMock];
								[[sut.highlightedLayer should] beNil];
							});
						});
					});
					context(@"not on an item", ^{
						beforeEach(^{
							[sut stub:@selector(indexOfItemAtPoint:) andReturn:theValue(NSNotFound)];
						});
						context(@"when the datasource returns NSDragOperationNone", ^{
							beforeEach(^{
								[datasourceMock stub:@selector(flowView:validateDrop:proposedIndex:) andReturn:theValue(NSDragOperationNone)];
							});
							it(@"should not highlight a layer when not dragging to an item", ^{
								[sut draggingUpdated:dragInfoMock];
								[[sut.highlightedLayer should] beNil];
							});
						});
					});
				});
			});
			context(@"when the datasource does not validate the drop", ^{
				beforeEach(^{
					sut.dataSource = [KWMock nullMock];
				});
				context(@"when dragging to a valid item", ^{
					beforeEach(^{
						[sut stub:@selector(indexOfItemAtPoint:) andReturn:theValue(0)];
					});
					it(@"should return NSDragOperationNone when dragging to a valid item ", ^{
						[[theValue([sut draggingUpdated:dragInfoMock]) should] equal:theValue(NSDragOperationNone)];
					});
					it(@"should not highlight any layer", ^{
						[[sut.highlightedLayer should] beNil];
					});
				});
				context(@"when not dragging to a valid item", ^{
					beforeEach(^{
						[sut stub:@selector(indexOfItemAtPoint:) andReturn:theValue(NSNotFound)];
					});
					it(@"should return NSDragOperationNone when not dragging to an item", ^{
						[[theValue([sut draggingUpdated:dragInfoMock]) should] equal:theValue(NSDragOperationNone)];
					});
					it(@"should not highlight any layer", ^{
						[[sut.highlightedLayer should] beNil];
					});
				});
			});
		});
		context(@"concludeDragOperation:", ^{
			it(@"should not highlight any layer", ^{
				[[sut should] receive:@selector(setHighlightedLayer:) withArguments:[KWNull null]];
				[sut concludeDragOperation:dragInfoMock];
				[[sut.highlightedLayer should] beNil];
			});
		});
	});
});
SPEC_END
