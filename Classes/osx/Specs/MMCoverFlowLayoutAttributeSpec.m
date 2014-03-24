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

#import <QuartzCore/QuartzCore.h>

#import "Kiwi.h"
#import "MMCoverFLowLayoutAttributes.h"

@interface TestingMMCoverFlowLayoutAttributesSubclass : MMCoverFlowLayoutAttributes

@end

@implementation TestingMMCoverFlowLayoutAttributesSubclass


@end

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
		const NSUInteger indexFixture = 10;
		const CGPoint positionFixture = CGPointMake(10, 10);
		const CGSize sizeFixture = CGSizeMake(50, 50);
		const CGPoint anchorPointFixture = CGPointMake(.5,.5);
		const CATransform3D transformFixture = CATransform3DIdentity;
		const CGFloat zPositionFixture = 100;

		beforeEach(^{
			sut = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:indexFixture
															position:positionFixture
																size:sizeFixture
														 anchorPoint:anchorPointFixture
														   transfrom:transformFixture
														   zPosition:zPositionFixture];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should exists", ^{
			[[sut shouldNot] beNil];
		});
		context(@"values from designated initializer", ^{
			it(@"should have an index of 10", ^{
				[[theValue(sut.index) should] equal:@(indexFixture)];
			});
			it(@"should have an identity transform matrix", ^{
				NSValue *expectedTransform = [NSValue valueWithCATransform3D:transformFixture];
				[[[NSValue valueWithCATransform3D:sut.transform] should] equal:expectedTransform];
			});
			it(@"should have a positon of {10,10}", ^{
				NSValue *expectedPosition = [NSValue valueWithPoint:positionFixture];
				[[[NSValue valueWithPoint:sut.position] should] equal:expectedPosition];
			});
			it(@"should have the bounds passed by the designated initalizer", ^{
				[[theValue(sut.bounds) should] equal:theValue(CGRectMake(0, 0, sizeFixture.width, sizeFixture.height))];
			});
			it(@"should have a {0.5,0.5} anchorpoint", ^{
				NSValue *expectedPoint = [NSValue valueWithPoint:NSPointFromCGPoint(CGPointMake(.5, .5))];
				[[[NSValue valueWithPoint:NSPointFromCGPoint(sut.anchorPoint)] should] equal:expectedPoint];
			});
			it(@"should have a zPosition of 100", ^{
				[[theValue(sut.zPosition) should] equal:theValue(100)];
			});
		});
		context(NSStringFromProtocol(@protocol(NSObject)), ^{
			__block MMCoverFlowLayoutAttributes *attribute = nil;

			beforeEach(^{
				attribute = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:sut.index position:sut.position size:sut.bounds.size anchorPoint:sut.anchorPoint transfrom:sut.transform zPosition:sut.zPosition];
			});
			afterEach(^{
				attribute = nil;
			});

			context(NSStringFromSelector(@selector(hash)), ^{
				it(@"should have the same hash as an instance with identical values", ^{
					[[theValue([sut hash]) should] equal:theValue([attribute hash])];
				});
				it(@"should not be equal with a differing index", ^{
					[attribute setValue:@(20) forKey:@"index"];
					
					[[theValue([sut hash]) shouldNot] equal:theValue([attribute hash])];
				});
				it(@"should not have the same hash with a differing transform", ^{
					[attribute setValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(30, 60, 90)] forKey:@"transform"];
					
					[[theValue([sut hash]) shouldNot] equal:theValue([attribute hash])];
				});
				it(@"should not have the same hash with a differing bounds", ^{
					[attribute setValue:[NSValue valueWithRect:CGRectMake(0, 0, 400, 400)] forKey:@"bounds"];
					
					[[theValue([sut hash]) shouldNot] equal:theValue([attribute hash])];
				});
				it(@"should not have the same hash with a differing zPosition", ^{
					[attribute setValue:@200 forKey:@"zPosition"];
					
					[[theValue([sut hash]) shouldNot] equal:theValue([attribute hash])];
				});
				it(@"should not have the same hash with a differing position", ^{
					[attribute setValue:[NSValue valueWithPoint:CGPointMake(50, 50)] forKey:@"position"];
					
					[[theValue([sut hash]) shouldNot] equal:theValue([attribute hash])];
				});
				it(@"should not have the same hash with a differing anchorPoint", ^{
					[attribute setValue:[NSValue valueWithPoint:CGPointMake(50, 50)] forKey:@"anchorPoint"];
					
					[[theValue([sut hash]) shouldNot] equal:theValue([attribute hash])];
				});
			});
			context(NSStringFromSelector(@selector(isEqual:)), ^{
				it(@"should be equal to itself", ^{
					[[theValue([sut isEqual:sut]) should] beYes];
				});
				it(@"should be equal to another instance with the same attribute values", ^{
					[[sut should] equal:attribute];
				});
				it(@"should not be equal with a differing index", ^{
					[attribute setValue:@(20) forKey:@"index"];
					
					[[sut shouldNot] equal:attribute];
				});
				it(@"should not be equal with a differing transform", ^{
					[attribute setValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(30, 60, 90)] forKey:@"transform"];
					
					[[sut shouldNot] equal:attribute];
				});
				it(@"should not be equal with a differing bounds", ^{
					[attribute setValue:[NSValue valueWithRect:CGRectMake(0, 0, 400, 400)] forKey:@"bounds"];
					
					[[sut shouldNot] equal:attribute];
				});
				it(@"should not be equal with a differing zPosition", ^{
					[attribute setValue:@200 forKey:@"zPosition"];
					
					[[sut shouldNot] equal:attribute];
				});
				it(@"should not be equal with a differing position", ^{
					[attribute setValue:[NSValue valueWithPoint:CGPointMake(50, 50)] forKey:@"position"];
					
					[[sut shouldNot] equal:attribute];
				});
				it(@"should not be equal with a differing anchorPoint", ^{
					[attribute setValue:[NSValue valueWithPoint:CGPointMake(50, 50)] forKey:@"anchorPoint"];
					
					[[sut shouldNot] equal:attribute];
				});
				it(@"should be equal to a subclass", ^{
					TestingMMCoverFlowLayoutAttributesSubclass *subclass = [[TestingMMCoverFlowLayoutAttributesSubclass alloc] initWithIndex:sut.index position:sut.position size:sut.bounds.size anchorPoint:sut.anchorPoint transfrom:sut.transform zPosition:sut.zPosition];
					
					[[sut should] equal:subclass];
				});
				it(@"should not be equal to a KVC compatible container", ^{
					NSDictionary *attributesDict = [sut dictionaryWithValuesForKeys:@[@"index", @"transform", @"bounds", @"position", @"anchorPoint", @"zPosition"]];
					
					[[sut shouldNot] equal:attributesDict];
				});
			});
		});
		context(NSStringFromSelector(@selector(applyToLayer:)), ^{
			__block CALayer *mockedLayer = nil;

			beforeEach(^{
				mockedLayer = [CALayer nullMock];
			});
			afterEach(^{
				mockedLayer = nil;
			});

			it(@"should respond to applyToLayer:", ^{
				[[sut should] respondToSelector:@selector(applyToLayer:)];
			});
			it(@"should set the anchorPoint to the layer", ^{
				[[mockedLayer should] receive:@selector(setAnchorPoint:) withArguments:theValue(sut.anchorPoint)];

				[sut applyToLayer:mockedLayer];
			});
			it(@"should set the zPosition to the layer", ^{
				[[mockedLayer should] receive:@selector(setZPosition:) withArguments:theValue(sut.zPosition)];
			
				[sut applyToLayer:mockedLayer];
			});
			it(@"should set the transform to the layer", ^{
				[[mockedLayer should] receive:@selector(setTransform:) withArguments:theValue(sut.transform)];
				
				[sut applyToLayer:mockedLayer];
			});
			it(@"should set the bounds to the layer", ^{
				[[mockedLayer should] receive:@selector(setBounds:) withArguments:theValue(sut.bounds)];
				
				[sut applyToLayer:mockedLayer];
			});
			it(@"should set the position adjusted by the anchorPoint", ^{
				CGAffineTransform anchorTransform = CGAffineTransformMakeTranslation(sut.anchorPoint.x*CGRectGetWidth(sut.bounds), sut.anchorPoint.y*CGRectGetHeight(sut.bounds));
				CGPoint expectedPosition = CGPointApplyAffineTransform(sut.position, anchorTransform);
				[[mockedLayer should] receive:@selector(setPosition:) withArguments:theValue(expectedPosition)];

				[sut applyToLayer:mockedLayer];
			});
			it(@"should set the index", ^{
				[[mockedLayer should] receive:@selector(setValue:forKey:) withArguments:@(indexFixture), kMMCoverFlowLayoutAttributesIndexAttributeKey];
				
				[sut applyToLayer:mockedLayer];
			});
		});
		context(NSStringFromSelector(@selector(description)), ^{
			it(@"should return the expected description string", ^{
				NSString *expectedDescription = [NSString stringWithFormat:@"MMCoverFlowLayoutAttributes: %p, index: %@, position: %@, anchorPoint: %@, bounds: %@, zPosition: %@, transform: %@", sut, @(sut.index), [NSValue valueWithPoint:sut.position], [NSValue valueWithPoint:sut.anchorPoint], [NSValue valueWithRect:sut.bounds], @(sut.zPosition), [NSValue valueWithCATransform3D:sut.transform]];

				[[[sut description] should] equal:expectedDescription];
			});
		});
	});
});

SPEC_END
