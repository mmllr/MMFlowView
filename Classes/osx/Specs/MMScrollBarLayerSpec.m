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

	context(@"new instance", ^{
		const CGFloat horizontalKnobMargin = 5;
		const CGFloat verticalKnobMargin = 2;

		__block id mockedScrollBarDelegate = nil;
		__block CALayer *knobLayer = nil;
		
		beforeEach(^{
			sut = [[MMScrollBarLayer alloc] init];
			knobLayer = [sut.sublayers firstObject];
			mockedScrollBarDelegate = [KWMock nullMockForProtocol:@protocol(MMScrollBarDelegate)];
		});
		afterEach(^{
			mockedScrollBarDelegate = nil;
			sut = nil;
			knobLayer = nil;
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
		it(@"should have a nil scrollBarDelegate", ^{
			[[(id)sut.scrollBarDelegate should] beNil];
		});
		it(@"should have one sublayer", ^{
			[[sut.sublayers should] haveCountOf:1];
		});
		it(@"should have a MMScrollKnobLayer sublayer", ^{
			[[knobLayer should] beKindOfClass:[MMScrollKnobLayer class]];
		});
		it(@"should have a knob layer at position 5,2", ^{
			NSValue *expectedPosition = [NSValue valueWithPoint:NSMakePoint(horizontalKnobMargin, verticalKnobMargin)];
			[[[NSValue valueWithPoint:knobLayer.frame.origin] should] equal:expectedPosition];
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
		context(NSStringFromSelector(@selector(layoutSublayers)), ^{
			context(@"when the content rect bigger than visible rect", ^{
				const CGFloat contentSize = 2000;
				const CGFloat visibleSize = 500;
				const CGFloat scrollBarWidth = visibleSize * .75;
				const CGFloat effectiveScrollBarWidth = scrollBarWidth - 2*horizontalKnobMargin;
				const CGFloat contentToVisibleAspectRatio = visibleSize / contentSize;
				const CGFloat expectedKnobWidth = effectiveScrollBarWidth * contentToVisibleAspectRatio;
				const CGFloat availableScrollingSize = effectiveScrollBarWidth - expectedKnobWidth;
				const CGFloat minimumKnobWidth = 40.;
				__block CGFloat currentKnobPosition = 0;
				__block CGRect expectedKnobFrame;

				beforeEach(^{
					[mockedScrollBarDelegate stub:@selector(contentSizeForScrollBarLayer:) andReturn:theValue(contentSize)];
					[mockedScrollBarDelegate stub:@selector(visibleSizeForScrollBarLayer:) andReturn:theValue(visibleSize)];
					sut.scrollBarDelegate = mockedScrollBarDelegate;
					[sut stub:@selector(bounds) andReturn:theValue(CGRectMake(0, 0, scrollBarWidth, 20))];
				});
				it(@"should ask the delegate for the content size", ^{
					[[mockedScrollBarDelegate should] receive:@selector(contentSizeForScrollBarLayer:) withArguments:sut];

					[sut layoutSublayers];
				});
				it(@"should ask the delegate for the visible size", ^{
					[[mockedScrollBarDelegate should] receive:@selector(visibleSizeForScrollBarLayer:) withArguments:sut];
					
					[sut layoutSublayers];
				});
				it(@"should ask the delegate for the current knob position", ^{
					[[mockedScrollBarDelegate should] receive:@selector(currentKnobPositionInScrollBarLayer:)];

					[sut layoutSublayers];
				});
				context(@"knob interaction", ^{
					__block MMScrollKnobLayer *mockedKnob = nil;
					
					beforeEach(^{
						mockedKnob = [MMScrollKnobLayer nullMock];
						[sut stub:@selector(sublayers) andReturn:@[mockedKnob]];
					});
					afterEach(^{
						mockedKnob = nil;
					});
					context(@"knob on leftmost position", ^{
						beforeEach(^{
							currentKnobPosition = 0;
							[mockedScrollBarDelegate stub:@selector(currentKnobPositionInScrollBarLayer:) andReturn:theValue(currentKnobPosition)];
							expectedKnobFrame = CGRectMake(horizontalKnobMargin + availableScrollingSize * currentKnobPosition, verticalKnobMargin, expectedKnobWidth, CGRectGetHeight(sut.bounds) - 2*verticalKnobMargin);
						});
						it(@"should set the knob frame", ^{
							[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];

							[sut layoutSublayers];
						});
						it(@"should not be hidden", ^{
							[sut layoutSublayers];
							[[theValue(sut.hidden) should] beNo];
						});
					});
					context(@"knob on mid position", ^{
						beforeEach(^{
							currentKnobPosition = .5;
							[mockedScrollBarDelegate stub:@selector(currentKnobPositionInScrollBarLayer:) andReturn:theValue(currentKnobPosition)];
							expectedKnobFrame = CGRectMake(horizontalKnobMargin + availableScrollingSize * currentKnobPosition, verticalKnobMargin, expectedKnobWidth, CGRectGetHeight(sut.bounds) - 2*verticalKnobMargin);
						});
						it(@"should set the knob frame", ^{
							[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];

							[sut layoutSublayers];
						});
						it(@"should not be hidden", ^{
							[sut layoutSublayers];
							[[theValue(sut.hidden) should] beNo];
						});
					});
					context(@"knob on rightmost position", ^{
						beforeEach(^{
							currentKnobPosition = 1;
							[mockedScrollBarDelegate stub:@selector(currentKnobPositionInScrollBarLayer:) andReturn:theValue(currentKnobPosition)];
							expectedKnobFrame = CGRectMake(horizontalKnobMargin + availableScrollingSize * currentKnobPosition, verticalKnobMargin, expectedKnobWidth, CGRectGetHeight(sut.bounds) - 2*verticalKnobMargin);
						});
						it(@"should set the knob frame", ^{
							[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];
							
							[sut layoutSublayers];
						});
						it(@"should not be hidden", ^{
							[sut layoutSublayers];
							[[theValue(sut.hidden) should] beNo];
						});
					});
					context(@"when delegate returns knob position less than zero", ^{
						beforeEach(^{
							[mockedScrollBarDelegate stub:@selector(currentKnobPositionInScrollBarLayer:) andReturn:theValue(-10)];
							expectedKnobFrame = CGRectMake(horizontalKnobMargin, verticalKnobMargin, expectedKnobWidth, CGRectGetHeight(sut.bounds) - 2*verticalKnobMargin);
						});
						it(@"should set the knob frame to the minimum left position", ^{
							[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];
							
							[sut layoutSublayers];
						});
						it(@"should not be hidden", ^{
							[sut layoutSublayers];
							[[theValue(sut.hidden) should] beNo];
						});
					});
					context(@"when delegate returns knob position greater than one", ^{
						beforeEach(^{
							[mockedScrollBarDelegate stub:@selector(currentKnobPositionInScrollBarLayer:) andReturn:theValue(2)];
							CGFloat expectedPosition = horizontalKnobMargin + effectiveScrollBarWidth - expectedKnobWidth;
							expectedKnobFrame = CGRectMake(expectedPosition, verticalKnobMargin, expectedKnobWidth, CGRectGetHeight(sut.bounds) - 2*verticalKnobMargin);
						});
						it(@"should set the knob frame to the minimum left position", ^{
							[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];
							
							[sut layoutSublayers];
						});
						it(@"should not be hidden", ^{
							[sut layoutSublayers];
							[[theValue(sut.hidden) should] beNo];
						});
					});
					context(@"when visible and content size are greater than zero and equal", ^{
						beforeEach(^{
							[mockedScrollBarDelegate stub:@selector(contentSizeForScrollBarLayer:) andReturn:theValue(100)];
							[mockedScrollBarDelegate stub:@selector(visibleSizeForScrollBarLayer:) andReturn:theValue(100)];
							sut.scrollBarDelegate = mockedScrollBarDelegate;
							expectedKnobFrame = CGRectMake(horizontalKnobMargin, verticalKnobMargin, effectiveScrollBarWidth, CGRectGetHeight(sut.bounds) - 2*verticalKnobMargin);
						});
						it(@"should be hidden", ^{
							[sut layoutSublayers];
							[[theValue(sut.hidden) should] beYes];
						});
						it(@"should set the knob to span complete scroll bar", ^{
							[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];

							[sut layoutSublayers];
						});
					});
					context(@"when content size is way greater than visible size", ^{
						beforeEach(^{
							[mockedScrollBarDelegate stub:@selector(contentSizeForScrollBarLayer:) andReturn:theValue(5000)];
							[mockedScrollBarDelegate stub:@selector(visibleSizeForScrollBarLayer:) andReturn:theValue(10)];
							sut.scrollBarDelegate = mockedScrollBarDelegate;
							expectedKnobFrame = CGRectMake(horizontalKnobMargin, verticalKnobMargin, minimumKnobWidth, CGRectGetHeight(sut.bounds) - 2*verticalKnobMargin);
						});
						it(@"should not be hidden", ^{
							[sut layoutSublayers];
							[[theValue(sut.hidden) should] beNo];
						});
						it(@"should set the knob to the minimum width (40)", ^{
							[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];
							
							[sut layoutSublayers];
						});
					});
					context(@"when visible size is greater than content size", ^{
						beforeEach(^{
							[mockedScrollBarDelegate stub:@selector(contentSizeForScrollBarLayer:) andReturn:theValue(100)];
							[mockedScrollBarDelegate stub:@selector(visibleSizeForScrollBarLayer:) andReturn:theValue(200)];
							sut.scrollBarDelegate = mockedScrollBarDelegate;
							expectedKnobFrame = CGRectMake(horizontalKnobMargin, verticalKnobMargin, effectiveScrollBarWidth, CGRectGetHeight(sut.bounds) - 2*verticalKnobMargin);
						});
						it(@"should be hidden", ^{
							[sut layoutSublayers];
							[[theValue(sut.hidden) should] beYes];
						});
						it(@"should set the knob to span complete scroll bar", ^{
							[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];
							
							[sut layoutSublayers];
						});
					});
					context(@"when delegate gives invalid content or visible size", ^{
						beforeEach(^{
							expectedKnobFrame = CGRectMake(horizontalKnobMargin, verticalKnobMargin, effectiveScrollBarWidth, CGRectGetHeight(sut.bounds) - 2*verticalKnobMargin);
						});
						context(@"when content size is zero", ^{
							beforeEach(^{
								[mockedScrollBarDelegate stub:@selector(contentSizeForScrollBarLayer:) andReturn:theValue(0)];
								sut.scrollBarDelegate = mockedScrollBarDelegate;
							});
							it(@"should be hidden", ^{
								[sut layoutSublayers];
								[[theValue(sut.hidden) should] beYes];
							});
							it(@"should set the knob to span complete scroll bar", ^{
								[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];
								
								[sut layoutSublayers];
							});
						});
						context(@"when visbile size is zero", ^{
							beforeEach(^{
								[mockedScrollBarDelegate stub:@selector(contentSizeForScrollBarLayer:) andReturn:theValue(0)];
								sut.scrollBarDelegate = mockedScrollBarDelegate;
							});
							it(@"should be hidden", ^{
								[sut layoutSublayers];
								[[theValue(sut.hidden) should] beYes];
							});
							it(@"should set the knob to span complete scroll bar", ^{
								[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];
								
								[sut layoutSublayers];
							});
						});
						context(@"when content size is negative", ^{
							beforeEach(^{
								[mockedScrollBarDelegate stub:@selector(contentSizeForScrollBarLayer:) andReturn:theValue(-100)];
								sut.scrollBarDelegate = mockedScrollBarDelegate;
							});
							it(@"should be hidden", ^{
								[sut layoutSublayers];
								[[theValue(sut.hidden) should] beYes];
							});
							it(@"should set the knob to span complete scroll bar", ^{
								[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];
								
								[sut layoutSublayers];
							});
						});
						context(@"when visbile size is negative", ^{
							beforeEach(^{
								[mockedScrollBarDelegate stub:@selector(contentSizeForScrollBarLayer:) andReturn:theValue(-100)];
								sut.scrollBarDelegate = mockedScrollBarDelegate;
							});
							it(@"should be hidden", ^{
								[sut layoutSublayers];
								[[theValue(sut.hidden) should] beYes];
							});
							it(@"should set the knob to span complete scroll bar", ^{
								[[mockedKnob should] receive:@selector(setFrame:) withArguments:theValue(expectedKnobFrame)];
								
								[sut layoutSublayers];
							});
						});
					});
					
				});
				
			});
			context(@"when having a incomplete scrollBarDelegate", ^{
				beforeEach(^{
					mockedScrollBarDelegate = [KWMock nullMock];
					sut.scrollBarDelegate = mockedScrollBarDelegate;
				});
				it(@"should not ask the delegate for the content size", ^{
					[[mockedScrollBarDelegate shouldNot] receive:@selector(contentSizeForScrollBarLayer:)];

					[sut layoutSublayers];
				});
				it(@"should not ask the delegate for the visible size", ^{
					[[mockedScrollBarDelegate shouldNot] receive:@selector(visibleSizeForScrollBarLayer:)];

					[sut layoutSublayers];
				});
				it(@"should not ask the delegate for the current knob position", ^{
					[[mockedScrollBarDelegate shouldNot] receive:@selector(currentKnobPositionInScrollBarLayer:)];

					[sut layoutSublayers];
				});
				it(@"should be hidden", ^{
					[sut layoutSublayers];

					[[theValue(sut.hidden) should] beYes];
				});
			});
		});
		context(NSStringFromSelector(@selector(beginDragAtPoint:)), ^{
			__block CGPoint dragPoint;

			it(@"should respond to beginDragAtPoint:", ^{
				[[sut should] respondToSelector:@selector(beginDragAtPoint:)];
			});
			context(@"mouse point not in knob layer", ^{
				beforeEach(^{
					dragPoint = CGPointMake(CGRectGetMinX(knobLayer.frame) - 10, CGRectGetMinY(knobLayer.frame) - 10);
				});
				it(@"should set the draggingOffset to -1", ^{
					[sut beginDragAtPoint:dragPoint];
					[[theValue(sut.draggingOffset) should] equal:-1 withDelta:.0000001];
				});
			});
			context(@"mouse point in knob layer", ^{
				beforeEach(^{
					dragPoint = CGPointMake(CGRectGetMidX(knobLayer.frame), CGRectGetMinY(knobLayer.frame));
				});
				it(@"should set the draggingOffset to the position of the click on the knob", ^{
					CGFloat expectedOffset = dragPoint.x - CGRectGetMinX(knobLayer.frame);
					[sut beginDragAtPoint:dragPoint];
					[[theValue(sut.draggingOffset) should] equal:expectedOffset withDelta:.0000001];
				});
			});
		});
		context(NSStringFromSelector(@selector(endDrag)), ^{
			it(@"should respond to endDrag", ^{
				[[sut should] respondToSelector:@selector(endDrag)];
			});
			it(@"should set the draggingOffset to -1", ^{
				[sut endDrag];
				[[theValue(sut.draggingOffset) should] equal:-1 withDelta:.0000001];
			});
		});
		context(NSStringFromSelector(@selector(mouseDraggedToPoint:)), ^{
			beforeEach(^{
				[mockedScrollBarDelegate stub:@selector(contentSizeForScrollBarLayer:) andReturn:theValue(1000)];
				[mockedScrollBarDelegate stub:@selector(visibleSizeForScrollBarLayer:) andReturn:theValue(100)];
				sut.scrollBarDelegate = mockedScrollBarDelegate;
				[sut layoutSublayers];
			});

			it(@"should respond to mouseDraggedToPoint:", ^{
				[[sut should] respondToSelector:@selector(mouseDraggedToPoint:)];
			});
			context(@"when in drag", ^{
				__block CGPoint draggedPoint;

				beforeEach(^{
					sut.draggingOffset = 15;
				});
				it(@"should invoke the delegate with position zero when dragging beyound the leftmost position", ^{
					draggedPoint = CGPointMake(CGRectGetMinX(sut.frame) - 10, CGRectGetMidY(sut.frame));

					[[mockedScrollBarDelegate should] receive:@selector(scrollBarLayer:knobDraggedToPosition:) withArguments:sut, theValue(0)];

					[sut mouseDraggedToPoint:draggedPoint];
				});
				it(@"should invoke the delegate with position one when dragging to rightmost position", ^{
					draggedPoint = CGPointMake(CGRectGetMaxX(sut.frame), CGRectGetMidY(sut.frame));

					[[mockedScrollBarDelegate should] receive:@selector(scrollBarLayer:knobDraggedToPosition:) withArguments:sut, theValue(1)];

					[sut mouseDraggedToPoint:draggedPoint];
				});
				it(@"should invoke the delegate with position adjusted by the draggingOffset when dragging to mid position", ^{
					draggedPoint = CGPointMake(CGRectGetMidX(sut.frame) + 10, CGRectGetMidY(sut.frame));

					CGFloat dragPointCorrectedByOffset = draggedPoint.x - sut.draggingOffset;
					CGFloat minX = horizontalKnobMargin;
					CGFloat maxX = CGRectGetMaxX(sut.bounds) - horizontalKnobMargin - CGRectGetWidth(knobLayer.bounds);
					CGFloat scrollWidth = maxX - minX;
					CGFloat expectedPosition = (dragPointCorrectedByOffset - minX) / scrollWidth;
					[[mockedScrollBarDelegate should] receive:@selector(scrollBarLayer:knobDraggedToPosition:) withArguments:sut, theValue(expectedPosition)];
					
					[sut mouseDraggedToPoint:draggedPoint];
				});
				context(@"when scrollBarDelegete does not respond to -scrollBarLayer:knobDraggedToPosition:", ^{
					beforeEach(^{
						mockedScrollBarDelegate = [KWMock nullMock];
						sut.scrollBarDelegate = mockedScrollBarDelegate;
						draggedPoint = CGPointMake(CGRectGetMidX(sut.frame), CGRectGetMidY(sut.frame));
					});
					it(@"should not receive -scrollBarLayer:knobDraggedToPosition:", ^{
						[[mockedScrollBarDelegate shouldNot] receive:@selector(scrollBarLayer:knobDraggedToPosition:)];

						[sut mouseDraggedToPoint:draggedPoint];
					});
				});
			});
			context(@"when not in drag", ^{
				beforeEach(^{
					sut.draggingOffset = -1;
				});
				it(@"should not invoke the scrollbar delegate", ^{
					CGPoint draggedPoint = CGPointMake(CGRectGetMidX(sut.frame), CGRectGetMidY(sut.frame));
					[[mockedScrollBarDelegate shouldNot] receive:@selector(scrollBarLayer:knobDraggedToPosition:)];
					[sut mouseDraggedToPoint:draggedPoint];
				});
			});
		});
		context(NSStringFromSelector(@selector(mouseDownAtPoint:)), ^{
			__block CGPoint mousePoint;
			__block id knobLayerMock = nil;

			beforeEach(^{
				sut.scrollBarDelegate = mockedScrollBarDelegate;
				knobLayerMock = [MMScrollKnobLayer nullMock];

				CGRect knobFrame = CGRectInset(sut.bounds, 30, 5);
				[knobLayerMock stub:@selector(frame) andReturn:theValue(knobFrame)];
				[sut stub:@selector(sublayers) andReturn:@[knobLayerMock]];
			});
			afterEach(^{
				knobLayerMock = nil;
			});

			it(@"should respond to mouseDownAtPoint:", ^{
				[[sut should] respondToSelector:@selector(mouseDownAtPoint:)];
			});
			context(@"when clicking left to knob in layer", ^{
				beforeEach(^{
					mousePoint = CGPointMake(CGRectGetMinX([knobLayerMock frame]) - 10, CGRectGetMidY(sut.bounds));
				});
				it(@"should tell the scrollBarDelegate to perform a decrement action", ^{
					[[mockedScrollBarDelegate should] receive:@selector(decrementClickedInScrollBarLayer:) withArguments:sut];
					[sut mouseDownAtPoint:mousePoint];
				});
				it(@"should not start a drag", ^{
					[[sut shouldNot] receive:@selector(beginDragAtPoint:)];
					
					[sut mouseDownAtPoint:mousePoint];
				});
				context(@"when the scroll bar delegate does not handle the decrement", ^{
					beforeEach(^{
						mockedScrollBarDelegate = [KWMock nullMock];
						sut.scrollBarDelegate = mockedScrollBarDelegate;
					});
					it(@"should not tell the delegate to perform the decrement", ^{
						[[mockedScrollBarDelegate shouldNot] receive:@selector(decrementClickedInScrollBarLayer:)];
						
						[sut mouseDownAtPoint:mousePoint];
					});
				});
			});
			context(@"when clicking right to knob in layer", ^{
				beforeEach(^{
					MMScrollKnobLayer *knob = [sut.sublayers firstObject];

					mousePoint = CGPointMake(CGRectGetMaxX(knob.frame) + 10, CGRectGetMidY(sut.bounds));
				});
				it(@"should tell the scrollBarDelegate to perform a increment action", ^{
					[[mockedScrollBarDelegate should] receive:@selector(incrementClickedInScrollBarLayer:) withArguments:sut];
					
					[sut mouseDownAtPoint:mousePoint];
				});
				it(@"should not start a drag", ^{
					[[sut shouldNot] receive:@selector(beginDragAtPoint:)];
					
					[sut mouseDownAtPoint:mousePoint];
				});
				context(@"when the scroll bar delegate does not handle the increment", ^{
					beforeEach(^{
						mockedScrollBarDelegate = [KWMock nullMock];
						sut.scrollBarDelegate = mockedScrollBarDelegate;
					});
					it(@"should not tell the delegate to perform the increment", ^{
						[[mockedScrollBarDelegate shouldNot] receive:@selector(incrementClickedInScrollBarLayer:)];

						[sut mouseDownAtPoint:mousePoint];
					});
				});
			});
			context(@"when clicking on the knob", ^{
				beforeEach(^{
					MMScrollKnobLayer *knob = [sut.sublayers firstObject];
					
					mousePoint = CGPointMake(CGRectGetMidX(knob.frame), CGRectGetMidY(sut.bounds));
				});
				it(@"should start a drag", ^{
					[[sut should] receive:@selector(beginDragAtPoint:) withArguments:theValue(mousePoint)];

					[sut mouseDownAtPoint:mousePoint];
				});
			});
		});
	});
});

SPEC_END
