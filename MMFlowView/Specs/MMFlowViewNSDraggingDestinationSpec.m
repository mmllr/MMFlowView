//
//  MMFlowViewNSDraggingDestinationSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 15.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView+NSDraggingDestination.h"

SPEC_BEGIN(MMFlowViewNSDraggingDestinationSpec)

describe(@"NSDraggingDestination", ^{

	context(@"a new instance", ^{
		__block MMFlowView *sut = nil;

		beforeEach(^{
			sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should not want periodic dragging updates", ^{
			[[theValue([sut wantsPeriodicDraggingUpdates]) should] beNo];
		});
		it(@"should return yes for prepareForDragOperation:", ^{
			[[theValue([sut prepareForDragOperation:[KWMock nullMockForProtocol:@protocol(NSDraggingInfo)]]) should] beYes];
		});
		context(@"-performDragOperation:", ^{
			__block id dragInfo = nil;
			beforeEach(^{
				dragInfo = [KWMock nullMockForProtocol:@protocol(NSDraggingInfo)];
			});
		});
});

});
SPEC_END
