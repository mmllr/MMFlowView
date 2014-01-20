//
//  MMFlowViewImageCacheSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 02.01.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowViewImageCache.h"

SPEC_BEGIN(MMFlowViewImageCacheSpec)

describe(@"MMFlowViewImageCache", ^{
	__block id sut = nil;

	beforeEach(^{
		sut = [KWMock nullMockForProtocol:@protocol(MMFlowViewImageCache)];
	});
	afterEach(^{
		sut = nil;
	});
	context(@"newly created instance", ^{
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should respond to cacheImage:", ^{
			[[sut should] respondToSelector:@selector(cacheImage:withUID:)];
		});
		it(@"should respond to imageForUID:", ^{
			[[sut should] respondToSelector:@selector(imageForUID:)];
		});
	});
	
});

SPEC_END
