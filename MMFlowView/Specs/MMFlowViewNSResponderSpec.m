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
});

SPEC_END
