//
//  MMFlowViewContentBinderDelegateSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 03.04.14.
//  Copyright 2014 Markus Müller. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView_Private.h"
#import "MMFlowViewContentBinder.h"
#import "MMFlowView+MMFlowViewContentBinderDelegate.h"
#import "MMFlowViewImageCache.h"
#import "MMCoverFlowLayer.h"

SPEC_BEGIN(MMFlowViewContentBinderDelegateSpec)

describe(@"MMFlowView+MMFlowViewContentBinderDelegate", ^{
	__block MMFlowView *sut = nil;
	__block MMFlowViewContentBinder *contentBinderMock = nil;
	NSArray *contentArray = @[];
	
	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
		contentBinderMock = [KWMock nullMockForClass:[MMFlowViewContentBinder class]];
		[contentBinderMock stub:@selector(observedItems) andReturn:contentArray];
	});
	afterEach(^{
		sut = nil;
		contentBinderMock = nil;
	});

	it(@"should conform to the MMFlowViewContentBinderDelegate protocol", ^{
		[[sut should] conformToProtocol:@protocol(MMFlowViewContentBinderDelegate)];
	});

	it(@"should respond to -contentArrayDidChange:", ^{
		[[sut should] respondToSelector:@selector(contentArrayDidChange:)];
	});

	it(@"should respond to -contentBinder:itemChanged:", ^{
		[[sut should] respondToSelector:@selector(contentBinder:itemChanged:)];
	});

	context(NSStringFromSelector(@selector(contentArrayDidChange:)), ^{
		it(@"should reload the content", ^{
			[[sut should] receive:@selector(reloadContent)];

			[sut contentArrayDidChange:contentBinderMock];
		});
		it(@"should set the contentAdapter to the contentBinders contentArray", ^{
			[sut contentArrayDidChange:contentBinderMock];

			[[sut.contentAdapter should] equal:contentBinderMock.observedItems];
		});
	});

	context(NSStringFromSelector(@selector(contentBinder:itemChanged:)), ^{
		__block id itemMock = nil;
		__block id imageCacheMock = nil;
		__block id coverFLowLayerMock = nil;

		NSString *testUID = @"testUID";

		beforeEach(^{
			itemMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewItem)];
			[itemMock stub:@selector(imageItemUID) andReturn:testUID];

			imageCacheMock = [KWMock nullMockForClass:[MMFlowViewImageCache class]];
			sut.imageCache = imageCacheMock;

			coverFLowLayerMock = [MMCoverFlowLayer nullMock];
			sut.coverFlowLayer = coverFLowLayerMock;
		});
		afterEach(^{
			coverFLowLayerMock = nil;
			imageCacheMock = nil;
		});
		it(@"should remove the image from the image cache", ^{
			[[imageCacheMock should] receive:@selector(removeImageWithUUID:) withArguments:testUID];

			[sut contentBinder:contentBinderMock itemChanged:itemMock];
		});
		it(@"should trigger a relayout in the coverFlowLayer", ^{
			[[coverFLowLayerMock should] receive:@selector(setNeedsLayout)];

			[sut contentBinder:contentBinderMock itemChanged:itemMock];
		});
	});
});

SPEC_END
