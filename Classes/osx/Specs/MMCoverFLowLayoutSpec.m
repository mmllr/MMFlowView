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
//  MMCoverFLowLayoutSpec.m
//
//  Created by Markus Müller on 18.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMCoverFLowLayout.h"
#import "MMCoverFlowLayoutAttributes.h"
#import "MMMacros.h"

SPEC_BEGIN(MMCoverFLowLayoutSpec)

describe(@"MMCoverFlowLayout", ^{
	__block MMCoverFlowLayout *sut = nil;
	const CGSize visibleSizeFixture = CGSizeMake(200, 200);

	context(@"designated initalizer", ^{
		context(@"too small value for visibleSize", ^{
			beforeEach(^{
				sut = [[MMCoverFlowLayout alloc] initWithVisibleSize:CGSizeMake(-100, -100)];
			});
			it(@"should have a contentHeight of 1", ^{
				[[theValue(sut.visibleSize) should] equal:theValue(CGSizeMake(1, 1))];
			});
		});
		beforeEach(^{
			sut = [[MMCoverFlowLayout alloc] initWithVisibleSize:visibleSizeFixture];
		});
		it(@"should set the contentHeight", ^{
			[[theValue(sut.visibleSize) should] equal:theValue(visibleSizeFixture)];
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
		it(@"should respond to initWithCoder:", ^{
			[[sut should] respondToSelector:@selector(initWithCoder:)];
		});
		it(@"should respond to encodeWithCoder:", ^{
			[[sut should] respondToSelector:@selector(encodeWithCoder:)];
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
		it(@"should have a zero contentSize", ^{
			[[theValue(sut.contentSize) should] equal:theValue(CGSizeZero)];
		});
		it(@"should have a default visibleSize of {100,100}", ^{
			[[theValue(sut.visibleSize) should] equal:theValue(CGSizeMake(100, 100))];
		});
		it(@"should have a default stackedDistance of 300", ^{
			[[theValue(sut.stackedDistance) should] equal:theValue(300)];
		});
		it(@"should return nil for layoutAttributesForItemAtIndex", ^{
			[[[sut layoutAttributesForItemAtIndex:0] should] beNil];
		});
		it(@"should have a nil delegate", ^{
			[[(id)sut.delegate should] beNil];
		});
		context(NSStringFromSelector(@selector(itemSize)), ^{
			it(@"should have an itemHeight of visible height minus two times the vertical margin", ^{
				CGFloat expectedHeight = sut.visibleSize.height - 2*sut.verticalMargin;

				[[theValue(sut.itemSize.height) should] equal:theValue(expectedHeight)];
			});
			it(@"should have a square item size", ^{
				[[theValue(sut.itemSize.width) should] equal:theValue(sut.itemSize.height)];
			});
		});
		context(NSStringFromSelector(@selector(visibleSize)), ^{
			beforeEach(^{
				sut.visibleSize = CGSizeZero;
			});
			it(@"should not have a smaller height smaller than 1", ^{
				[[theValue(sut.visibleSize.height) shouldNot] beLessThan:theValue(1)];
			});
			it(@"should not have a smaller width smaller than 1", ^{
				[[theValue(sut.visibleSize.width) shouldNot] beLessThan:theValue(1)];
			});
		});
		context(NSStringFromSelector(@selector(verticalMargin)), ^{
			it(@"should not be less than 0", ^{
				sut.verticalMargin = -10;
				[[theValue(sut.verticalMargin) shouldNot] beLessThan:theValue(0)];
			});
			it(@"should not be greater than the visible height", ^{
				sut.verticalMargin = sut.visibleSize.height * 2;
				[[theValue(sut.verticalMargin) shouldNot] beGreaterThan:theValue(sut.visibleSize.height)];
			});
		});
		context(NSStringFromSelector(@selector(interItemSpacing)), ^{
			it(@"should not set negative values", ^{
				sut.interItemSpacing = -10;
				[[theValue(sut.interItemSpacing) should] beGreaterThan:theValue(0)];
			});
			it(@"should set the minimum value of 1", ^{
				sut.interItemSpacing = 1.f;
				[[theValue(sut.interItemSpacing) should] equal:theValue(1)];
			});
		});
		context(NSStringFromSelector(@selector(stackedAngle)), ^{
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
		context(NSStringFromSelector(@selector(selectedItemIndex)), ^{
			it(@"should not set the seletion with no items", ^{
				sut.selectedItemIndex = 0;
				[[theValue(sut.selectedItemIndex) should] equal:theValue(NSNotFound)];
			});
		});
		context(NSStringFromSelector(@selector(stackedDistance)), ^{
			it(@"should not set negative values", ^{
				sut.stackedDistance = -100;
				[[theValue(sut.stackedDistance) should] beGreaterThanOrEqualTo:theValue(0)];
			});
		});
		context(@"when having many items (10)", ^{
			beforeEach(^{
				sut.numberOfItems = 10;
			});
			it(@"should select the first item", ^{
				[[theValue(sut.selectedItemIndex) should] equal:theValue(0)];
			});
			it(@"should set the number of items", ^{
				[[theValue(sut.numberOfItems) should] equal:theValue(10)];
			});
			context(@"when selecting items", ^{
				it(@"should select a random item", ^{
					NSUInteger expectedIndex = arc4random_uniform((u_int32_t)sut.numberOfItems);
					sut.selectedItemIndex = expectedIndex;
					
					[[theValue(sut.selectedItemIndex) should] equal:theValue(expectedIndex)];
				});
				it(@"should select the last item", ^{
					sut.selectedItemIndex = sut.numberOfItems - 1;
					[[theValue(sut.selectedItemIndex) should] equal:theValue(9)];
				});
				it(@"should select the first item", ^{
					sut.selectedItemIndex = 0;
					[[theValue(sut.selectedItemIndex) should] equal:theValue(0)];
				});
				it(@"should select the last index if asked to select beyound item count", ^{
					sut.selectedItemIndex = sut.numberOfItems + 10;
					[[theValue(sut.selectedItemIndex) should] equal:theValue(9)];
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
				__block MMCoverFlowLayoutAttributes *expectedAttributes = nil;
				__block CGFloat expectedStackedItemWidth = 0;
				__block CGSize expectedItemSize = CGSizeZero;
				__block CGFloat expectedHorizonzalPosition = 0;
				__block CGFloat expectedVerticalPosition = 0;
				__block CATransform3D leftTransform = CATransform3DIdentity;
				__block CATransform3D rightTransform = CATransform3DIdentity;
				__block NSUInteger testedItemIndex = 0;
				__block CGRect visibleRect = CGRectZero;
				__block CGFloat selectedItemLeftEdge = 0;
				__block CGFloat selectedItemRightEdge = 0;
				
				beforeEach(^{
					CGFloat itemHeight = sut.visibleSize.height - sut.verticalMargin*2;
					expectedItemSize = CGSizeMake(itemHeight, itemHeight);

					expectedVerticalPosition = sut.visibleSize.height / 2 - sut.itemSize.height / 2;

					leftTransform = CATransform3DConcat(CATransform3DMakeRotation(DEGREES2RADIANS(sut.stackedAngle), 0, 1, 0), CATransform3DMakeTranslation(0, 0, -sut.stackedDistance));
					rightTransform = CATransform3DConcat(CATransform3DMakeRotation(-DEGREES2RADIANS(sut.stackedAngle), 0, 1, 0), CATransform3DMakeTranslation(0, 0, -sut.stackedDistance));;
					
					sut.selectedItemIndex = sut.numberOfItems / 2;
					expectedStackedItemWidth = cos(DEGREES2RADIANS(sut.stackedAngle))*sut.itemSize.width + sut.interItemSpacing;

					visibleRect = CGRectMake(0, 0, sut.visibleSize.width, sut.visibleSize.height);
					selectedItemLeftEdge = CGRectGetMidX(visibleRect) - sut.itemSize.width / 2;
					selectedItemRightEdge = CGRectGetMidX(visibleRect) + sut.itemSize.width / 2;

				});
				afterEach(^{
					expectedAttributes = nil;
					attributes = nil;
				});

				context(NSStringFromSelector(@selector(contentSize)), ^{
					__block CGFloat expectedContentWidth;
					
					context(@"selection on both ends of stack", ^{
						beforeEach(^{
							CGFloat stackedWidth = cos(DEGREES2RADIANS(sut.stackedAngle))*sut.itemSize.width + sut.interItemSpacing;
							expectedContentWidth = sut.itemSize.width + stackedWidth * (sut.numberOfItems-1) + sut.itemSize.width;
						});
						context(@"first item selected", ^{
							beforeEach(^{
								sut.selectedItemIndex = 0;
							});
							it(@"should habe a contentWidth of stackedWidth * number of stacked items plus item width plus one interItemSpacing", ^{
								[[theValue(sut.contentSize.width) should] equal:theValue(expectedContentWidth)];
							});
						});
						context(@"last item selected", ^{
							beforeEach(^{
								sut.selectedItemIndex = sut.numberOfItems - 1;
							});
							it(@"should have a contentWidth of stackedWidth * number of stacked items plus item width plus one interItemSpacing", ^{
								[[theValue(sut.contentSize.width) should] equal:theValue(expectedContentWidth)];
							});
						});
					});
					context(@"selection in stack", ^{
						it(@", should habe a contentWidth of stackedWidth * number of stacked items plus item width plus two interItemSpacing", ^{
							CGFloat stackedWidth = cos(DEGREES2RADIANS(sut.stackedAngle))*sut.itemSize.width + sut.interItemSpacing;
							expectedContentWidth = sut.itemSize.width + stackedWidth * (sut.numberOfItems - 1) + sut.itemSize.width * 2;
							[[theValue(sut.contentSize.width) should] equal:theValue(expectedContentWidth)];
						});
					});
				});

				context(NSStringFromSelector(@selector(layoutAttributesForItemAtIndex:)), ^{
					it(@"should return attributes for first item", ^{
						[[[sut layoutAttributesForItemAtIndex:0] shouldNot] beNil];
					});
					it(@"should return attributes for last item", ^{
						[[[sut layoutAttributesForItemAtIndex:sut.numberOfItems - 1] shouldNot] beNil];
					});
					it(@"should return nil when asking for attributes outside bounds", ^{
						[[[sut layoutAttributesForItemAtIndex:sut.numberOfItems + 1] should] beNil];
					});
					context(@"layout delegate interaction", ^{
						__block id delegateMock = nil;

						afterEach(^{
							delegateMock = nil;
						});
						context(@"when the delegate responds to coverFLowLayout:aspectRatioForItem:", ^{
							__block CGSize itemSize = CGSizeZero;
							__block CGFloat testAspectRatio = 1;

							beforeEach(^{
								delegateMock = [KWMock nullMockForProtocol:@protocol(MMCoverFlowLayoutDelegate)];
								sut.delegate = delegateMock;
							});
							it(@"should ask the delegate for the aspect ratio of the item", ^{
								[[delegateMock should] receive:@selector(coverFLowLayout:aspectRatioForItem:) withArguments:sut, theValue(0)];

								[sut layoutAttributesForItemAtIndex:0];
							});
							context(@"when the items height is greater than its width", ^{
								beforeEach(^{
									itemSize = CGSizeMake(200, 100);
									testAspectRatio = itemSize.width/itemSize.height;

									[delegateMock stub:@selector(coverFLowLayout:aspectRatioForItem:) andReturn:theValue(testAspectRatio)];
								});
								it(@"should set the item size according to the aspect ratio from the delegate", ^{
									CGAffineTransform aspectTransform = CGAffineTransformMakeScale(1, 1/testAspectRatio);
									expectedItemSize = CGSizeApplyAffineTransform(expectedItemSize, aspectTransform);

									attributes = [sut layoutAttributesForItemAtIndex:0];
									[[theValue(attributes.bounds.size) should] equal:theValue(expectedItemSize)];
								});
							});
							context(@"when the items height is greater than its width", ^{
								beforeEach(^{
									itemSize = CGSizeMake(100, 200);
									testAspectRatio = itemSize.width/itemSize.height;

									[delegateMock stub:@selector(coverFLowLayout:aspectRatioForItem:) andReturn:theValue(testAspectRatio)];
								});
								it(@"should set the item size according to the aspect ratio from the delegate", ^{
									CGAffineTransform aspectTransform = CGAffineTransformMakeScale(testAspectRatio, 1);
									expectedItemSize = CGSizeApplyAffineTransform(expectedItemSize, aspectTransform);
									
									attributes = [sut layoutAttributesForItemAtIndex:0];
									[[theValue(attributes.bounds.size) should] equal:theValue(expectedItemSize)];
								});
							});
							context(@"when the items height is equal to its width", ^{
								beforeEach(^{
									testAspectRatio = 1;
									
									[delegateMock stub:@selector(coverFLowLayout:aspectRatioForItem:) andReturn:theValue(testAspectRatio)];
								});
								it(@"should have an attribute item size of the layouts itemSize", ^{
									attributes = [sut layoutAttributesForItemAtIndex:0];
									[[theValue(attributes.bounds.size) should] equal:theValue(sut.itemSize)];
								});
							});
						});
						context(@"when the delegate does not respond to coverFLowLayout:aspectRatioForItem:", ^{
							beforeEach(^{
								delegateMock = [KWMock nullMock];
								sut.delegate = delegateMock;
							});
							it(@"should not ask the delegate for the aspect ratio", ^{
								[[delegateMock shouldNot] receive:@selector(coverFLowLayout:aspectRatioForItem:)];

								[sut layoutAttributesForItemAtIndex:0];
							});
							it(@"should have an attribute item size of the layouts itemSize", ^{
								attributes = [sut layoutAttributesForItemAtIndex:0];
								[[theValue(attributes.bounds.size) should] equal:theValue(sut.itemSize)];
							});
						});
					});
				});

				context(@"selected item", ^{
					beforeEach(^{
						expectedHorizonzalPosition = selectedItemLeftEdge;
					});
					
					it(@"should be centered in the horizontally centered visible area for a selected item between the left and the right stack", ^{
						sut.selectedItemIndex = sut.numberOfItems / 2;
						expectedAttributes = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:sut.selectedItemIndex
																					   position:CGPointMake(expectedHorizonzalPosition, expectedVerticalPosition)
																						   size:expectedItemSize
																					anchorPoint:CGPointMake(0.5, 0)
																					  transfrom:CATransform3DIdentity
																					  zPosition:0];
						
						[[[sut layoutAttributesForItemAtIndex:sut.selectedItemIndex] should] equal:expectedAttributes];
					});
					it(@"should be centered in the horizontally centered visible area for the first selected item", ^{
						sut.selectedItemIndex = 0;
						expectedAttributes = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:sut.selectedItemIndex
																					   position:CGPointMake(expectedHorizonzalPosition, expectedVerticalPosition)
																						   size:expectedItemSize
																					anchorPoint:CGPointMake(0.5, 0)
																					  transfrom:CATransform3DIdentity
																					  zPosition:0];
						
						[[[sut layoutAttributesForItemAtIndex:sut.selectedItemIndex] should] equal:expectedAttributes];
					});
					it(@"should be centered in the horizontally centered visible area for the last selected item", ^{
						sut.selectedItemIndex = sut.numberOfItems - 1;
						expectedAttributes = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:sut.selectedItemIndex
																					   position:CGPointMake(expectedHorizonzalPosition, expectedVerticalPosition)
																						   size:expectedItemSize
																					anchorPoint:CGPointMake(0.5, 0)
																					  transfrom:CATransform3DIdentity
																					  zPosition:0];
						
						[[[sut layoutAttributesForItemAtIndex:sut.selectedItemIndex] should] equal:expectedAttributes];
					});
				});

				context(@"left item stack", ^{
					context(@"first item", ^{
						beforeEach(^{
							testedItemIndex = 0;
							expectedHorizonzalPosition = selectedItemLeftEdge - expectedStackedItemWidth * (sut.selectedItemIndex - testedItemIndex)  - sut.itemSize.width;
							attributes = [sut layoutAttributesForItemAtIndex:testedItemIndex];
						});

						it(@"should have the correct attributes", ^{
							expectedAttributes = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:testedItemIndex
																						   position:CGPointMake(expectedHorizonzalPosition, expectedVerticalPosition)
																							   size:expectedItemSize
																						anchorPoint:CGPointMake(0.5, 0)
																						  transfrom:leftTransform
																						  zPosition:0];
							
							[[attributes should] equal:expectedAttributes];
						});
						
						it(@"should have a distance of cos(stackedAngle*itemWidth) plus interItemSpacing to its neighbor", ^{
							MMCoverFlowLayoutAttributes *nextItemAttributes = [sut layoutAttributesForItemAtIndex:testedItemIndex+1];
							CGFloat distance = nextItemAttributes.position.x - attributes.position.x;
							[[theValue(distance) should] equal:expectedStackedItemWidth withDelta:0.000001];
						});
					});
					context(@"left item before the selected item", ^{
						beforeEach(^{
							testedItemIndex = sut.selectedItemIndex - 1;
							expectedHorizonzalPosition = selectedItemLeftEdge - expectedStackedItemWidth * (sut.selectedItemIndex - testedItemIndex) - sut.itemSize.width;
						});
						it(@"should have the correct attributes", ^{
							expectedAttributes = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:testedItemIndex
																						   position:CGPointMake(expectedHorizonzalPosition, expectedVerticalPosition)
																							   size:expectedItemSize
																						anchorPoint:CGPointMake(0.5, 0)
																						  transfrom:leftTransform
																						  zPosition:0];
							[[[sut layoutAttributesForItemAtIndex:testedItemIndex] should] equal:expectedAttributes];
						});
					});
				});
				
				
				context(@"right item stack", ^{
					context(@"item right from the selected item", ^{
						beforeEach(^{
							testedItemIndex = sut.selectedItemIndex + 1;
							expectedHorizonzalPosition = selectedItemRightEdge + expectedStackedItemWidth * (testedItemIndex - sut.selectedItemIndex);
							attributes = [sut layoutAttributesForItemAtIndex:testedItemIndex];
						});
						it(@"should have the correct attributes with the x position of itemIndex*expectedStackedItemWidth plus two times the item width if the first item is not selected", ^{
							expectedAttributes = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:testedItemIndex
																						   position:CGPointMake(expectedHorizonzalPosition, expectedVerticalPosition)
																							   size:expectedItemSize
																						anchorPoint:CGPointMake(0.5, 0)
																						  transfrom:rightTransform
																						  zPosition:0];
							[[attributes should] equal:expectedAttributes];
						});
					});
					context(@"last item selected", ^{
						beforeEach(^{
							testedItemIndex = sut.numberOfItems-1;
							expectedHorizonzalPosition = selectedItemRightEdge + expectedStackedItemWidth * (testedItemIndex - sut.selectedItemIndex);
							attributes = [sut layoutAttributesForItemAtIndex:testedItemIndex];
						});
						it(@"should have the correct attributes with the x position of itemIndex*expectedStackedItemWidth plus two times the item width if the first item is not selected", ^{
							expectedAttributes = [[MMCoverFlowLayoutAttributes alloc] initWithIndex:testedItemIndex
																						   position:CGPointMake(expectedHorizonzalPosition, expectedVerticalPosition)
																							   size:expectedItemSize
																						anchorPoint:CGPointMake(0.5, 0)
																						  transfrom:rightTransform
																						  zPosition:0];
							[[attributes should] equal:expectedAttributes];
						});
					});
				});
			});
		});
		context(NSStringFromProtocol(@protocol(NSCoding)), ^{
			beforeEach(^{
				sut.numberOfItems = 10;
			});
			context(@"non keyed archives", ^{
				it(@"should raise with non keyed archivers", ^{
					[[theBlock(^{
						[NSArchiver archivedDataWithRootObject:sut];
					}) should] raiseWithName:NSInvalidArchiveOperationException];
				});
			});
			context(@"keyed archives", ^{
				__block NSData *archivedData = nil;
				__block MMCoverFlowLayout *unarchivedLayout = nil;

				beforeEach(^{
					archivedData = [NSKeyedArchiver archivedDataWithRootObject:sut];
					unarchivedLayout = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
				});
				afterEach(^{
					archivedData = nil;
					unarchivedLayout = nil;
				});
				it(@"should encode", ^{
					[[archivedData shouldNot] beNil];
				});
				it(@"should decode", ^{
					[[unarchivedLayout shouldNot] beNil];
				});
				it(@"should decode the correct class", ^{
					[[unarchivedLayout should] beKindOfClass:[sut class]];
				});
				it(@"should encode visibleSize", ^{
					[[theValue(unarchivedLayout.visibleSize) should] equal:theValue(sut.visibleSize)];
				});
				it(@"should encode interItemSpacing", ^{
					[[theValue(unarchivedLayout.interItemSpacing) should] equal:theValue(sut.interItemSpacing)];
				});
				it(@"should encode stackedAngle", ^{
					[[theValue(unarchivedLayout.stackedAngle) should] equal:theValue(sut.stackedAngle)];
				});
				it(@"should encode selectedItemIndex", ^{
					[[theValue(unarchivedLayout.selectedItemIndex) should] equal:theValue(sut.selectedItemIndex)];
				});
				it(@"should encode numberOfItems", ^{
					[[theValue(unarchivedLayout.numberOfItems) should] equal:theValue(sut.numberOfItems)];
				});
				it(@"should encode stackedDistance", ^{
					[[theValue(unarchivedLayout.stackedDistance) should] equal:theValue(sut.stackedDistance)];
				});
				it(@"should encode verticalMargin", ^{
					[[theValue(unarchivedLayout.verticalMargin) should] equal:theValue(sut.verticalMargin)];
				});
			});
		});
	});
});

SPEC_END
