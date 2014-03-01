//
//  MMFlowViewNSResponderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 19.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView+NSResponder.h"
#import "MMFlowView_Private.h"
#import "NSEvent+MMAdditions.h"
#import "MMScrollBarLayer.h"
#import <objc/runtime.h>

static BOOL testingSuperInvoked = NO;

@interface MMFlowView (MMResponderTests)

- (void)mmTesting_keyDown:(NSEvent *)theEvent;

@end

@implementation MMFlowView (MMResponderTests)

- (void)mmTesting_keyDown:(NSEvent *)theEvent
{
	testingSuperInvoked = YES;
}

@end

SPEC_BEGIN(MMFlowViewNSResponderSpec)

describe(@"MMFlowView+NSResponder", ^{
	__block MMFlowView *sut = nil;
	__block NSEvent *mockedEvent = nil;
	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
		mockedEvent = [NSEvent nullMock];
	});
	afterEach(^{
		sut = nil;
		mockedEvent = nil;
	});
	it(@"should have an action cell class", ^{
		[[[[sut class] cellClass] should] equal:[NSActionCell class]];
	});
	it(@"should accept being first responder", ^{
		[[theValue([sut acceptsFirstResponder]) should] beYes];
	});
	context(NSStringFromSelector(@selector(mouseEntered:)), ^{
		it(@"should invoke mouseEnteredSelection", ^{
			[[sut should] receive:@selector(mouseEnteredSelection)];
			[sut mouseEntered:mockedEvent];
		});
	});
	context(NSStringFromSelector(@selector(mouseExited:)), ^{
		it(@"should invoke mouseEnteredSelection", ^{
			[[sut should] receive:@selector(mouseExitedSelection)];
			[sut mouseExited:mockedEvent];
		});
	});
	context(NSStringFromSelector(@selector(keyDown:)), ^{
		context(@"invoking supers implementation", ^{
			__block Method supersMethod;
			__block Method testingMethod;
			
			beforeEach(^{
				supersMethod = class_getInstanceMethod([sut superclass], @selector(keyDown:));
				testingMethod = class_getInstanceMethod([sut class], @selector(mmTesting_keyDown:));
				method_exchangeImplementations(supersMethod, testingMethod);
			});
			afterEach(^{
				method_exchangeImplementations(testingMethod, supersMethod);
			});
			it(@"should call up to super", ^{
				testingSuperInvoked = NO;
				[sut keyDown:mockedEvent];
				[[theValue(testingSuperInvoked) should] beYes];
			});
		});
		context(@"quicklook panel", ^{
			context(@"when controlling quicklook panel is turned off", ^{
				beforeEach(^{
					sut.canControlQuickLookPanel = NO;
				});
				it(@"should not invoke togglePreview:", ^{
					[[sut shouldNot] receive:@selector(togglePreviewPanel:)];
				});
			});
			context(@"when controlling quicklook panel is turned on", ^{
				beforeEach(^{
					sut.canControlQuickLookPanel = YES;
				});
				context(@"when the space key is pressed", ^{
					beforeEach(^{
						[mockedEvent stub:@selector(characters) andReturn:@" "];
					});
					it(@"should receive togglePreviewPanel:", ^{
						[[sut should] receive:@selector(togglePreviewPanel:) withArguments:sut];
						[sut keyDown:mockedEvent];
					});
				});
				it(@"should not invoke togglePreview:", ^{
					[[sut shouldNot] receive:@selector(togglePreviewPanel:)];
					[sut keyDown:mockedEvent];
				});
			});
		});
	});
	context(@"scrolling and swiping", ^{
		beforeEach(^{
			[mockedEvent stub:@selector(dominantDeltaInXYSpace) andReturn:theValue(3)];
			[sut stub:@selector(selectedIndex) andReturn:theValue(3)];
		});
		context(NSStringFromSelector(@selector(swipeWithEvent:)), ^{
			it(@"should ask the event for its dominant delta", ^{
				[[mockedEvent should] receive:@selector(dominantDeltaInXYSpace)];
				[sut swipeWithEvent:mockedEvent];
			});
			it(@"should add the dominant delta to the selected index", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(3+3)];
				[sut swipeWithEvent:mockedEvent];
			});
		});
		context(NSStringFromSelector(@selector(scrollWheel:)), ^{
			it(@"should ask the event for its dominant delta", ^{
				[[mockedEvent should] receive:@selector(dominantDeltaInXYSpace)];
				[sut swipeWithEvent:mockedEvent];
			});
			it(@"should add the dominant delta to the selected index", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(3+3)];
				[sut scrollWheel:mockedEvent];
			});
		});
	});
	context(NSStringFromSelector(@selector(mouseUp:)), ^{
		it(@"should disable dragging", ^{
			[[sut should] receive:@selector(setDraggingKnob:) withArguments:theValue(NO)];
			[sut mouseUp:mockedEvent];
		});
		it(@"should not drag the knob", ^{
			[[theValue(sut.draggingKnob) should] beNo];
		});
	});
	context(NSStringFromSelector(@selector(rightMouseUp:)), ^{
		__block id mockedDelegate = nil;

		afterEach(^{
			mockedDelegate = nil;
		});

		context(@"when the delegate supports right clicks", ^{
			NSPoint pointInWindow = NSMakePoint(10, 10);

			beforeEach(^{
				mockedDelegate = [KWMock nullMockForProtocol:@protocol(MMFlowViewDelegate)];
				sut.delegate = mockedDelegate;
				[mockedEvent stub:@selector(locationInWindow) andReturn:theValue(pointInWindow)];
			});
			it(@"should ask the event for the mouse location", ^{
				[[mockedEvent should] receive:@selector(locationInWindow)];
				[sut rightMouseUp:mockedEvent];
			});
			it(@"should ask for the item at the mouse position in view coordinates", ^{
				NSPoint expectedPoint = [sut convertPoint:pointInWindow fromView:nil];
				[[sut should] receive:@selector(indexOfItemAtPoint:) withArguments:theValue(expectedPoint)];
				[sut rightMouseUp:mockedEvent];
			});
			context(@"when an item was clicked", ^{
				const NSUInteger expectedItemIndex = 3;
				beforeEach(^{
					[sut stub:@selector(indexOfItemAtPoint:) andReturn:theValue(expectedItemIndex)];
				});
				it(@"should ask the delegate to handle the click", ^{
					[[mockedDelegate should] receive:@selector(flowView:itemWasRightClickedAtIndex:withEvent:) withArguments:sut, theValue(expectedItemIndex), mockedEvent];
					[sut rightMouseUp:mockedEvent];
				});
			});
			context(@"when no item was clicked", ^{
				beforeEach(^{
					[sut stub:@selector(indexOfItemAtPoint:) andReturn:theValue(NSNotFound)];
				});
				it(@"should ask the delegate to handle the click", ^{
					[[mockedDelegate shouldNot] receive:@selector(flowView:itemWasRightClickedAtIndex:withEvent:)];
					[sut rightMouseUp:mockedEvent];
				});
			});
		});
		context(@"when the delegate does supports right clicks", ^{
			beforeEach(^{
				mockedDelegate = [KWMock nullMock];
				sut.delegate = mockedDelegate;
			});
			it(@"should not ask the delegate to handle the click", ^{
				[[mockedDelegate shouldNot] receive:@selector(flowView:itemWasRightClickedAtIndex:withEvent:)];
				[sut rightMouseUp:mockedEvent];
			});
		});
	});
	context(NSStringFromSelector(@selector(mouseDragged:)), ^{
		context(@"scroll bar layer interaction", ^{
			__block MMScrollBarLayer *mockedScrollBarLayer = nil;
			__block CALayer *mockedLayer = nil;
			__block CGPoint pointInScrollLayer;
			NSPoint pointInWindow = NSMakePoint(10, 10);

			beforeEach(^{
				[mockedEvent stub:@selector(locationInWindow) andReturn:theValue(pointInWindow)];

				mockedLayer = [CALayer nullMock];
				pointInScrollLayer = CGPointMake(30, 7);
				[mockedLayer stub:@selector(convertPoint:toLayer:) andReturn:theValue(pointInScrollLayer)];
				[sut stub:@selector(layer) andReturn:mockedLayer];

				mockedScrollBarLayer = [MMScrollBarLayer nullMock];
				sut.scrollBarLayer = mockedScrollBarLayer;
			});
			afterEach(^{
				mockedScrollBarLayer = nil;
				mockedLayer = nil;
			});
			it(@"should ask the layer to convert the mouse point to the scrollbar layers coordinate space", ^{
				[[mockedLayer should] receive:@selector(convertPoint:toLayer:) withArguments:[KWAny any], mockedScrollBarLayer];
				[sut mouseDragged:mockedEvent];
			});
			it(@"should notify the scroll bar layer about the drag", ^{
				[[mockedScrollBarLayer should] receive:@selector(mouseDraggedToPoint:) withArguments:theValue(pointInScrollLayer)];
				[sut mouseDragged:mockedEvent];
			});
		});
	});
});

SPEC_END
