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
		__block NSArray *contentLayers = nil;
		const NSUInteger kNumberOfContentLayers = 10;
		const CGFloat kContentLayerOffset = 40.;
		const CGFloat kContentLayerSize = 30.;

		beforeEach(^{
			scrollLayer = [CAScrollLayer layer];
			scrollLayer.bounds = CGRectMake(0, 0, 50, 50);
			NSMutableArray *layers = [NSMutableArray arrayWithCapacity:kNumberOfContentLayers];

			for ( int i = 0; i < kNumberOfContentLayers; ++i ) {
				CALayer *layer = [CALayer layer];
				layer.frame = CGRectMake(i * kContentLayerOffset, 0, kContentLayerSize, kContentLayerSize);
				[scrollLayer addSublayer:layer];
				[layers addObject:layer];
			}
			contentLayers = [layers copy];
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
		it(@"should have a nil scrollBarDelegate", ^{
			[[(id)sut.scrollBarDelegate should] beNil];
		});
		context(@"scroll layer interaction", ^{
			it(@"should trigger layoutSublayers when the visible rect of its scroll layer changes", ^{
				[[sut should] receive:@selector(layoutSublayers)];
				[scrollLayer scrollRectToVisible:CGRectMake(50, 0, CGRectGetWidth(scrollLayer.bounds), CGRectGetHeight(scrollLayer.bounds))];
			});
			context(@"when removing layers", ^{
				it(@"should invoke layoutSublayers", ^{
					[[sut should] receive:@selector(layoutSublayers)];
					[[contentLayers firstObject] removeFromSuperlayer];
				});
			});
			context(@"adding layers to the scroll layer", ^{
				__block CALayer *newLayer = nil;
				beforeEach(^{
					newLayer = [CALayer layer];
					newLayer.frame = CGRectMake(0, 0, 300, 200);
				});
				afterEach(^{
					newLayer = nil;
				});
				it(@"should invoke layoutSublayers", ^{
					[[sut should] receive:@selector(layoutSublayers)];
					[scrollLayer addSublayer:newLayer];
				});
			});
			context(@"when modifying the frame of a scrollayer sublayer", ^{
				it(@"should trigger relayout when changing the frame of the sublayer", ^{
					[[sut should] receive:@selector(layoutSublayers) withCountAtLeast:1];
					CALayer *layer = [contentLayers firstObject];
					layer.frame = CGRectMake(-100, 0, 400, 200);
				});
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
				context(@"content rect bigger than visible rect", ^{
					__block CGFloat knobWidth = 0;
					__block CGFloat effectiveScrollerWidth = 0;
					__block CGFloat expectedKnobPosition = 0;
					__block CGFloat visibleWidth = 0;
					__block CGFloat aspectRatio = 0;
					__block CGFloat expectedKnobWidth = 0;

					beforeEach(^{
						knobWidth = CGRectGetWidth(knobLayer.bounds);
						effectiveScrollerWidth = CGRectGetWidth(sut.bounds) - 10.;	// - 10. -> 2*knobmargins
						visibleWidth = CGRectGetWidth(sut.scrollLayer.visibleRect);
						aspectRatio = scrollAreaWidth / visibleWidth;
						expectedKnobWidth = MAX( 40, effectiveScrollerWidth / aspectRatio );
					});
					context(@"knob at leftmost position", ^{
						beforeEach(^{
							[sut.scrollLayer scrollToPoint:CGPointMake(0, 0)];
							expectedKnobPosition = 5.;
						});
						it(@"should have the correct knob width", ^{
							[[theValue(knobWidth) should] equal:expectedKnobWidth withDelta:0.000001];
						});
						it(@"should have the correct knob position", ^{
							CGFloat scale = CGRectGetMinX(sut.scrollLayer.bounds) / scrollAreaWidth;
							CGFloat expectedX = 5. + scale * effectiveScrollerWidth;	// 5. -> left knobmargin
							[[theValue(CGRectGetMinX(knobLayer.frame)) should] equal:expectedX withDelta:0.0000001];
						});
					});
					context(@"knob at middle position", ^{
						beforeEach(^{
							[sut.scrollLayer scrollToPoint:CGPointMake(5*kContentLayerOffset, 0)];
						});
						it(@"should have the correct knob width", ^{
							[[theValue(knobWidth) should] equal:expectedKnobWidth withDelta:0.000001];
						});
						it(@"should have the correct knob position", ^{
							CGFloat scale = CGRectGetMinX(sut.scrollLayer.bounds) / scrollAreaWidth;
							CGFloat expectedX = 5. + scale * (effectiveScrollerWidth - knobWidth);	// 5. -> left knobmargin
							[[theValue(CGRectGetMinX(knobLayer.frame)) should] equal:expectedX withDelta:0.0000001];
						});
					});
					context(@"knob at rightmost position", ^{
						beforeEach(^{
							[sut.scrollLayer scrollToPoint:CGPointMake((kNumberOfContentLayers-1)*kContentLayerOffset, 0)];
						});
						it(@"should have the correct knob width", ^{
							[[theValue(knobWidth) should] equal:expectedKnobWidth withDelta:0.000001];
						});
						it(@"should have the correct knob position", ^{
							CGFloat scale = CGRectGetMinX(sut.scrollLayer.bounds) / scrollAreaWidth;
							CGFloat expectedX = 5. + scale * (effectiveScrollerWidth - knobWidth);	// 5. -> left knobmargin
							[[theValue(CGRectGetMinX(knobLayer.frame)) should] equal:expectedX withDelta:0.0000001];
						});
					});
					context(@"scrolling far beyond content", ^{
						it(@"should not exceed the leftmost scrollbar bounds", ^{
							[sut.scrollLayer scrollToPoint:CGPointMake(-kNumberOfContentLayers*2*kContentLayerOffset, 0)];
							CGFloat minXPosition = 5;
							[[theValue(CGRectGetMinX(knobLayer.frame)) should] equal:minXPosition withDelta:0.00001];
						});
						it(@"should not exceed the rightmost scrollbar bounds", ^{
							[sut.scrollLayer scrollToPoint:CGPointMake(kNumberOfContentLayers*2*kContentLayerOffset, 0)];
							CGFloat maxXPosition = CGRectGetMaxX(sut.bounds) - 5 - knobWidth;
							[[theValue(CGRectGetMinX(knobLayer.frame)) should] beLessThanOrEqualTo:theValue(maxXPosition)];
						});
					});
					it(@"should never have a smaller knob width than 40", ^{
						CALayer *bigLayer = [CALayer layer];
						bigLayer.bounds = CGRectMake(0, 0, 3000, 30);
						[scrollLayer addSublayer:bigLayer];
						[[theValue(CGRectGetWidth(knobLayer.bounds)) should] equal:theValue(40.)];
					});
					it(@"should be visible", ^{
						[[theValue(sut.hidden) should] beNo];
					});
				});
				context(@"content rect smaller or equal to visible rect", ^{
					beforeEach(^{
						sut.scrollLayer.bounds = CGRectMake(0, 0, 10000, 100);
					});
					it(@"should be invisible", ^{
						[[theValue(sut.hidden) should] beYes];
					});
				});
				
			});
		});
		context(NSStringFromSelector(@selector(beginDragAtPoint:)), ^{
			__block CGPoint dragPoint;

			it(@"should respond to beginDragAtPoint:", ^{
				[[sut should] respondToSelector:@selector(beginDragAtPoint:)];
			});
			context(@"mouse point not in layer", ^{
				beforeEach(^{
					dragPoint = CGPointMake(CGRectGetMinX(sut.frame) - 10, CGRectGetMinY(sut.frame) - 10);
				});
				it(@"should set the dragOrigin to CGPointZero", ^{
					[[sut should] receive:@selector(setDragOrigin:) withArguments:theValue(CGPointZero)];
					[sut beginDragAtPoint:dragPoint];
					[[theValue(sut.dragOrigin) should] equal:theValue(CGPointZero)];
				});
			});
			context(@"mouse point in layer", ^{
				beforeEach(^{
					dragPoint = CGPointMake(CGRectGetMidX(sut.frame), CGRectGetMinY(sut.frame));
				});
				it(@"should set the dragOrigin", ^{
					[sut beginDragAtPoint:dragPoint];
					[[theValue(sut.dragOrigin) should] equal:theValue(dragPoint)];
				});
			});
		});
		context(NSStringFromSelector(@selector(endDrag)), ^{
			it(@"should respond to endDrag", ^{
				[[sut should] respondToSelector:@selector(endDrag)];
			});
			it(@"should set the dragOrigin to CGPointZero", ^{
				[[sut should] receive:@selector(setDragOrigin:) withArguments:theValue(CGPointZero)];
				[sut endDrag];
				[[theValue(sut.dragOrigin) should] equal:theValue(CGPointZero)];
			});
		});
		context(NSStringFromSelector(@selector(mouseDraggedToPoint:)), ^{
			it(@"should respond to mouseDraggedToPoint:", ^{
				[[sut should] respondToSelector:@selector(mouseDraggedToPoint:)];
			});
			context(@"when in drag", ^{
				beforeEach(^{
					sut.dragOrigin = CGPointMake(CGRectGetMinX(sut.frame), CGRectGetMidY(sut.frame));
				});
			});
		});
	});
});

SPEC_END
