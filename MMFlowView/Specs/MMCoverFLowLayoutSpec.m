//
//  MMCoverFLowLayoutSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMCoverFLowLayout.h"

SPEC_BEGIN(MMCoverFLowLayoutSpec)

context(@"MMCoverFlowLayout", ^{
	context(@"a new instance", ^{
		__block MMCoverFlowLayout *sut = nil;
		CGSize defaultItemSize = CGSizeMake(50, 50);

		beforeEach(^{
			sut = [[MMCoverFlowLayout alloc] init];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should exists", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should have the default inter item spacing", ^{
			[[theValue(sut.interItemSpacing) should] equal:theValue(10)];
		});
		it(@"should have the default item size", ^{
			NSValue *itemSize = [NSValue valueWithSize:sut.itemSize];
			NSValue *expectedSite = [NSValue valueWithSize:defaultItemSize];
			[[itemSize should] equal:expectedSite];
		});
		it(@"should have a zero contentSize", ^{
			[[theValue((BOOL)CGSizeEqualToSize(sut.contentSize, CGSizeZero)) should] beTrue];
		});
	});
});

SPEC_END
