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
	context(NSStringFromSelector(@selector(swipeWithEvent:)), ^{
		context(@"when the events absolute deltaX is greater than deltaY", ^{
			beforeEach(^{
				[mockedEvent stub:@selector(deltaX) andReturn:theValue(10)];
				[mockedEvent stub:@selector(deltaY) andReturn:theValue(-5)];
				[sut stub:@selector(selectedIndex) andReturn:theValue(3)];
			});
			it(@"should add deltaX (10) to the selectedIndex (3)", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(3+10)];
				[sut swipeWithEvent:mockedEvent];
			});
		});
		context(@"when the events absolute deltaX is equal to deltaY", ^{
			beforeEach(^{
				[mockedEvent stub:@selector(deltaX) andReturn:theValue(-5)];
				[mockedEvent stub:@selector(deltaY) andReturn:theValue(-5)];
				[sut stub:@selector(selectedIndex) andReturn:theValue(7)];
			});
			it(@"should add deltaX (-5) to the selectedIndex (7)", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(7-5)];
				[sut swipeWithEvent:mockedEvent];
			});
		});
		context(@"when the events absolute deltaX is less than deltaY", ^{
			beforeEach(^{
				[mockedEvent stub:@selector(deltaX) andReturn:theValue(-5)];
				[mockedEvent stub:@selector(deltaY) andReturn:theValue(-6)];
				[sut stub:@selector(selectedIndex) andReturn:theValue(9)];
			});
			it(@"should add deltaY (-6) to the selectedIndex (9)", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(9-6)];
				[sut swipeWithEvent:mockedEvent];
			});
		});
	});
	context(NSStringFromSelector(@selector(scrollWheel:)), ^{
		context(@"when the events absolute deltaX is greater than deltaY", ^{
			beforeEach(^{
				[mockedEvent stub:@selector(deltaX) andReturn:theValue(10)];
				[mockedEvent stub:@selector(deltaY) andReturn:theValue(-5)];
				[sut stub:@selector(selectedIndex) andReturn:theValue(3)];
			});
			it(@"should add deltaX (10) to the selectedIndex (3)", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(3+10)];
				[sut scrollWheel:mockedEvent];
			});
		});
		context(@"when the events absolute deltaX is equal to deltaY", ^{
			beforeEach(^{
				[mockedEvent stub:@selector(deltaX) andReturn:theValue(-5)];
				[mockedEvent stub:@selector(deltaY) andReturn:theValue(-5)];
				[sut stub:@selector(selectedIndex) andReturn:theValue(7)];
			});
			it(@"should add deltaX (-5) to the selectedIndex (7)", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(7-5)];
				[sut scrollWheel:mockedEvent];
			});
		});
		context(@"when the events absolute deltaX is less than deltaY", ^{
			beforeEach(^{
				[mockedEvent stub:@selector(deltaX) andReturn:theValue(-5)];
				[mockedEvent stub:@selector(deltaY) andReturn:theValue(-6)];
				[sut stub:@selector(selectedIndex) andReturn:theValue(9)];
			});
			it(@"should add deltaY (-6) to the selectedIndex (9)", ^{
				[[sut should] receive:@selector(setSelectedIndex:) withArguments:theValue(9-6)];
				[sut scrollWheel:mockedEvent];
			});
		});
	});
});

SPEC_END
