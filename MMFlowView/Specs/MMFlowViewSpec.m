//
//  MMFlowViewSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView.h"

SPEC_BEGIN(MMFlowViewSpec)

context(@"MMFlowView", ^{
	context(@"a newly created instance", ^{
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
		
		it(@"should exists", ^{
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
		it(@"should have no visibile items", ^{
			[[sut.visibleItemIndexes should] beNil];
		});
		it(@"should initially show reflections", ^{
			[[theValue(sut.showsReflection) should] beYes];
		});
		it(@"should accept touch events", ^{
			[[theValue([sut acceptsTouchEvents]) should] beYes];
		});
		it(@"should have a stacked angle of 70", ^{
			[[theValue(sut.stackedAngle) should] equal:@70];
		});
		it(@"should have a spacing of 50", ^{
			[[theValue(sut.spacing) should] equal:@50];
		});
		it(@"should have a selectedScale of 200", ^{
			[[theValue(sut.selectedScale) should] equal:@200];
		});
		it(@"should have a stackedScale of -200", ^{
			[[theValue(sut.stackedScale) should] equal:@(-200)];
		});
		it(@"should have a reflectionOffset of -0.4", ^{
			[[theValue(sut.reflectionOffset) should] equal:@(-.4)];
		});
		it(@"should have a scroll duration of 0.4 seconds", ^{
			[[theValue(sut.scrollDuration) should] equal:@.4];
		});
		it(@"should have a item scale of 1", ^{
			[[theValue(sut.itemScale) should] equal:@1];
		});
		it(@"should have a preview scale of 0.25", ^{
			[[theValue(sut.previewScale) should] equal:@.25];
		});
		it(@"should have an empty title", ^{
			[[sut.title should] equal:@""];
		});
		it(@"should have a title size of 18", ^{
			[[theValue(sut.titleSize) should] equal:@18];
		});
		it(@"should be registered for url pasteboard type", ^{
			[[[sut registeredDraggedTypes] should] contain:NSURLPboardType];
		});
		it(@"should have an empty datasource", ^{
			[[(id)sut.dataSource should] beNil];
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
			it(@"should be layer backed", ^{
				[[theValue([sut wantsLayer]) should] beYes];
			});
			it(@"should have a layer attached", ^{
				[[[sut layer] shouldNot] beNil];
			});
		});
		context(@"layout", ^{
			NSPoint pointInView = NSMakePoint(NSMidX([sut bounds]), NSMidY([sut bounds]));
			NSPoint pointNotInView = NSMakePoint(NSWidth([sut bounds])*2, NSHeight([sut bounds])*2);

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
