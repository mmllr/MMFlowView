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
		context(@"when delegate method is not invoked from flowviews scroll bar layer", ^{
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
	
});

SPEC_END
