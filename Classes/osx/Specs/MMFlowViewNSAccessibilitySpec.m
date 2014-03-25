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
//  MMFlowViewNSAccessibilitySpec.m
//
//  Created by Markus Müller on 17.03.14.
//  Copyright 2014 Markus Müller. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView+NSAccessibility.h"
#import "MMFlowView_Private.h"
#import <objc/runtime.h>

static BOOL testingSuperInvoked = NO;

@interface MMFlowView (MMFlowViewNSAccessibilitySpec)

- (id)mmTesting_accessibilityAttributeValue:(NSString *)attribute;

@end

@implementation MMFlowView (MMFlowViewNSAccessibilitySpec)

- (id)mmTesting_accessibilityAttributeValue:(NSString *)attribute
{
	testingSuperInvoked = YES;
	return nil;
}

@end

SPEC_BEGIN(MMFlowViewNSAccessibilitySpec)

describe(@"MMFlowView+NSAccessibility", ^{
	__block MMFlowView *sut = nil;

	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 400)];
	});
	afterEach(^{
		sut = nil;
	});
	it(@"should not be ignored", ^{
		[[theValue([sut accessibilityIsIgnored]) should] beNo];
	});
	context(NSStringFromSelector(@selector(accessibilityAttributeNames)), ^{
		it(@"should have the expected attributes", ^{
			NSArray *expectedAttributes = @[NSAccessibilityChildrenAttribute,
											NSAccessibilityContentsAttribute,
											NSAccessibilityRoleAttribute,
											NSAccessibilityRoleDescriptionAttribute,
											NSAccessibilityHorizontalScrollBarAttribute];

			[[[sut accessibilityAttributeNames] should] containObjectsInArray:expectedAttributes];
		});
	});
	context(NSStringFromSelector(@selector(accessibilityAttributeValue:)), ^{
		it(@"should have a NSAccessibilityScrollAreaRole role", ^{
			[[[sut accessibilityAttributeValue:NSAccessibilityRoleAttribute] should] equal:NSAccessibilityScrollAreaRole];
		});
		it(@"should have the correct role description", ^{
			NSString *expectedRoleDescription = NSAccessibilityRoleDescriptionForUIElement(sut);

			[[[sut accessibilityAttributeValue:NSAccessibilityRoleDescriptionAttribute] should] equal:expectedRoleDescription];
		});
		it(@"should have two children", ^{
			NSArray *expectedChildren = @[sut.coverFlowLayer, sut.scrollBarLayer];

			[[[sut accessibilityAttributeValue:NSAccessibilityChildrenAttribute] should] equal:expectedChildren];
		});
		it(@"should have the coverFlowLayer as its content", ^{
			[[[sut accessibilityAttributeValue:NSAccessibilityContentsAttribute] should] equal:@[sut.coverFlowLayer]];
		});
		it(@"should have the scroll bar layer as the NSAccessibilityHorizontalScrollBarAttribute", ^{
			[[[sut accessibilityAttributeValue:NSAccessibilityHorizontalScrollBarAttribute] should] equal:sut.scrollBarLayer];
		});
		context(@"unhandled other attributes", ^{
			NSArray *unhandledAttributes = @[NSAccessibilityPositionAttribute, NSAccessibilitySizeAttribute, NSAccessibilityWindowAttribute];

			__block Method supersMethod;
			__block Method testingMethod;
			
			beforeEach(^{
				supersMethod = class_getInstanceMethod([sut superclass], @selector(accessibilityAttributeValue:));
				testingMethod = class_getInstanceMethod([sut class], @selector(mmTesting_accessibilityAttributeValue:));
				method_exchangeImplementations(supersMethod, testingMethod);
			});
			afterEach(^{
				method_exchangeImplementations(testingMethod, supersMethod);
			});
			it(@"should call up to super", ^{
				for (NSString *attribute in unhandledAttributes) {
					testingSuperInvoked = NO;
					[sut accessibilityAttributeValue:attribute];
					[[theValue(testingSuperInvoked) should] beYes];
				}
			});
		});
	});
	context(NSStringFromSelector(@selector(accessibilityHitTest:)), ^{
		__block NSWindow *windowMock = nil;
		__block NSView *contentViewMock = nil;
		__block NSRect hitRect = NSZeroRect;
		NSRect windowRect = NSMakeRect(50, 50, 1, 1);
		CGPoint localPoint = CGPointMake(55, 55);

		beforeEach(^{
			hitRect = NSMakeRect(NSMidX(sut.bounds), NSMidY(sut.bounds), 1, 1);

			contentViewMock = [NSView nullMock];
			[contentViewMock stub:@selector(convertPoint:toView:) andReturn:theValue(localPoint)];
			windowMock = [NSWindow nullMock];
			[windowMock stub:@selector(convertRectFromScreen:) andReturn:theValue(windowRect)];
			[windowMock stub:@selector(contentView) andReturn:contentViewMock];
			[sut stub:@selector(window) andReturn:windowMock];
		});
		afterEach(^{
			windowMock = nil;
		});
		it(@"should convert the hitPoint screen coordinates to window coordinates", ^{
			[[windowMock should] receive:@selector(convertRectFromScreen:) withArguments:theValue(hitRect)];

			[sut accessibilityHitTest:hitRect.origin];
		});
		it(@"should convert the window point to the view coordinate space", ^{
			[[contentViewMock should] receive:@selector(convertPoint:toView:) withArguments:theValue(windowRect.origin), sut];

			[sut accessibilityHitTest:hitRect.origin];
		});
		it(@"should ask for the hit layer in local coordinate space", ^{
			[[sut should] receive:@selector(hitLayerAtPoint:) withArguments:theValue(localPoint)];

			[sut accessibilityHitTest:hitRect.origin];
		});
		context(@"when a layer is hit", ^{
			__block CALayer *hitLayer = nil;

			beforeEach(^{
				hitLayer = [CALayer nullMock];
				[sut stub:@selector(hitLayerAtPoint:) andReturn:hitLayer];
			});
			afterEach(^{
				hitLayer = nil;
			});
			it(@"should return a unignored hit layer", ^{
				[hitLayer stub:@selector(accessibilityIsIgnored) andReturn:theValue(NO)];
				
				[[[sut accessibilityHitTest:hitRect.origin] should] equal:hitLayer];
			});
			it(@"should return the unignored anchestor for an ignored hit layer", ^{
				[hitLayer stub:@selector(accessibilityIsIgnored) andReturn:theValue(YES)];
				[hitLayer stub:@selector(accessibilityAttributeValue:) andReturn:sut withArguments:NSAccessibilityParentAttribute];

				[[[sut accessibilityHitTest:hitRect.origin] should] equal:sut];
			});
			it(@"should return the view for a nil hit layer", ^{
				[sut stub:@selector(hitLayerAtPoint:) andReturn:nil];

				[[[sut accessibilityHitTest:hitRect.origin] should] equal:sut];
			});
		});
	});
});

SPEC_END
