//
//  MMFlowViewImageCacheSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 02.01.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowViewImageCache.h"
#import "MMFlowView.h"

SPEC_BEGIN(MMFlowViewImageCacheSpec)

describe(@"MMFlowViewImageCache", ^{
	__block id sut = nil;

	beforeEach(^{
		sut = [[MMFlowViewImageCache alloc] init];
	});
	afterEach(^{
		sut = nil;
	});
	context(@"newly created instance", ^{
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should conform to MMFlowViewImageCache", ^{
			[[sut should] conformToProtocol:@protocol(MMFlowViewImageCache)];
		});
		it(@"should repond to cacheItem:withUUID:", ^{
			[[sut should] respondToSelector:@selector(cacheItem:withUUID:)];
		});
		it(@"should respond to itemForUUID:", ^{
			[[sut should] respondToSelector:@selector(itemForUUID:)];
		});
		context(@"caching items", ^{
			__block id itemMock = nil;

			beforeEach(^{
				itemMock = [NSObject nullMock];
			});
			afterEach(^{
				itemMock = nil;
			});
			it(@"should put an item to the cache", ^{
				// when
				[sut cacheItem:itemMock withUUID:@"item"];
				// then
				[[[sut itemForUUID:@"item"] should] equal:itemMock];
			});
			it(@"should return nil for an item not in the cache", ^{
				[[[sut itemForUUID:@"an item not in cache"] should] beNil];
			});
			it(@"should not throw when asking for an item with nil uuid", ^{
				[[theBlock(^{
					[sut itemForUUID:nil];
				}) shouldNot] raise];
			});
		});
	});
	
});

SPEC_END
