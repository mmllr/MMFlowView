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
//  MMCoverFlowImageLayerSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 29.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFLowViewImageLayer.h"

SPEC_BEGIN(MMCoverFlowImageLayerSpec)

describe(@"MMFlowViewImageLayer", ^{
	__block MMFlowViewImageLayer *sut = nil;

	context(@"creating with CALayer default -init/+layer", ^{
		it(@"should raise if created with +layer", ^{
			[[theBlock(^{
				[MMFlowViewImageLayer layer];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		it(@"should raise if created with -init", ^{
			[[theBlock(^{
				sut = [[MMFlowViewImageLayer alloc] init];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
	context(@"designated initializer", ^{
		const NSUInteger expectedIndex = 1;

		beforeEach(^{
			sut = [[MMFlowViewImageLayer alloc] initWithIndex:expectedIndex];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should have an index", ^{
			[[theValue(sut.index) should] equal:theValue(expectedIndex)];
		});
		it(@"should have name equal MMFlowViewContentLayerImage", ^{
			[[sut.name should] equal:@"MMFlowViewContentLayerImage"];
		});
		it(@"should have a contentsGravity of kCAGravityResizeAspect", ^{
			[[sut.contentsGravity should] equal:kCAGravityResizeAspect];
		});
		it(@"should have a constraints layout manager", ^{
			[[sut.layoutManager should] equal:[CAConstraintLayoutManager layoutManager]];
		});
		context(@"CoreAnimation actions", ^{
			__block id action = nil;
			
			context(@"transitions", ^{
				__block CATransition *transition = nil;
				
				context(@"order out transition", ^{
					beforeEach(^{
						action = [sut actionForKey:kCAOnOrderOut];
						transition = (CATransition*)action;
					});
					afterEach(^{
						transition = nil;
					});
					it(@"should be a CATransition class", ^{
						[[transition should] beKindOfClass:[CATransition class]];
					});
					it(@"should be a fading transition", ^{
						[[transition.type should] equal:kCATransitionFade];
					});
					it(@"should have a duration of .5 seconds", ^{
						[[theValue(transition.duration) should] equal:theValue(.5)];
					});
				});
				context(@"order in transition", ^{
					beforeEach(^{
						action = [sut actionForKey:kCAOnOrderIn];
						transition = (CATransition*)action;
					});
					afterEach(^{
						transition = nil;
					});
					it(@"should be a CATransition class", ^{
						[[transition should] beKindOfClass:[CATransition class]];
					});
					it(@"should be a reveal transition", ^{
						[[transition.type should] equal:kCATransitionReveal];
					});
					it(@"should have a duration of .5 seconds", ^{
						[[theValue(transition.duration) should] equal:theValue(.5)];
					});
				});
			});
			it(@"should have no contents action", ^{
				[[(id)[sut actionForKey:@"contents"] should] beNil];
			});
			it(@"should have no bounds action", ^{
				[[(id)[sut actionForKey:@"bounds"] should] beNil];
			});
			
		});

	});
	
});

SPEC_END
