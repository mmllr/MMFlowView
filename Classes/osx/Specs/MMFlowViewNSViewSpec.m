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
//  MMFlowViewNSViewSpec.m
//
//  Created by Markus Müller on 01.04.14.
//  Copyright 2014 Markus Müller. All rights reserved.
//

#import <objc/runtime.h>

#import "Kiwi.h"
#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+NSKeyValueObserving.h"
#import "MMTestImageItem.h"

static BOOL testingSuperInvoked = NO;

@interface MMFlowView (MMFlowViewNSViewSpec)

- (void)mmTesting_viewWillMoveToSuperview:(NSView *)newSuperview;

@end

@implementation MMFlowView (MMResponderTests)

- (void)mmTesting_viewWillMoveToSuperview:(NSView *)newSuperview
{
	testingSuperInvoked = YES;
}

@end

SPEC_BEGIN(MMFlowViewNSViewSpec)

describe(@"NSView overrides", ^{
	__block MMFlowView *sut = nil;

	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	});
	afterEach(^{
		sut = nil;
	});
	it(@"should not be flipped", ^{
		[[theValue([sut isFlipped]) should] beNo];
	});
	it(@"should be opaque", ^{
		[[theValue([sut isOpaque]) should] beYes];
	});
	it(@"should need panel to become to key", ^{
		[[theValue([sut needsPanelToBecomeKey]) should] beYes];
	});
	it(@"should accept touch events", ^{
		[[theValue([sut acceptsTouchEvents]) should] beYes];
	});
	it(@"should have no intrinsinc content size", ^{
		NSSize expectedContentSite = NSMakeSize(NSViewNoInstrinsicMetric, NSViewNoInstrinsicMetric);
		
		[[theValue(sut.intrinsicContentSize) should] equal:theValue(expectedContentSite)];
	});
	it(@"should not translate autoresizing mask into constraints", ^{
		[[theValue([sut translatesAutoresizingMaskIntoConstraints]) should] beNo];
	});
	context(NSStringFromSelector(@selector(viewWillMoveToSuperview:)), ^{
		__block NSView *superViewMock = nil;

		beforeEach(^{
			superViewMock = [NSView nullMock];
		});
		afterEach(^{
			superViewMock = nil;
		});

		context(@"when removed from view hierarchy and bound to a content array", ^{
			__block NSArray *contentArray = nil;
			__block id itemMock = nil;
			__block NSArrayController *controller = nil;

			beforeEach(^{
				itemMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewItem)];
				contentArray = @[itemMock, itemMock, itemMock, itemMock];
				controller = [[NSArrayController alloc] initWithContent:contentArray];
				[controller setObjectClass:[MMTestImageItem class]];
				[sut bind:NSContentArrayBinding toObject:controller withKeyPath:@"arrangedObjects" options:nil];
				[sut stub:@selector(superview) andReturn:superViewMock];
			});
			afterEach(^{
				contentArray = nil;
				controller = nil;
			});
			it(@"should unbind from the NSContentArrayBinding", ^{
				[[sut should] receive:@selector(unbind:) withArguments:NSContentArrayBinding];

				[sut viewWillMoveToSuperview:nil];
			});
			it(@"should not have a content array binding", ^{
				[sut viewWillMoveToSuperview:nil];
				[[[sut infoForBinding:NSContentArrayBinding] should] beNil];
			});
		});

		context(@"invoking supers implementation", ^{
			__block Method supersMethod;
			__block Method testingMethod;
			
			beforeEach(^{
				supersMethod = class_getInstanceMethod([sut superclass], @selector(viewWillMoveToSuperview:));
				testingMethod = class_getInstanceMethod([sut class], @selector(mmTesting_viewWillMoveToSuperview:));
				method_exchangeImplementations(supersMethod, testingMethod);
			});
			afterEach(^{
				method_exchangeImplementations(testingMethod, supersMethod);
			});
			it(@"should call up to super", ^{
				testingSuperInvoked = NO;
				[sut viewWillMoveToSuperview:superViewMock];
				[[theValue(testingSuperInvoked) should] beYes];
			});
		});
	});
});

SPEC_END
