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

SPEC_BEGIN(MMFlowViewSpec)

describe(@"MMFlowView", ^{
	context(@"a new instance", ^{
		__block MMFlowView *sut = nil;
		NSRect initialFrame = NSMakeRect(0, 0, 400, 300);
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
			it(@"should have an action cell class", ^{
				[[[[sut class] cellClass] should] equal:[NSActionCell class]];
			});
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
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
		});
		context(@"NSResponder overrides", ^{
			it(@"should accept being first responder", ^{
				[[theValue([sut acceptsFirstResponder]) should] beYes];
			});
		});
		it(@"should have no items", ^{
			[[theValue(sut.numberOfItems) should] equal:theValue(0)];
		});
		it(@"shoud have no item selected", ^{
			[[theValue(sut.selectedIndex) should] equal:theValue(NSNotFound)];
		});
		context(@"visibleItemIndexes", ^{
			it(@"should not be nil", ^{
				[[sut.visibleItemIndexes shouldNot] beNil];
			});
			it(@"should have count of zero", ^{
				[[sut.visibleItemIndexes should] haveCountOf:0];
			});
		});
		it(@"should initially show reflections", ^{
			[[theValue(sut.showsReflection) should] beYes];
		});
		it(@"should accept touch events", ^{
			[[theValue([sut acceptsTouchEvents]) should] beYes];
		});
		context(@"stackedAngle property", ^{
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
					[[theValue(sut.layout.stackedAngle) should] equal:theValue(sut.stackedAngle)];
				});

			});
		});
		context(@"spacing property", ^{
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
					[[theValue(sut.layout.interItemSpacing) should] equal:theValue(sut.spacing)];
				});
			});
		});
		it(@"should have a stackedScale of -200", ^{
			[[theValue(sut.stackedScale) should] equal:theValue(-200)];
		});
		it(@"should have a reflectionOffset of -.4", ^{
			[[theValue(sut.reflectionOffset) should] equal:theValue(-.4)];
		});
		it(@"should have a scroll duration of .4 seconds", ^{
			[[theValue(sut.scrollDuration) should] equal:theValue(.4)];
		});
		it(@"should have a item scale of 1", ^{
			[[theValue(sut.itemScale) should] equal:theValue(1)];
		});
		it(@"should have a preview scale of 0.25", ^{
			[[theValue(sut.previewScale) should] equal:theValue(.25)];
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
		context(@"MMCoverFlowLayerDataSource", ^{
			it(@"should conform to the MMCoverFlowLayerDataSource protocol", ^{
				[[sut should] conformToProtocol:@protocol(MMCoverFlowLayerDataSource)];
			});
			it(@"should respond to coverFlowLayer:contentLayerForIndex:", ^{
				[[sut should] respondToSelector:@selector(coverFlowLayer:contentLayerForIndex:)];
			});
			it(@"should be the datasource for the coverflow layer", ^{
				[[sut should] equal:sut.coverFlowLayer.dataSource];
			});
			it(@"should reload the cover flow layer when invoking reloadContent", ^{
				[[sut.coverFlowLayer should] receive:@selector(reloadContent)];
				[sut reloadContent];
			});
			context(@"content layers", ^{
				__block CALayer *contentLayer = nil;

				beforeEach(^{
					contentLayer = [sut coverFlowLayer:sut.coverFlowLayer contentLayerForIndex:0];
				});
				afterEach(^{
					contentLayer = nil;
				});
				it(@"should not return nil when asked for a content layer", ^{
					[[contentLayer shouldNot] beNil];
				});
				it(@"should have set an image", ^{
					[[contentLayer.contents shouldNot] beNil];
				});
			});
		});
		context(@"bindings", ^{
			__block NSArray *exposedBindings = nil;

			beforeEach(^{
				exposedBindings = [sut exposedBindings];
			});
			afterEach(^{
				exposedBindings = nil;
			});

			it(@"should expose NSContentArrayBinding", ^{
				[[exposedBindings should] contain:NSContentArrayBinding];
			});
			it(@"should expose kMMFlowViewImageRepresentationBinding", ^{
				[[exposedBindings should] contain:kMMFlowViewImageRepresentationBinding];
			});
			it(@"should expose kMMFlowViewImageRepresentationTypeBinding", ^{
				[[exposedBindings should] contain:kMMFlowViewImageRepresentationTypeBinding];
			});
			it(@"should expose kMMFlowViewImageUIDBinding", ^{
				[[exposedBindings should] contain:kMMFlowViewImageUIDBinding];
			});
			it(@"should expose kMMFlowViewImageTitleBinding", ^{
				[[exposedBindings should] contain:kMMFlowViewImageTitleBinding];
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
			context(@"coverFlowLayer property", ^{
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
			context(@"containerLayer", ^{
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
					context(@"super layer equal midx", ^{
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
					context(@"super layer max-y", ^{
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
					context(@"super layer equal width", ^{
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
					context(@"super layer equal width", ^{
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
			__block NSPoint pointInView;
			__block NSPoint pointNotInView;

			beforeEach(^{
				pointInView = NSMakePoint(NSMidX([sut bounds]), NSMidY([sut bounds]));
				pointNotInView = NSMakePoint(NSWidth([sut bounds])*2, NSHeight([sut bounds])*2);
			});
			context(@"indexForItemAtPoint:", ^{
				it(@"should return NSNotFound with empty contents for point in view", ^{
					[[theValue([sut indexOfItemAtPoint:pointInView]) should] equal:theValue(NSNotFound)];
				});
				it(@"should return NSNotFound for point outside view", ^{
					[[theValue([sut indexOfItemAtPoint:pointNotInView]) should] equal:theValue(NSNotFound)];
				});
			});
			
		});
		context(@"datasource", ^{
			__block id datasourceMock = nil;
			__block NSArray *mockedItems = nil;
			const NSInteger numberOfItems = 10;

			beforeEach(^{
				[sut.layer layoutSublayers];
				datasourceMock = [KWMock mockForProtocol:@protocol(MMFlowViewDataSource)];
				sut.dataSource = datasourceMock;

				NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:numberOfItems];
				for ( NSInteger i = 0; i < numberOfItems; ++i) {
					NSString *titleString = [NSString stringWithFormat:@"%ld", (long)i];
					// item
					id itemMock = [KWMock mockForProtocol:@protocol(MMFlowViewItem)];
					[itemMock stub:@selector(imageItemRepresentationType) andReturn:kMMFlowViewNSImageRepresentationType];
					[itemMock stub:@selector(imageItemUID) andReturn:titleString];
					[itemMock stub:@selector(imageItemTitle) andReturn:titleString];
					[itemMock stub:@selector(imageItemRepresentation) andReturn:[NSImage imageNamed:NSImageNameUser]];
					[itemArray addObject:itemMock];
					[[datasourceMock stubAndReturn:itemMock] flowView:sut itemAtIndex:i];
				}
				mockedItems = [itemArray copy];
			});
			afterEach(^{
				sut.dataSource = nil;
				datasourceMock = nil;
				mockedItems = nil;
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
				afterEach(^{
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
					context(@"item layers", ^{
						it(@"should have numberOfItems (10) sublayers", ^{
							[[[sut.coverFlowLayer should] have:numberOfItems] sublayers];
						});
						it(@"should have item layers of kind MMCoverFlowItemLayer", ^{
							
						});
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
			});
		});
	});
	
});


SPEC_END
