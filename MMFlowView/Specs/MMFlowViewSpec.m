//
//  MMFlowViewSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView.h"

SPEC_BEGIN(MMFlowViewSpec)

context(@"MMFlowView", ^{
	__block MMFlowView *sut = nil;
	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	});
	afterEach(^{
		sut = nil;
	});
	it(@"should exists", ^{
		[[sut shouldNot] beNil];
	});
	
});


SPEC_END
