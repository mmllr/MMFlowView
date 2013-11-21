//
//  MMScrollBarLayerSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 14.11.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMScrollBarLayer.h"
#import "MMScrollKnobLayer.h"

SPEC_BEGIN(MMScrollBarLayerSpec)

describe(@"MMScrollBarLayer", ^{
	__block MMScrollBarLayer *sut = nil;
	context(@"creating with CALayer default -init/+layer", ^{
		it(@"should raise if created with +layer", ^{
			[[theBlock(^{
				[MMScrollBarLayer layer];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		it(@"should raise if created with -init", ^{
			[[theBlock(^{
				sut = [[MMScrollBarLayer alloc] init];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
	context(@"new instance created by its designated initalizer", ^{
		__block CAScrollLayer *scrollLayer = nil;

		beforeEach(^{
			scrollLayer = [CAScrollLayer layer];
			scrollLayer.bounds = CGRectMake(0, 0, 50, 50);
			
			for ( int i = 0; i < 10; ++i ) {
				CALayer *layer = [CALayer layer];
				layer.frame = CGRectMake(i * 40, 0, 30, 30);
				[scrollLayer addSublayer:layer];
			}
			sut = [[MMScrollBarLayer alloc] initWithScrollLayer:scrollLayer];
		});
		afterEach(^{
			scrollLayer = nil;
			sut = nil;
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should be of kind MMScrollBarLayer", ^{
			[[sut should] beKindOfClass:[MMScrollBarLayer class]];
		});
		it(@"should be named MMScrollBarLayerName", ^{
			[[sut.name should] equal:@"MMScrollBarLayerName"];
		});
		it(@"should have a black background color", ^{
			[[[NSColor colorWithCGColor:sut.backgroundColor] should] equal:[NSColor blackColor]];
		});
		it(@"should have a gray border color", ^{
			[[[NSColor colorWithCGColor:sut.borderColor] should] equal:[NSColor grayColor]];
		});
		it(@"should be opaque", ^{
			[[theValue(sut.opaque) should] beYes];
		});
		it(@"should have a border width of 1", ^{
			[[theValue(sut.borderWidth) should] equal:theValue(1.)];
		});
		it(@"should have a corner radius of 10", ^{
			[[theValue(sut.cornerRadius) should] equal:theValue(10.)];
		});
		it(@"should have a height of 20", ^{
			[[theValue(CGRectGetHeight(sut.frame)) should] equal:theValue(20)];
		});
		it(@"should have a width of 100", ^{
			[[theValue(CGRectGetWidth(sut.frame)) should] equal:theValue(100)];
		});
		it(@"should have a non nil scroll layer", ^{
			[[sut.scrollLayer shouldNot] beNil];
		});
		it(@"should have the scroll layer with it attached", ^{
			[[sut.scrollLayer should] equal:scrollLayer];
		});
		context(@"scroll layer related", ^{
			it(@"should invoke layoutSublayers when the visible rect of its scroll layer changes", ^{
				[[sut should] receive:@selector(layoutSublayers)];
				[scrollLayer scrollRectToVisible:CGRectMake(50, 0, CGRectGetWidth(scrollLayer.bounds), CGRectGetHeight(scrollLayer.bounds))];
			});
		});
		context(@"constraints", ^{
			__block CAConstraint *constraint =  nil;
			it(@"should have three constraints", ^{
				[[sut.constraints should] haveCountOf:3];
			});
			context(@"super layer midx", ^{
				beforeEach(^{
					constraint = [sut.constraints firstObject];
				});
				afterEach(^{
					constraint = nil;
				});
				it(@"should be relative to its superlayer", ^{
					[[ constraint.sourceName should] equal:@"superlayer"];
				});
				it(@"should have a mid-x sourceAttribute", ^{
					[[theValue(constraint.sourceAttribute) should] equal:theValue(kCAConstraintMidX)];
				});
				it(@"should have a mid-x attribute", ^{
					[[theValue(constraint.attribute) should] equal:theValue(kCAConstraintMidX)];
				});
				it(@"should have a scale of 1", ^{
					[[theValue(constraint.scale) should] equal:theValue(1)];
				});
				it(@"should have an offset of zero", ^{
					[[theValue(constraint.offset) should] beZero];
				});
			});
			context(@"super layer min-y with offset", ^{
				beforeEach(^{
					constraint = sut.constraints[1];
				});
				afterEach(^{
					constraint = nil;
				});
				it(@"should be relative to its superlayer", ^{
					[[ constraint.sourceName should] equal:@"superlayer"];
				});
				it(@"should have a mid-x sourceAttribute", ^{
					[[theValue(constraint.sourceAttribute) should] equal:theValue(kCAConstraintMinY)];
				});
				it(@"should have a mid-x attribute", ^{
					[[theValue(constraint.attribute) should] equal:theValue(kCAConstraintMinY)];
				});
				it(@"should have a scale of 1", ^{
					[[theValue(constraint.scale) should] equal:theValue(1)];
				});
				it(@"should have an offset of 10.", ^{
					[[theValue(constraint.offset) should] equal:theValue(10.)];
				});
			});
			context(@"super layer width 75% scale", ^{
				beforeEach(^{
					constraint = sut.constraints[2];
				});
				afterEach(^{
					constraint = nil;
				});
				it(@"should be relative to its superlayer", ^{
					[[ constraint.sourceName should] equal:@"superlayer"];
				});
				it(@"should have a width sourceAttribute", ^{
					[[theValue(constraint.sourceAttribute) should] equal:theValue(kCAConstraintWidth)];
				});
				it(@"should have a width attribute", ^{
					[[theValue(constraint.attribute) should] equal:theValue(kCAConstraintWidth)];
				});
				it(@"should have an offset of 0.", ^{
					[[theValue(constraint.offset) should] beZero];
				});
				it(@"should have a scale of .75", ^{
					[[theValue(constraint.scale) should] equal:theValue(.75)];
				});
			});
		});
		context(@"CoreAnimation actions", ^{
			__block NSDictionary *actions = nil;
			beforeEach(^{
				actions = sut.actions;
			});
			afterEach(^{
				actions = nil;
			});
			it(@"should have disabled the implicit position action", ^{
				[[actions[@"position"] should] equal:[NSNull null]];
			});
			it(@"should have disabled the implicit bounds action", ^{
				[[actions[@"bounds"] should] equal:[NSNull null]];
			});
		});
		context(@"NSAccessibility", ^{
			it(@"should not be ignored", ^{
				[[theValue([sut accessibilityIsIgnored]) should] beNo];
			});
			it(@"should have a scrollbar role", ^{
				[[[sut accessibilityAttributeValue:NSAccessibilityRoleAttribute] should] equal:NSAccessibilityScrollBarRole];
			});
			it(@"should have a horizontal orientation", ^{
				[[[sut accessibilityAttributeValue:NSAccessibilityOrientationAttribute] should] equal:NSAccessibilityHorizontalOrientationValue];
			});
			it(@"should be enabled", ^{
				[[[sut accessibilityAttributeValue:NSAccessibilityEnabledAttribute] should] beYes];
			});
		});
		context(@"sublayers", ^{
			__block CALayer *knobLayer = nil;

			beforeEach(^{
				knobLayer = [sut.sublayers firstObject];
			});
			afterEach(^{
				knobLayer = nil;
			});

			it(@"should have one sublayer", ^{
				[[sut.sublayers should] haveCountOf:1];
			});
			it(@"should have a MMScrollKnobLayer sublayer", ^{
				[[knobLayer should] beKindOfClass:[MMScrollKnobLayer class]];
			});
			it(@"should have a knob layer at position 5,2", ^{
				NSValue *expectedPosition = [NSValue valueWithPoint:NSMakePoint(5, 2)];
				[[[NSValue valueWithPoint:knobLayer.frame.origin] should] equal:expectedPosition];
			});
			context(@"knob size and position", ^{
				__block CGFloat minX;
				__block CGFloat maxX;
				__block CGFloat scrollAreaWidth = 0;

				beforeEach(^{
					minX = FLT_MAX;
					maxX = FLT_MIN;

					[sut.scrollLayer.sublayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
						minX = MIN( CGRectGetMinX(layer.frame), minX);
						maxX = MAX( CGRectGetMaxX(layer.frame), maxX);
					}];
					scrollAreaWidth = maxX - minX;
				});
				it(@"should have the correct knob width", ^{
					CGFloat visibleWidth = CGRectGetWidth(sut.scrollLayer.visibleRect);
					CGFloat aspectRatio = scrollAreaWidth / visibleWidth;
					CGFloat expectedWidth = CGRectGetWidth(knobLayer.bounds) * aspectRatio + 10.;	// + 10. -> 2*knobmargins
					[[theValue(CGRectGetWidth(sut.bounds)) should] equal:expectedWidth withDelta:0.000001];
				});
				it(@"should have the correct knob position", ^{
					CGFloat scale = CGRectGetMinX(sut.scrollLayer.bounds) / scrollAreaWidth;
					CGFloat effectiveWidth = CGRectGetWidth(sut.bounds) - 10;	// -10. -> 2*knobmargins
					CGFloat expectedX = 5. + scale * effectiveWidth;	// 5. -> left knobmargin
					[[theValue(CGRectGetMinX(knobLayer.frame)) should] equal:expectedX withDelta:0.0000001];
				});
				it(@"should never have a smaller knob width than 10", ^{
					CALayer *bigLayer = [CALayer layer];
					bigLayer.bounds = CGRectMake(0, 0, 3000, 30);
					[scrollLayer addSublayer:bigLayer];
					[[theValue(CGRectGetWidth(knobLayer.bounds)) should] equal:theValue(10)];
				});
			});
		});
	});
});

SPEC_END
