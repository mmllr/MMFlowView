//
//  NSValueMMAdditionsSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 23.01.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "NSValue+MMAdditions.h"

SPEC_BEGIN(NSValueMMAdditionsSpec)

describe(@"NSValue+MMAdditions", ^{
	__block NSValue *sut = nil;

	afterEach(^{
		sut = nil;
	});
	context(@"+valueWithCGAffineTransform:", ^{
		it(@"should respond to valueWithCGAffineTransform class method", ^{
			[[[NSValue class] should] respondToSelector:@selector(valueWithCGAffineTransform:)];
		});
		it(@"should create a value from a CGAffineTransform", ^{
			[[[NSValue valueWithCGAffineTransform:CGAffineTransformIdentity] shouldNot] beNil];
		});
	});
	context(@"-CGAffineTransformValue", ^{
		beforeEach(^{
			sut = [NSValue valueWithCGAffineTransform:CGAffineTransformIdentity];
		});
		it(@"should respond to CGAffineTransformValue", ^{
			[[sut should] respondToSelector:@selector(CGAffineTransformValue)];
		});
		it(@"should return the identity matrix", ^{
			[[theValue((BOOL)CGAffineTransformEqualToTransform([sut CGAffineTransformValue], CGAffineTransformIdentity)) should] beYes];
		});
		context(@"when created with valueWithCGAffineTransform", ^{
			beforeEach(^{
				sut = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(M_2_PI)];
			});
			it(@"should have the initialized transform", ^{
				[[theValue((BOOL)CGAffineTransformEqualToTransform([sut CGAffineTransformValue], CGAffineTransformMakeRotation(M_2_PI))) should] beYes];
			});
		});
		context(@"when not created with valueWithCGAffineTransform:", ^{
			beforeEach(^{
				sut = @10;
			});
			it(@"should return an identity transform", ^{
				CGAffineTransform transform = [sut CGAffineTransformValue];
				CGAffineTransform expectedTransform = CGAffineTransformIdentity;
				[[theValue((BOOL)CGAffineTransformEqualToTransform(transform, expectedTransform)) should] beTrue];
			});
		});
	});
	context(@"equality", ^{
		it(@"should treat two identical CGAffineTransforms as equal", ^{
			NSValue *a = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeScale(30, 70)];
			NSValue *b = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeScale(30, 70)];
			[[a should] equal:b];
		});
		it(@"should treat two different CGAffineTransforms not as equal", ^{
			NSValue *a = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeScale(30, 70)];
			NSValue *b = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(M_1_PI)];
			[[a shouldNot] equal:b];
		});
	});
});

SPEC_END
