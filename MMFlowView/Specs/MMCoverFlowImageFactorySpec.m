//
//  MMCoverFlowImageFactorySpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMCoverFlowImageFactory.h"

SPEC_BEGIN(MMCoverFlowImageFactorySpec)

describe(@"MMCoverFlowImageFactory", ^{
	__block MMCoverFlowImageFactory *sut = nil;

	beforeEach(^{
		sut = [[MMCoverFlowImageFactory alloc] init];
	});
	afterEach(^{
		sut = nil;
	});
	it(@"should exist", ^{
		[[sut shouldNot] beNil];
	});
});

SPEC_END
