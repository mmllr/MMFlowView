//
//  MMCoverFLowLayoutSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 18.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMCoverFLowLayout.h"
#import "MMCoverFlowLayoutAttributes.h"

SPEC_BEGIN(MMCoverFLowLayoutSpec)

context(@"MMCoverFlowLayout", ^{
	__block MMCoverFlowLayout *sut = nil;

	context(@"designated initalizer", ^{
		context(@"too small value for contentHeight", ^{
			beforeEach(^{
				sut = [[MMCoverFlowLayout alloc] initWithContentHeight:-100];
			});
			it(@"should have a contentHeight of 1", ^{
				[[theValue(sut.contentHeight) should] equal:theValue(1)];
			});
		});
		beforeEach(^{
			sut = [[MMCoverFlowLayout alloc] initWithContentHeight:200];
		});
		it(@"should set the contentHeight", ^{
			[[theValue(sut.contentHeight) should] equal:theValue(200)];
		});
	});
	context(@"a new instance", ^{
		beforeEach(^{
			sut = [[MMCoverFlowLayout alloc] init];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should have the default inter item spacing of 10", ^{
			[[theValue(sut.interItemSpacing) should] equal:theValue(10)];
		});
		it(@"should have a default stacked angle of 70", ^{
			[[theValue(sut.stackedAngle) should] equal:theValue(70)];
		});
		it(@"should have a default selected index of NSNotFound", ^{
			[[theValue(sut.selectedItemIndex) should] equal:theValue(NSNotFound)];
		});
		it(@"should have an item count of 0", ^{
			[[theValue(sut.numberOfItems) should] equal:theValue(0)];
		});
		it(@"should have a default vertical margin of 10", ^{
			[[theValue(sut.verticalMargin) should] equal:theValue(10)];
		});
		it(@"should have a zero contentWidth", ^{
			[[theValue(sut.contentWidth) should] equal:theValue(0)];
		});
		it(@"should have a default contentHeight of 100", ^{
			[[theValue(sut.contentHeight) should] equal:theValue(100)];
		});
		it(@"should have a default stackedDistance of 100", ^{
			[[theValue(sut.stackedDistance) should] equal:theValue(100)];
		});
		it(@"should return nil for layoutAttributesForItemAtIndex", ^{
			[[[sut layoutAttributesForItemAtIndex:0] should] beNil];
		});
		context(@"contentHeight", ^{
			it(@"should not be smaller than 1", ^{
				sut.contentHeight = 0;
				[[theValue(sut.contentHeight) shouldNot] beLessThan:theValue(1)];
			});
		});
		context(@"verticalMargin", ^{
			it(@"should not be less than 0", ^{
				sut.verticalMargin = -10;
				[[theValue(sut.verticalMargin) shouldNot] beLessThan:theValue(0)];
			});
			it(@"should not be greater than the contentHeight", ^{
				sut.verticalMargin = sut.contentHeight * 2;
				[[theValue(sut.verticalMargin) shouldNot] beGreaterThan:theValue(sut.contentHeight)];
			});
		});
		context(@"interItemSpacing", ^{
			it(@"should not set negative values", ^{
				sut.interItemSpacing = -10;
				[[theValue(sut.interItemSpacing) should] beGreaterThan:theValue(0)];
			});
			it(@"should set the minimum value of 1", ^{
				sut.interItemSpacing = 1.f;
				[[theValue(sut.interItemSpacing) should] equal:theValue(1)];
			});
		});
		context(@"stackedAngle", ^{
			it(@"it should set the minimum of 0 for a negative angle", ^{
				sut.stackedAngle = -10;
				[[theValue(sut.stackedAngle) should] equal:theValue(0)];
			});
			it(@"should set the minimum allowed value of 0", ^{
				sut.stackedAngle = 0;
				[[theValue(sut.stackedAngle) should] equal:theValue(0)];
			});
			it(@"should set the maximum value of 90", ^{
				sut.stackedAngle = 90;
				[[theValue(sut.stackedAngle) should] equal:theValue(90)];
			});
			it(@"it should set the maximum of 90 for an angle greater than 90", ^{
				sut.stackedAngle = 100;
				[[theValue(sut.stackedAngle) should] equal:theValue(90)];
			});
		});
		context(@"selectedIndex", ^{
			it(@"should not set the seletion with no items", ^{
				sut.selectedItemIndex = 0;
				[[theValue(sut.selectedItemIndex) should] equal:theValue(NSNotFound)];
			});
		});
		context(@"stackedDistance", ^{
			it(@"should not set negative values", ^{
				sut.stackedDistance = -100;
				[[theValue(sut.stackedDistance) should] beGreaterThanOrEqualTo:theValue(0)];
			});
		});
		context(@"many items", ^{
			beforeEach(^{
				sut.numberOfItems = 10;
			});
			afterEach(^{
				sut.numberOfItems = 0;
			});
			context(@"no previously selected item", ^{
				it(@"should select the first item", ^{
					[[theValue(sut.selectedItemIndex) should] equal:theValue(0)];
				});
			});
			it(@"should set the number of items", ^{
				[[theValue(sut.numberOfItems) should] equal:theValue(10)];
			});
			context(@"selecting items", ^{
				context(@"any item in bounds", ^{
					__block NSUInteger expectedIndex;
	
					beforeEach(^{
						expectedIndex = arc4random_uniform((int32_t)sut.numberOfItems);
						sut.selectedItemIndex = expectedIndex;
					});
					it(@"should set the item", ^{
						[[theValue(sut.selectedItemIndex) should] equal:theValue(expectedIndex)];
					});
				});
				context(@"last item", ^{
					beforeEach(^{
						sut.selectedItemIndex = sut.numberOfItems - 1;
					});
					it(@"should select the last item", ^{
						[[theValue(sut.selectedItemIndex) should] equal:theValue(9)];
					});
					it(@"should select the first item", ^{
						sut.selectedItemIndex = 0;
						[[theValue(sut.selectedItemIndex) should] equal:theValue(0)];
					});
				});
				context(@"selecting beyound bounds", ^{
					beforeEach(^{
						sut.selectedItemIndex = sut.numberOfItems + 10;
					});
					it(@"should select the last index if asked to select beyound item count", ^{
						[[theValue(sut.selectedItemIndex) should] equal:theValue(9)];
					});
				});
				context(@"selecting NSNotFound", ^{
					__block NSUInteger previousSelection;
					
					beforeEach(^{
						previousSelection = sut.selectedItemIndex;
						sut.selectedItemIndex = NSNotFound;
					});
					it(@"should not select NSNotFound", ^{
						[[theValue(sut.selectedItemIndex) shouldNot] equal:theValue(NSNotFound)];
					});
					it(@"should keep the previously selected index", ^{
						[[theValue(sut.selectedItemIndex) should] equal:theValue(previousSelection)];
					});
				});
			});
			context(@"remove all items", ^{
				beforeEach(^{
					sut.numberOfItems = 0;
				});
				it(@"should set numberOfItems to 0", ^{
					[[theValue(sut.numberOfItems) should] equal:theValue(0)];
				});
				it(@"should have a selection of NSNotFound", ^{
					[[theValue(sut.selectedItemIndex) should] equal:theValue(NSNotFound)];
				});
			});
			context(@"invalid number of items", ^{
				__block NSUInteger expectedSelection;
				beforeEach(^{
					expectedSelection = sut.selectedItemIndex;
					sut.numberOfItems = NSNotFound;
				});
				it(@"it should not set NSNotFound for numberOfItems", ^{
					[[theValue(sut.numberOfItems) shouldNot] equal:theValue(NSNotFound)];
				});
				it(@"should not change the selection", ^{
					[[theValue(sut.selectedItemIndex) should] equal:theValue(expectedSelection)];
				});
			});
			context(@"layout attributes", ^{
				__block MMCoverFlowLayoutAttributes *attributes = nil;

				beforeEach(^{
					sut.selectedItemIndex = sut.numberOfItems / 2;
					attributes = [sut layoutAttributesForItemAtIndex:sut.selectedItemIndex];
				});
				afterEach(^{
					attributes = nil;
				});

				context(@"index bound checking", ^{
					it(@"should return attributes for first item", ^{
						[[[sut layoutAttributesForItemAtIndex:0] shouldNot] beNil];
					});
					it(@"should return attributes for last item", ^{
						[[[sut layoutAttributesForItemAtIndex:sut.numberOfItems - 1] shouldNot] beNil];
					});
					it(@"should return nil when asking for attributes outside bounds", ^{
						[[[sut layoutAttributesForItemAtIndex:sut.numberOfItems + 1] should] beNil];
					});
				});
				context(@"item size", ^{
					__block CGFloat expectedHeight;
					beforeEach(^{
						expectedHeight = sut.contentHeight - sut.verticalMargin*2;
					});
					it(@"should have a height of contentHeight - verticalMargin", ^{
						[[theValue(attributes.size.height) should] equal:theValue(expectedHeight)];
					});
					it(@"should have same width as height", ^{
						[[theValue(attributes.size.width) should] equal:theValue(attributes.size.height)];
					});
				});
				context(@"left stack", ^{
					beforeEach(^{
						attributes = [sut layoutAttributesForItemAtIndex:sut.selectedItemIndex - 1];
					});
					afterEach(^{
						attributes = nil;
					});
					it(@"should have the left stack transform", ^{
						NSValue *expectedTransfrom = [NSValue valueWithCATransform3D:CATransform3DMakeRotation((sut.stackedAngle * M_PI / 180.), 0, 1, 0)];
						NSValue *actualTransform = [NSValue valueWithCATransform3D:attributes.transform];

						[[actualTransform should] equal:expectedTransfrom];
					});
					it(@"should have the correct index", ^{
						[[theValue(attributes.index) should] equal:theValue(sut.selectedItemIndex - 1)];
					});
					it(@"should have an anchorPoint of {0, 0.5}", ^{
						NSValue *expectedPoint = [NSValue valueWithPoint:CGPointMake(0, 0.5)];
						[[[NSValue valueWithPoint:attributes.anchorPoint] should] equal:expectedPoint];
					});
					it(@"should have zPosition of negative stackedDistance", ^{
						[[theValue(attributes.zPosition) should] equal:theValue(-sut.stackedDistance)];
					});
				});
				context(@"selection", ^{
					beforeEach(^{
						attributes = [sut layoutAttributesForItemAtIndex:sut.selectedItemIndex];
					});
					afterEach(^{
						attributes = nil;
					});
					it(@"should have an identity transform", ^{
						NSValue *expectedTransfrom = [NSValue valueWithCATransform3D:CATransform3DIdentity];
						[[[NSValue valueWithCATransform3D:attributes.transform] should] equal:expectedTransfrom];
					});
					it(@"should have the correct index", ^{
						[[theValue(attributes.index) should] equal:theValue(sut.selectedItemIndex)];
					});
					it(@"should have an anchorPoint of {0.5, 0.5}", ^{
						NSValue *expectedPoint = [NSValue valueWithPoint:CGPointMake(0.5, 0.5)];
						[[[NSValue valueWithPoint:attributes.anchorPoint] should] equal:expectedPoint];
					});
					it(@"should have a 0 zPosition", ^{
						[[theValue(attributes.zPosition) should] equal:theValue(0)];
					});
				});
				context(@"right stack", ^{
					beforeEach(^{
						attributes = [sut layoutAttributesForItemAtIndex:sut.selectedItemIndex + 1];
					});
					afterEach(^{
						attributes = nil;
					});
					it(@"should have the right stack transform", ^{
						NSValue *expectedTransfrom = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-(sut.stackedAngle * M_PI / 180.), 0, 1, 0)];
						
						[[[NSValue valueWithCATransform3D:attributes.transform] should] equal:expectedTransfrom];
					});
					it(@"should have the correct index", ^{
						[[theValue(attributes.index) should] equal:theValue(sut.selectedItemIndex + 1)];
					});
					it(@"should have an anchorPoint of {1, 0.5}", ^{
						NSValue *expectedPoint = [NSValue valueWithPoint:CGPointMake(1, 0.5)];
						[[[NSValue valueWithPoint:attributes.anchorPoint] should] equal:expectedPoint];
					});
					it(@"should have zPosition of negative stackedDistance", ^{
						[[theValue(attributes.zPosition) should] equal:theValue(-sut.stackedDistance)];
					});
				});
			});
		});
	});
});

SPEC_END
