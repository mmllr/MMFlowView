//
//  MMFlowViewDatasourceContentAdapterSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 01.04.14.
//  Copyright 2014 Markus Müller. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowViewContentAdapter.h"
#import "MMFlowViewDatasourceContentAdapter.h"
#import "MMFlowView.h"

SPEC_BEGIN(MMFlowViewDatasourceContentAdapterSpec)

describe(NSStringFromClass([MMFlowViewDatasourceContentAdapter class]), ^{
	__block MMFlowViewDatasourceContentAdapter *sut = nil;
	__block id dataSourceMock = nil;
	__block MMFlowView *flowViewMock = nil;

	afterEach(^{
		sut = nil;
		dataSourceMock = nil;
		flowViewMock = nil;
	});

	it(@"should raise an NSInternalInconsistencyException when not created with designated initalizer", ^{
		[[theBlock(^{
			sut = [[MMFlowViewDatasourceContentAdapter alloc] init];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});

	it(@"should raise an NSInternalInconsistencyException when created with nil flow view", ^{
		[[theBlock(^{
			sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:nil];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	context(@"a newly instance created with a valid datasource and a flowview", ^{
		__block id itemMock = nil;
		NSUInteger numberOfItems = 10;
		
		beforeEach(^{
			itemMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewItem)];

			dataSourceMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewDataSource)];
			[dataSourceMock stub:@selector(flowView:itemAtIndex:) andReturn:itemMock];
			[dataSourceMock stub:@selector(numberOfItemsInFlowView:) andReturn:theValue(numberOfItems)];

			flowViewMock = [MMFlowView nullMock];
			[flowViewMock stub:@selector(dataSource) andReturn:dataSourceMock];

			sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:flowViewMock];
		});
		afterEach(^{
			itemMock = nil;
		});
		
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should conform to MMFlowViewContentAdapter", ^{
			[[sut should] conformToProtocol:@protocol(MMFlowViewContentAdapter)];
		});
		
		context(NSStringFromSelector(@selector(count)), ^{
			it(@"should respond to count", ^{
				[[sut should] respondToSelector:@selector(count)];
			});
			it(@"should ask the datasource for the count of items", ^{
				[[dataSourceMock should] receive:@selector(numberOfItemsInFlowView:) withArguments:flowViewMock];
		
				[sut count];
			});
			it(@"should return the number of items in the datasource", ^{
				[[sut should] haveCountOf:numberOfItems];
			});
		});

		context(NSStringFromSelector(@selector(objectAtIndexedSubscript:)), ^{
			it(@"should respond to objectAtIndexedSubscript:", ^{
				[[sut should] respondToSelector:@selector(objectAtIndexedSubscript:)];
			});
			it(@"should ask the datasource for the item at the index", ^{
				[[dataSourceMock should] receive:@selector(flowView:itemAtIndex:)];

				[sut objectAtIndexedSubscript:0];
			});
			it(@"should raise an NSRangeException if accessed with an index out of bounds", ^{
				[[theBlock(^{
					[sut objectAtIndexedSubscript:numberOfItems];
				}) should] raiseWithName:NSRangeException reason:@"Index 10 out of bounds (10)"];
			});
		});
	});
	context(@"when the datasource is set but incomplete", ^{
		beforeEach(^{
			dataSourceMock = [KWMock mock];
			
			flowViewMock = [MMFlowView nullMock];
			[flowViewMock stub:@selector(dataSource) andReturn:dataSourceMock];

			sut = [[MMFlowViewDatasourceContentAdapter alloc] initWithFlowView:flowViewMock];
		});
		context(NSStringFromSelector(@selector(count)), ^{
			it(@"should not ask the datasource if it does not respond to numberOfItemsInFlowView:", ^{
				[[dataSourceMock shouldNot] receive:@selector(numberOfItemsInFlowView:)];
				
				[sut count];
			});
			it(@"should have a count of zero", ^{
				[[sut should] haveCountOf:0];
			});
		});

		context(@"when the datasource implements numberOfItemsInFlowView:", ^{
			beforeEach(^{
				[dataSourceMock stub:@selector(numberOfItemsInFlowView:) andReturn:theValue(10)];
			});
			context(NSStringFromSelector(@selector(objectAtIndexedSubscript:)), ^{
				it(@"should not send flowView:itemAtIndex: to the datasource and return nil", ^{
					[[dataSourceMock shouldNot] receive:@selector(flowView:itemAtIndex:)];

					[[(id)[sut objectAtIndexedSubscript:0] should] beNil];
				});
			});
		});
	});
});

SPEC_END
