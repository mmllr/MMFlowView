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
	NSRect initialFrame = NSMakeRect(0, 0, 400, 300);
	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:initialFrame];
	});
	afterEach(^{
		sut = nil;
	});
	it(@"should exists", ^{
		[[sut shouldNot] beNil];
	});
	it(@"should have no items", ^{
		[[theValue(sut.numberOfItems) should] equal:theValue(0)];
	});
	it(@"shoud have no item selected", ^{
		[[theValue(sut.selectedIndex) should] equal:theValue(NSNotFound)];
	});
	it(@"should initially show reflections", ^{
		[[theValue(sut.showsReflection) should] beYes];
	});
});


SPEC_END
