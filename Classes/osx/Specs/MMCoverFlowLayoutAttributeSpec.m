/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://github.com/mmllr All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this
 software and associated documentation files (the "Software"), to deal in the Software
 without restriction, including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies
 or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
 
 */
//
//  MMCoverFlowLayoutAttributeSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMCoverFLowLayoutAttributes.h"

SPEC_BEGIN(MMCoverFlowLayoutAttributesSpec)

describe(@"MMCoverFlowLayoutAttributes", ^{
	__block MMCoverFlowLayoutAttributes *sut = nil;

	context(@"creating with default -init", ^{
		it(@"should raise if created with -init", ^{
			[[theBlock(^{
				sut = [[MMCoverFlowLayoutAttributes alloc] init];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
	context(@"a new instance created with designated initializer", ^{
		beforeEach(^{
			sut = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:10
															position:CGPointMake(10, 10)
																size:CGSizeMake(50, 50)
														 anchorPoint:CGPointMake(.5,.5)
														   transfrom:CATransform3DIdentity
														   zPosition:100];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should exists", ^{
			[[sut shouldNot] beNil];
		});
		context(@"values from designated initializer", ^{
			it(@"should have an index of 10", ^{
				[[theValue(sut.index) should] equal:@10];
			});
			it(@"should have an identity transform matrix", ^{
				NSValue *expectedTransform = [NSValue valueWithCATransform3D:CATransform3DIdentity];
				[[[NSValue valueWithCATransform3D:sut.transform] should] equal:expectedTransform];
			});
			it(@"should have a positon of {10,10}", ^{
				NSValue *expectedPosition = [NSValue valueWithPoint:CGPointMake(10, 10)];
				[[[NSValue valueWithPoint:sut.position] should] equal:expectedPosition];
			});
			it(@"should have the bounds passed by the designated initalizer", ^{
				NSValue *expectedBounds = [NSValue valueWithRect:CGRectMake(0, 0, 50, 50)];
				[[[NSValue valueWithRect:sut.bounds] should] equal:expectedBounds];
			});
			it(@"should have a {0.5,0.5} anchorpoint", ^{
				NSValue *expectedPoint = [NSValue valueWithPoint:NSPointFromCGPoint(CGPointMake(.5, .5))];
				[[[NSValue valueWithPoint:NSPointFromCGPoint(sut.anchorPoint)] should] equal:expectedPoint];
			});
			it(@"should have a zPosition of 100", ^{
				[[theValue(sut.zPosition) should] equal:theValue(100)];
			});
		});
		
	});
});

SPEC_END
