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
//  MMFlowViewMMScrollBarDelegateSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 04.03.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+MMScrollBarDelegate.h"
#import "MMScrollBarLayer.h"
#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayer.h"

SPEC_BEGIN(MMFlowViewMMScrollBarDelegateSpec)

describe(@"MMFlowView+MMScrollBarDelegate", ^{
	__block MMFlowView *sut = nil;

	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	});
	afterEach(^{
		sut = nil;
	});
	it(@"should conform to MMScrollBarDelegate protocol", ^{
		[[sut should] conformToProtocol:@protocol(MMScrollBarDelegate)];
	});
	it(@"should respond to scrollBarLayer:knobDraggedToPosition:", ^{
		[[sut should] respondToSelector:@selector(scrollBarLayer:knobDraggedToPosition:)];
	});
	it(@"should respond to decrementClickedInScrollBarLayer:", ^{
		[[sut should] respondToSelector:@selector(decrementClickedInScrollBarLayer:)];
	});
	it(@"should respond to incrementClickedInScrollBarLayer:", ^{
		[[sut should] respondToSelector:@selector(incrementClickedInScrollBarLayer:)];
	});
	it(@"should be the scroll bar delegate", ^{
		[[sut should] equal:sut.scrollBarLayer.scrollBarDelegate];
	});
	context(NSStringFromSelector(@selector(scrollBarLayer:knobDraggedToPosition:)), ^{
		context(@"when delegate method is invoked from flowviews scroll bar layer and the flow view has items", ^{
			beforeEach(^{
				[sut stub:@selector(numberOfItems) andReturn:theValue(11)];
			});
			it(@"should change the selection to first item when knob dragged to leftmost position", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(0)];
				[sut scrollBarLayer:sut.scrollBarLayer knobDraggedToPosition:0];
			});
			it(@"should change the selection to last item when knob dragged to rightmost position", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(10)];
				[sut scrollBarLayer:sut.scrollBarLayer knobDraggedToPosition:1];
			});
			it(@"should change the selection to the middle item when knob dragged to mid position", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(5)];
				[sut scrollBarLayer:sut.scrollBarLayer knobDraggedToPosition:.5];
			});
		});
		context(@"when delegate method is not invoked with flowviews scroll bar layer", ^{
			__block MMScrollBarLayer *mockedScrollBarLayer = nil;
			
			beforeEach(^{
				mockedScrollBarLayer = [MMScrollBarLayer nullMock];
			});
			afterEach(^{
				mockedScrollBarLayer = nil;
			});
			it(@"should not change the selection", ^{
				[[sut shouldNot] receive:@selector(setSelectedIndex:)];
				
				[sut scrollBarLayer:mockedScrollBarLayer knobDraggedToPosition:.3];
			});
		});
	});
	context(NSStringFromSelector(@selector(decrementClickedInScrollBarLayer:)), ^{
		context(@"when delegate method is invoked from flowviews scroll bar layer", ^{
			it(@"should move the selection one item left", ^{
				[[sut should] receive:@selector(moveLeft:) withArguments:sut];
				[sut decrementClickedInScrollBarLayer:sut.scrollBarLayer];
			});
		});
		context(@"when delegate method is not invoked with flowviews scroll bar layer", ^{
			__block MMScrollBarLayer *mockedScrollBarLayer = nil;
			
			beforeEach(^{
				mockedScrollBarLayer = [MMScrollBarLayer nullMock];
			});
			afterEach(^{
				mockedScrollBarLayer = nil;
			});
			it(@"should not change the selection", ^{
				[[sut shouldNot] receive:@selector(setSelectedIndex:)];
				
				[sut decrementClickedInScrollBarLayer:mockedScrollBarLayer];
			});
		});
	});
	context(NSStringFromSelector(@selector(incrementClickedInScrollBarLayer:)), ^{
		context(@"when delegate method is invoked from flowviews scroll bar layer", ^{
			it(@"should move the selection one item right", ^{
				[[sut should] receive:@selector(moveRight:) withArguments:sut];
				[sut incrementClickedInScrollBarLayer:sut.scrollBarLayer];
			});
		});
		context(@"when delegate method is not invoked with flowviews scroll bar layer", ^{
			__block MMScrollBarLayer *mockedScrollBarLayer = nil;
			
			beforeEach(^{
				mockedScrollBarLayer = [MMScrollBarLayer nullMock];
			});
			afterEach(^{
				mockedScrollBarLayer = nil;
			});
			it(@"should not change the selection", ^{
				[[sut shouldNot] receive:@selector(setSelectedIndex:)];
				
				[sut incrementClickedInScrollBarLayer:mockedScrollBarLayer];
			});
		});
	});
	context(NSStringFromSelector(@selector(contentSizeForScrollBarLayer:)), ^{
		__block MMCoverFlowLayout *mockedLayout = nil;

		beforeEach(^{
			mockedLayout = [MMCoverFlowLayout nullMock];
			[mockedLayout stub:@selector(contentWidth) andReturn:theValue(1000)];
			sut.layout = mockedLayout;
		});
		afterEach(^{
			mockedLayout = nil;
		});
		it(@"should respond to contentSizeForScrollBarLayer:", ^{
			[[sut should] respondToSelector:@selector(contentSizeForScrollBarLayer:)];
		});
		it(@"should return the content size of the layout", ^{
			CGFloat expectedSize = 1000;
			[[theValue([sut contentSizeForScrollBarLayer:sut.scrollBarLayer]) should] equal:theValue(expectedSize)];
		});
		it(@"should ask the layout for the content width", ^{
			[[mockedLayout should] receive:@selector(contentWidth)];

			[sut contentSizeForScrollBarLayer:sut.scrollBarLayer];
		});
	});
	context(NSStringFromSelector(@selector(visibleSizeForScrollBarLayer:)), ^{
		__block MMCoverFlowLayer *mockedCoverFlowLayer = nil;
		CGRect visibleRect = CGRectMake(0, 0, 100, 100);

		beforeEach(^{
			mockedCoverFlowLayer = [MMCoverFlowLayer nullMock];
			[mockedCoverFlowLayer stub:@selector(visibleRect) andReturn:theValue(visibleRect)];
			sut.coverFlowLayer = mockedCoverFlowLayer;
		});
		afterEach(^{
			mockedCoverFlowLayer = nil;
		});
		it(@"should respond to visibleSizeForScrollBarLayer:", ^{
			[[sut should] respondToSelector:@selector(visibleSizeForScrollBarLayer:)];
		});
		it(@"should return the visible size of the cover flow layer", ^{
			[[theValue([sut visibleSizeForScrollBarLayer:sut.scrollBarLayer]) should] equal:CGRectGetWidth(visibleRect) withDelta:0.00001];
		});
		it(@"should ask the cover flow layer for its visible rect", ^{
			[[mockedCoverFlowLayer should] receive:@selector(visibleRect)];

			[sut visibleSizeForScrollBarLayer:sut.scrollBarLayer];
		});
	});
	context(NSStringFromSelector(@selector(currentKnobPositionInScrollBarLayer:)), ^{
		beforeEach(^{
			[sut stub:@selector(numberOfItems) andReturn:theValue(11)];
		});
		it(@"should respond to currentKnobPositionInScrollBarLayer:", ^{
			[[sut should] respondToSelector:@selector(currentKnobPositionInScrollBarLayer:)];
		});
		it(@"should return zero for the first selected index", ^{
			[sut stub:@selector(selectedIndex) andReturn:theValue(0)];

			[[theValue([sut currentKnobPositionInScrollBarLayer:sut.scrollBarLayer]) should] beZero];
		});
		it(@"should return one for the last selected index", ^{
			[sut stub:@selector(selectedIndex) andReturn:theValue(10)];
			
			[[theValue([sut currentKnobPositionInScrollBarLayer:sut.scrollBarLayer]) should] equal:theValue(1)];
		});
		it(@"should return .5 for the mid selected index", ^{
			[sut stub:@selector(selectedIndex) andReturn:theValue(5)];

			[[theValue([sut currentKnobPositionInScrollBarLayer:sut.scrollBarLayer]) should] equal:theValue(.5)];
		});
		it(@"should return zero for an invalid selection", ^{
			[sut stub:@selector(selectedIndex) andReturn:theValue(NSNotFound)];

			[[theValue([sut currentKnobPositionInScrollBarLayer:sut.scrollBarLayer]) should] beZero];
		});
		it(@"should return zero for with no items", ^{
			[sut stub:@selector(numberOfItems) andReturn:theValue(0)];

			[[theValue([sut currentKnobPositionInScrollBarLayer:sut.scrollBarLayer]) should] beZero];
		});
		it(@"should return zero for with first item selected and one items", ^{
			[sut stub:@selector(selectedIndex) andReturn:theValue(0)];
			[sut stub:@selector(numberOfItems) andReturn:theValue(1)];
			
			[[theValue([sut currentKnobPositionInScrollBarLayer:sut.scrollBarLayer]) should] beZero];
		});
		it(@"should return zero for with first item selected and one items", ^{
			[sut stub:@selector(selectedIndex) andReturn:theValue(1)];
			[sut stub:@selector(numberOfItems) andReturn:theValue(1)];
			
			[[theValue([sut currentKnobPositionInScrollBarLayer:sut.scrollBarLayer]) should] equal:theValue(1)];
		});
	});
});

SPEC_END
