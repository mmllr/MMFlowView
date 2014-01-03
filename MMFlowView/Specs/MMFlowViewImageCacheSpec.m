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
	__block MMFlowViewImageCache* sut = nil;

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
		it(@"should have no cached images", ^{
			[[theValue(sut.numberOfImages) should] equal:theValue(0)];
		});
	});
	
});

SPEC_END
