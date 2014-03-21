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
//  MMFlowViewSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMMacros.h"
#import "MMFlowViewImageCache.h"
#import "MMFlowViewImageFactory.h"
#import "MMImageDecoderProtocol.h"
#import "MMCoverFlowLayer.h"
#import "MMCoverFlowLayout.h"
#import "MMScrollBarLayer.h"

SPEC_BEGIN(MMFlowViewSpec)

describe(@"MMFlowView", ^{
	context(@"a new instance", ^{
		__block MMFlowView *sut = nil;
		__block NSArray *mockedItems = nil;
		const NSInteger numberOfItems = 10;
		const NSRect initialFrame = NSMakeRect(0, 0, 400, 300);

		beforeAll(^{
			NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:numberOfItems];
			for ( NSInteger i = 0; i < numberOfItems; ++i) {
				NSString *titleString = [NSString stringWithFormat:@"%ld", (long)i];
				// item
				id itemMock = [KWMock mockForProtocol:@protocol(MMFlowViewItem)];
				[itemMock stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewNSImageRepresentationType];
				[itemMock stub:@selector(imageItemUID) andReturn:titleString];
				[itemMock stub:@selector(imageItemTitle) andReturn:titleString];
				id imageMock = [NSImage nullMock];
				[itemMock stub:@selector(imageItemRepresentation) andReturn:imageMock];
				[itemArray addObject:itemMock];
			}
			mockedItems = [itemArray copy];
		});
		afterAll(^{
			mockedItems = nil;
		});
		beforeEach(^{
			sut = [[MMFlowView alloc] initWithFrame:initialFrame];
		});
		afterEach(^{
			sut = nil;
		});

		context(@"class related", ^{
			it(@"should be of MMFlowView class", ^{
				[[sut should] beKindOfClass:[MMFlowView class]];
			});
		});
		context(@"NSView overrides", ^{
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
		});
		context(NSStringFromSelector(@selector(visibleItemIndexes)), ^{
			it(@"should not be nil", ^{
				[[sut.visibleItemIndexes shouldNot] beNil];
			});
			it(@"should have count of zero", ^{
				[[sut.visibleItemIndexes should] haveCountOf:0];
			});
		});
		context(NSStringFromSelector(@selector(stackedAngle)), ^{
			it(@"should have a default stacked angle of 70", ^{
				[[theValue(sut.stackedAngle) should] equal:theValue(70)];
			});
			context(@"setting its value", ^{
				beforeEach(^{
					sut.stackedAngle = 50;
				});
				it(@"should change the stacked angle", ^{
					[[theValue(sut.stackedAngle) should] equal:theValue(50)];
				});
				it(@"should change the cover flow layout", ^{
					[[theValue(sut.coverFlowLayout.stackedAngle) should] equal:theValue(sut.stackedAngle)];
				});
			});
		});
		context(NSStringFromSelector(@selector(selectedItemFrame)), ^{
			it(@"should initially have a selectedItemFrame of NSZeroRect", ^{
				NSValue *expectedFrame = [NSValue valueWithRect:NSZeroRect];
				[[[NSValue valueWithRect:sut.selectedItemFrame] should] equal:expectedFrame];
			});
		});
		context(NSStringFromSelector(@selector(spacing)), ^{
			it(@"should have a default spacing of 50", ^{
				[[theValue(sut.spacing) should] equal:theValue(50)];
			});
			context(@"setting its value", ^{
				beforeEach(^{
					sut.spacing = 100;
				});
				it(@"should change the spacing", ^{
					[[theValue(sut.spacing) should] equal:theValue(100)];
				});
				it(@"should change the underlying layout", ^{
					[[theValue(sut.coverFlowLayout.interItemSpacing) should] equal:theValue(sut.spacing)];
				});
			});
		});
		context(NSStringFromSelector(@selector(showsReflection)), ^{
			it(@"should not initially show reflections", ^{
				[[theValue(sut.showsReflection) should] beNo];
			});
			context(@"setting", ^{
				beforeEach(^{
					sut.showsReflection = YES;
				});
				it(@"should be enabled", ^{
					[[theValue(sut.showsReflection) should] beYes];
				});
				it(@"should enable it on the coverFlowLayer", ^{
					[[theValue(sut.coverFlowLayer.showsReflection) should] beYes];
				});
				context(@"disabling", ^{
					beforeEach(^{
						sut.showsReflection = NO;
					});
					it(@"should be disabled", ^{
						[[theValue(sut.showsReflection) should] beNo];
					});
					it(@"should enable it on the coverFlowLayer", ^{
						[[theValue(sut.coverFlowLayer.showsReflection) should] beNo];
					});
				});
			});
		});
		context(NSStringFromSelector(@selector(reflectionOffset)), ^{
			it(@"should have a reflectionOffset of -.4", ^{
				[[theValue(sut.reflectionOffset) should] equal:-.4 withDelta:.0000001];
			});
			context(@"setting", ^{
				beforeEach(^{
					sut.reflectionOffset = -.7;
				});
				it(@"should be -.7", ^{
					[[theValue(sut.reflectionOffset) should] equal:-.7 withDelta:0.000001];
				});
				it(@"should set the coverFlowLayers reflectionOffset", ^{
					[[theValue(sut.coverFlowLayer.reflectionOffset) should] equal:-.7 withDelta:0.0000001];
				});
			});
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should have no items", ^{
			[[theValue(sut.numberOfItems) should] equal:theValue(0)];
		});
		it(@"shoud have no item selected", ^{
			[[theValue(sut.selectedIndex) should] equal:theValue(NSNotFound)];
		});
		it(@"should have an empty title", ^{
			[[sut.title should] equal:@""];
		});
		it(@"should have a title size of 18", ^{
			[[theValue(sut.titleSize) should] equal:theValue(18)];
		});
		it(@"should be registered for url pasteboard type", ^{
			[[[sut registeredDraggedTypes] should] contain:NSURLPboardType];
		});
		it(@"should have an empty datasource", ^{
			[[(id)sut.dataSource should] beNil];
		});
		context(@"image cache", ^{
			it(@"should have an image cache", ^{
				[[(id)sut.imageCache shouldNot] beNil];
			});
			it(@"should conform to the MMFlowViewImageCache protocol", ^{
				[[((id)sut.imageCache) should] conformToProtocol:@protocol(MMFlowViewImageCache)];
			});
		});
		context(@"image factory", ^{
			it(@"should have an image factory", ^{
				[[sut.imageFactory shouldNot] beNil];
			});
			it(@"should be a MMFlowViewImageFactory class", ^{
				[[sut.imageFactory should] beKindOfClass:[MMFlowViewImageFactory class]];
			});
			it(@"should have a cache", ^{
				[[(id)sut.imageFactory.cache shouldNot] beNil];
			});
			it(@"should have the flowviews image cache", ^{
				[[(id)sut.imageFactory.cache should] equal:sut.imageCache];
			});
		});
		context(@"live resizing", ^{
			context(@"coverflow layer related", ^{
				beforeEach(^{
					[sut viewWillStartLiveResize];
				});
				it(@"should set the live resizing status to the MMCoverFLowLayer", ^{
					[[theValue(sut.coverFlowLayer.inLiveResize) should] beYes];
				});
				it(@"should end the live resizing to the MMCoverFlowLayer", ^{
					[sut viewDidEndLiveResize];
					[[theValue(sut.coverFlowLayer.inLiveResize) should] beNo];
				});
			});
		});
		
		context(@"delegate", ^{
			it(@"should have an empty delegate", ^{
				[[(id)sut.delegate should] beNil];
			});
		});
		context(@"changing the selection", ^{
			beforeEach(^{
				sut.selectedIndex = 0;
			});
			it(@"should do nothing", ^{
				[[theValue(sut.selectedIndex) should] equal:theValue(NSNotFound)];
			});
			it(@"should have an empty title", ^{
				sut.title = @"";
			});
		});
		
		context(@"layers", ^{
			beforeEach(^{
				[sut.layer layoutSublayers];
			});
			it(@"should be layer backed", ^{
				[[theValue([sut wantsLayer]) should] beYes];
			});
			it(@"should have a layer attached", ^{
				[[[sut layer] shouldNot] beNil];
			});
			context(@"backgroundLayer property", ^{
				it(@"should have a background layer", ^{
					[[sut.backgroundLayer shouldNot] beNil];
				});
				it(@"should have the background layer as its view layer", ^{
					[[[sut layer] should] equal:sut.backgroundLayer];
				});
				it(@"should be a gradient layer", ^{
					[[sut.backgroundLayer should] beKindOfClass:[CAGradientLayer class]];
				});
				it(@"should horizontally autoresize", ^{
					[[theValue(sut.backgroundLayer.autoresizingMask & kCALayerWidthSizable)should] beTrue];
				});
				it(@"should vertically autoresize", ^{
					[[theValue(sut.backgroundLayer.autoresizingMask & kCALayerHeightSizable)should] beTrue];
				});
				it(@"should have a layout manager", ^{
					[[sut.backgroundLayer.layoutManager shouldNot] beNil];
				});
				it(@"should have a constraint layout manager", ^{
					[[sut.backgroundLayer.layoutManager should] beKindOfClass:[CAConstraintLayoutManager class]];
				});
				it(@"should have the colors", ^{
					NSArray *expectedColors = @[(__bridge id)[ [ NSColor colorWithCalibratedRed:52.f / 255.f green:55.f / 255.f blue:69.f / 255.f alpha:1.f ] CGColor ],
												(__bridge id)[ [ NSColor colorWithCalibratedRed:36.f / 255.f green:37.f / 255.f blue:48.f / 255.f alpha:1.f ] CGColor ],
												(__bridge id)[[ NSColor blackColor ] CGColor ]];
					[[((CAGradientLayer*)sut.backgroundLayer).colors should] equal:expectedColors];
				});
				it(@"should have the positions", ^{
					NSArray *expectedLocations = @[@0.,@.2,@1.];
					CAGradientLayer *gradientLayer = (CAGradientLayer*)sut.backgroundLayer;
					[[gradientLayer.locations should] equal:expectedLocations];
				});
				it(@"should have a zero position", ^{
					NSValue *actualPosition = [NSValue valueWithPoint:sut.backgroundLayer.position];
					[[actualPosition should] equal:[NSValue valueWithPoint:CGPointZero]];
				});
				it(@"should match the views bounds", ^{
					NSValue *actualBounds = [NSValue valueWithRect:sut.backgroundLayer.bounds];
					NSValue *viewBounds = [NSValue valueWithRect:[sut bounds]];
					[[actualBounds should] equal:viewBounds];
				});
				it(@"should be have a frame origin of 0,0", ^{
					NSValue *expectedPoint = [NSValue valueWithPoint:NSMakePoint(0, 0)];
					[[[NSValue valueWithPoint:sut.backgroundLayer.frame.origin] should] equal:expectedPoint];
				});
			});
			context(NSStringFromSelector(@selector(coverFlowLayer)), ^{
				it(@"should be set", ^{
					[[sut.coverFlowLayer shouldNot] beNil];
				});
				it(@"should have type MMCoverFlowLayer", ^{
					[[sut.coverFlowLayer should] beKindOfClass:[MMCoverFlowLayer class]];
				});
				it(@"should be a sublayer of the container layer", ^{
					[[sut.containerLayer.sublayers should] contain:sut.coverFlowLayer];
				});
				it(@"should have the same width as the view", ^{
					[[theValue(CGRectGetWidth(sut.coverFlowLayer.bounds)) should] equal:theValue(CGRectGetWidth(sut.bounds))];
				});
			});
			context(NSStringFromSelector(@selector(containerLayer)), ^{
				it(@"should exist", ^{
					[[sut.containerLayer shouldNot] beNil];
				});
				it(@"should be a CALayer", ^{
					[[sut.containerLayer should] beKindOfClass:[CALayer class]];
				});
				it(@"should be a sublayer of the background layer", ^{
					[[sut.backgroundLayer.sublayers should] contain:sut.containerLayer];
				});
				it(@"should have the name MMFlowViewContainerLayer", ^{
					[[sut.containerLayer.name should] equal:@"MMFlowViewContainerLayer"];
				});
				it(@"should have the same width as the view", ^{
					[[theValue(CGRectGetWidth(sut.containerLayer.bounds)) should] equal:theValue(CGRectGetWidth(sut.bounds))];
				});
				context(@"constraints", ^{
					__block CAConstraint *constraint =  nil;
					it(@"should have three constraints", ^{
						[[sut.containerLayer.constraints should] haveCountOf:4];
					});
					context(@"superlayer equal midx", ^{
						beforeEach(^{
							constraint = [sut.containerLayer.constraints firstObject];
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
					context(@"superlayer max-y", ^{
						beforeEach(^{
							constraint = sut.containerLayer.constraints[1];
						});
						afterEach(^{
							constraint = nil;
						});
						it(@"should be relative to its superlayer", ^{
							[[ constraint.sourceName should] equal:@"superlayer"];
						});
						it(@"should have a max-y sourceAttribute", ^{
							[[theValue(constraint.sourceAttribute) should] equal:theValue(kCAConstraintMaxY)];
						});
						it(@"should have a max-Y attribute", ^{
							[[theValue(constraint.attribute) should] equal:theValue(kCAConstraintMaxY)];
						});
						it(@"should have a scale of 1", ^{
							[[theValue(constraint.scale) should] equal:theValue(1)];
						});
						it(@"should have an offset of zero", ^{
							[[theValue(constraint.offset) should] beZero];
						});
					});
					context(@"superlayer equal width", ^{
						beforeEach(^{
							constraint = sut.containerLayer.constraints[2];
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
						it(@"should have a scale of 1", ^{
							[[theValue(constraint.scale) should] equal:theValue(1)];
						});
					});
					context(@"superlayer equal width", ^{
						beforeEach(^{
							constraint = sut.containerLayer.constraints[3];
						});
						afterEach(^{
							constraint = nil;
						});
						it(@"should be relative to the MMFlowViewTitleLayer", ^{
							[[ constraint.sourceName should] equal:@"MMFlowViewTitleLayer"];
						});
						it(@"should have a width sourceAttribute", ^{
							[[theValue(constraint.sourceAttribute) should] equal:theValue(kCAConstraintMaxY)];
						});
						it(@"should have a width attribute", ^{
							[[theValue(constraint.attribute) should] equal:theValue(kCAConstraintMinY)];
						});
						it(@"should have an offset of 0.", ^{
							[[theValue(constraint.offset) should] beZero];
						});
						it(@"should have a scale of 1", ^{
							[[theValue(constraint.scale) should] equal:theValue(1)];
						});
					});
				});
				context(@"core animation actions", ^{
					__block NSDictionary *actions = nil;
					beforeEach(^{
						actions = sut.containerLayer.actions;
					});
					afterEach(^{
						actions = nil;
					});
					it(@"should have disabled the bounds action", ^{
						[[actions[@"bounds"] should] equal:[NSNull null]];
					});
					it(@"should have disabled the position action", ^{
						[[actions[@"position"] should] equal:[NSNull null]];
					});
				});
			});
			context(@"scrollBarLayer property", ^{
				it(@"should not be nil", ^{
					[[sut.scrollBarLayer shouldNot] beNil];
				});
				it(@"should be from type MMScrollBarLayer", ^{
					[[sut.scrollBarLayer should] beKindOfClass:[MMScrollBarLayer class]];
				});
				it(@"should be a sublayer of the container layer", ^{
					[[sut.backgroundLayer.sublayers should] contain:sut.scrollBarLayer];
				});
			});
			
		});
		context(@"layout", ^{
			__block NSPoint pointInCenterOfView;
			__block NSPoint pointNotInView;

			beforeEach(^{
				pointInCenterOfView = NSMakePoint(NSMidX([sut bounds]), NSMidY([sut bounds]));
				pointNotInView = NSMakePoint(NSWidth([sut bounds])*2, NSHeight([sut bounds])*2);
			});
			context(NSStringFromSelector(@selector(indexOfItemAtPoint:)), ^{
				it(@"should return NSNotFound with empty contents for point in view", ^{
					[[theValue([sut indexOfItemAtPoint:pointInCenterOfView]) should] equal:theValue(NSNotFound)];
				});
				it(@"should return NSNotFound for point outside view", ^{
					[[theValue([sut indexOfItemAtPoint:pointNotInView]) should] equal:theValue(NSNotFound)];
				});
				context(@"layer interaction", ^{
					__block CALayer *mockedHostingLayer = nil;
					__block MMCoverFlowLayer *mockedCoverFlowLayer = nil;
					__block CALayer *mockedContainerLayer = nil;
					CGPoint expectedPoint = {20, 20};

					beforeEach(^{
						mockedHostingLayer = [CALayer nullMock];
						mockedContainerLayer = [CALayer nullMock];
						mockedCoverFlowLayer = [MMCoverFlowLayer nullMock];
						[sut stub:@selector(layer) andReturn:mockedHostingLayer];
						sut.coverFlowLayer = mockedCoverFlowLayer;
						sut.containerLayer = mockedContainerLayer;
						[mockedHostingLayer stub:@selector(convertPoint:toLayer:) andReturn:theValue(expectedPoint)];
					});
					afterEach(^{
						mockedHostingLayer = nil;
					});
					it(@"should ask the views layer to convert the point to the containerlayer", ^{
						[[mockedHostingLayer should] receive:@selector(convertPoint:toLayer:) withArguments:theValue(pointInCenterOfView), mockedContainerLayer];
						[sut indexOfItemAtPoint:pointInCenterOfView];
					});
					it(@"should ask the coverFlowLayer for the index", ^{
						[[mockedCoverFlowLayer should] receive:@selector(indexOfLayerAtPoint:) withArguments:theValue(expectedPoint)];
						[sut indexOfItemAtPoint:pointInCenterOfView];
					});
				});
				
			});
			
		});
		context(@"datasource", ^{
			__block id datasourceMock = nil;

			beforeEach(^{
				datasourceMock = [KWMock mockForProtocol:@protocol(MMFlowViewDataSource)];
				[mockedItems enumerateObjectsUsingBlock:^(id itemMock, NSUInteger idx, BOOL *stop) {
					[[datasourceMock stubAndReturn:itemMock] flowView:sut itemAtIndex:idx];
				}];
				sut.dataSource = datasourceMock;
				[sut.layer layoutSublayers];
			});
			afterEach(^{
				sut.dataSource = nil;
				datasourceMock = nil;
			});
			it(@"should have the datasource", ^{
				[[(id)sut.dataSource should] equal:datasourceMock];
			});
			context(@"datasource interaction", ^{
				beforeEach(^{
					[[datasourceMock stubAndReturn:theValue(numberOfItems)] numberOfItemsInFlowView:sut];
					sut.dataSource = datasourceMock;
				});
				it(@"should ask the datasource for the number of items", ^{
					[[datasourceMock should] receive:@selector(numberOfItemsInFlowView:)];
					[sut reloadContent];
				});
			});
			context(@"one item", ^{
				NSString *expectedTitle = @"0";

				beforeEach(^{
					[[datasourceMock stubAndReturn:theValue(1)] numberOfItemsInFlowView:sut];
					sut.dataSource = datasourceMock;
					[sut reloadContent];
				});
				it(@"should have one item", ^{
					[[theValue(sut.numberOfItems) should] equal:theValue(1)];
				});
				it(@"should have the image item title", ^{
					[[sut.title should] equal:expectedTitle];
				});
				it(@"should have one visibile item", ^{
					[[sut.visibleItemIndexes should] haveCountOf:1];
				});
			});
			context(@"many items", ^{
				beforeAll(^{
					
				});
				beforeEach(^{
					[[datasourceMock stubAndReturn:theValue(numberOfItems)] numberOfItemsInFlowView:sut];
					sut.dataSource = datasourceMock;
					[sut reloadContent];
				});
				it(@"should have 10 items", ^{
					[[theValue(sut.numberOfItems) should] equal:theValue(numberOfItems)];
				});
				it(@"should have the first image item title", ^{
					[[sut.title should] equal:@"0"];
				});
				it(@"should have the first item selected", ^{
					[[theValue(sut.selectedIndex) should] equal:theValue(0)];
				});
				context(@"layers", ^{
					it(@"should have numberOfItems (10) sublayers", ^{
						[[theValue(sut.numberOfItems) should] equal:theValue(10)];
					});
					it(@"should reload the cover flow layer when invoking reloadContent", ^{
						[[sut.coverFlowLayer should] receive:@selector(reloadContent)];
						[sut reloadContent];
					});
					it(@"should relayout the cover flow layer when changing the selection", ^{
						[[sut.coverFlowLayer should] receive:@selector(setNeedsLayout)];
						sut.selectedIndex = sut.selectedIndex + 1;
					});
				});
				context(@"visibleItems", ^{
					it(@"should have the selected item visible", ^{
						[[theValue([sut.visibleItemIndexes containsIndex:sut.selectedIndex]) should] beYes];
					});
					it(@"should match the visible item count of its cover flow layer", ^{
						[[sut.visibleItemIndexes should] haveCountOf:[sut.coverFlowLayer.visibleItemIndexes count]];
					});
				});
				context(@"moving left", ^{
					beforeEach(^{
						[sut moveLeft:self];
					});
					it(@"should still have the first item selected", ^{
						[[theValue(sut.selectedIndex) should] equal:theValue(0)];
					});
					it(@"should show the first item title", ^{
						[[sut.title should] equal:@"0"];
					});
				});
				context(@"moving right", ^{
					beforeEach(^{
						[sut moveRight:self];
					});
					it(@"should have the second item selected", ^{
						[[theValue(sut.selectedIndex) should] equal:theValue(1)];
					});
					it(@"should show the second item title", ^{
						[[sut.title should] equal:@"1"];
					});
					context(@"moving back left", ^{
						beforeEach(^{
							[sut moveLeft:self];
						});
						it(@"should have the first item selected", ^{
							[[theValue(sut.selectedIndex) should] equal:theValue(0)];
						});
						it(@"should show the first item title", ^{
							[[sut.title should] equal:@"0"];
						});
					});
				});
				context(@"changing the selection", ^{
					afterEach(^{
						sut.selectedIndex = 0;
					});
					context(@"select the third item", ^{
						beforeEach(^{
							sut.selectedIndex = 2;
						});
						it(@"should have the third item selected", ^{
							[[theValue(sut.selectedIndex) should] equal:theValue(2)];
						});
						it(@"should show the third item title", ^{
							[[sut.title should] equal:@"2"];
						});
					});
					context(@"select the last item", ^{
						beforeEach(^{
							sut.selectedIndex = sut.numberOfItems - 1;
						});
						it(@"should have selected the last item", ^{
							[[theValue(sut.selectedIndex) should] equal:theValue(numberOfItems - 1)];
						});
					});
					context(@"select beyound the item count", ^{
						beforeEach(^{
							sut.selectedIndex = sut.numberOfItems * 2;
						});
						it(@"should do nothing", ^{
							[[theValue(sut.selectedIndex) should] equal:theValue(0)];
						});
						it(@"should show the first item title", ^{
							[[sut.title should] equal:@"0"];
						});
					});
					context(@"selecting a negative item index", ^{
						beforeEach(^{
							sut.selectedIndex = -1;
						});
						it(@"should do nothing", ^{
							[[theValue(sut.selectedIndex) should] equal:theValue(0)];
						});
						it(@"should show the first item title", ^{
							[[sut.title should] equal:@"0"];
						});
					});
				});
				context(@"selectedItemFrame", ^{
					it(@"should have a selectedItemFrame matching the coverflow layers selectedItemFrame coverted into view space", ^{
						NSRect rectInHostingLayer = NSRectFromCGRect([sut.layer convertRect:sut.coverFlowLayer.selectedItemFrame fromLayer:sut.coverFlowLayer]);
						NSValue *expectedFrame = [NSValue valueWithRect:rectInHostingLayer];
						[[[NSValue valueWithRect:sut.selectedItemFrame] should] equal:expectedFrame];
					});
				});
				context(@"tracking areas", ^{
					__block NSTrackingArea *trackingArea = nil;
					
					beforeEach(^{
						[sut updateTrackingAreas];
						trackingArea = [[sut trackingAreas] firstObject];
					});
					afterEach(^{
						trackingArea = nil;
					});
					it(@"should have one tracking area", ^{
						[[[sut trackingAreas] should] haveCountOf:1];
					});
					it(@"should have the selected item rect", ^{
						NSValue *expectedRect = [NSValue valueWithRect:sut.selectedItemFrame];
						[[[NSValue valueWithRect:[trackingArea rect]] should] equal:expectedRect];
					});
					it(@"should have the NSTrackingActiveInActiveApp option", ^{
						[[theValue([trackingArea options] & NSTrackingActiveInActiveApp) should] beTrue];
					});
					it(@"should have the NSTrackingActiveWhenFirstResponder option", ^{
						[[theValue([trackingArea options] & NSTrackingActiveWhenFirstResponder) should] beTrue];
					});
					it(@"should have the NSTrackingMouseEnteredAndExited option", ^{
						[[theValue([trackingArea options] & NSTrackingMouseEnteredAndExited) should] beTrue];
					});
					it(@"should have the NSTrackingAssumeInside option", ^{
						[[theValue([trackingArea options] & NSTrackingAssumeInside) should] beTrue];
					});
					it(@"should be the owner of the tracking area", ^{
						[[[trackingArea owner] should] equal:sut];
					});
				});
			});
		});
	});
	
});


SPEC_END
