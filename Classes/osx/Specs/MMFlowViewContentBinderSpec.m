//
//  MMFlowViewContentBinderSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 02.04.14.
//  Copyright 2014 Markus Müller. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowViewContentBinder.h"
#import "MMFlowView.h"
#import "TestingContentContainer.h"

@interface MMTestImageItem : NSObject

@property (nonatomic, strong) NSString *imageItemUID;
@property (nonatomic, strong) NSString *imageItemRepresentationType;
@property (nonatomic, strong) NSString *imageItemRepresentation;

@end

@implementation MMTestImageItem
@end

SPEC_BEGIN(MMFlowViewContentBinderSpec)

describe(NSStringFromClass([MMFlowViewContentBinder class]), ^{
	__block MMFlowViewContentBinder *sut = nil;
	__block NSArrayController *arrayController = nil;
	__block TestingContentContainer *container = nil;
	__block id delegateMock = nil;
	NSUInteger numberOfItems = 10;
	
	NSString *arrangedObjectsKey = @"arrangedObjects";

	beforeEach(^{
		container = [TestingContentContainer new];

		NSMutableArray *items = [container mutableArrayValueForKey:@"items"];
		for (NSUInteger i = 0; i < numberOfItems; ++i) {
			[items addObject:[MMTestImageItem new]];
		}
		arrayController = [[NSArrayController alloc] init];
		[arrayController setObjectClass:[MMTestImageItem class]];
		[arrayController setEditable:YES];
		[arrayController bind:NSContentArrayBinding
					 toObject:container
				  withKeyPath:@"items"
					  options:nil];
		delegateMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewContentBinderDelegate)];
	});
	afterEach(^{
		arrayController = nil;
		sut = nil;
		delegateMock = nil;
	});
	it(@"should raise an NSInternalInconsistencyException when not crated by designated initalizer", ^{
		[[theBlock(^{
			sut = [[MMFlowViewContentBinder alloc] init];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	it(@"should raise an NSInternalInconsistencyException whenn created by an correctly configured NSArrayController but a nil content array key path", ^{
		[[theBlock(^{
			sut = [[MMFlowViewContentBinder alloc] initWithArrayController:arrayController withContentArrayKeyPath:nil];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	context(@"a new instance created by an correctly configured NSArrayController and a content array key path", ^{
		beforeEach(^{
			sut = [[MMFlowViewContentBinder alloc] initWithArrayController:arrayController withContentArrayKeyPath:arrangedObjectsKey];
		});
		afterEach(^{
			sut = nil;
		});

		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});

		it(@"should have the content key path from the initializer", ^{
			[[sut.contentArrayKeyPath should] equal:arrangedObjectsKey];
		});

		it(@"should have an empty contentArray", ^{
			[[sut.contentArray should] haveCountOf:0];
		});

		it(@"should have no observedItems", ^{
			[[sut.observedItems should] beNil];
		});

		context(NSStringFromSelector(@selector(observedItemKeys)), ^{
			NSArray *mandantoryKeys = @[NSStringFromSelector(@selector(imageItemRepresentation)), NSStringFromSelector(@selector(imageItemRepresentationType)), NSStringFromSelector(@selector(imageItemUID))];
			it(@"should contain the non optional MMFlowViewItem protocol methods", ^{
				[[sut.observedItemKeys should] containObjectsInArray:mandantoryKeys];
			});
		});

		context(NSStringFromSelector(@selector(stopObservingContent)), ^{
	
			context(@"when observing the content", ^{
				beforeEach(^{
					[sut startObservingContent];
				});

				it(@"should not observe the content anymore", ^{
					[sut stopObservingContent];

					[[sut.observedItems should] beNil];
				});

				it(@"should remove itself as an observer from the observed items", ^{
					NSIndexSet *expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [sut.observedItems count])];
					for (NSString *key in sut.observedItemKeys) {
						[[sut.observedItems should] receive:@selector(removeObserver:fromObjectsAtIndexes:forKeyPath:context:) withArguments:sut, expectedIndexes, key, [KWAny any]];
					}
					[sut stopObservingContent];
				});

				it(@"should remove itself as an observer from the array controller", ^{
					[[arrayController should] receive:@selector(removeObserver:forKeyPath:context:) withArguments:sut, arrangedObjectsKey, [KWAny any]];
			
					[sut stopObservingContent];
				});
			});

			context(@"when not observing the content", ^{
				it(@"should not remove itself as an observer from the array controller", ^{
					[[arrayController shouldNot] receive:@selector(removeObserver:forKeyPath:context:) withArguments:sut, arrangedObjectsKey, [KWAny any]];
					
					[sut stopObservingContent];
				});
			});
			
		}),
		
		context(NSStringFromSelector(@selector(startObservingContent)), ^{
			__block MMTestImageItem *anItem = nil;

			beforeEach(^{
				sut.delegate = delegateMock;
				[sut startObservingContent];
			});
			afterEach(^{
				anItem = nil;
			});

			it(@"should observe the items to the array controller", ^{
				[[sut.observedItems should] haveCountOf:numberOfItems];
				[[sut.observedItems should] equal:[arrayController arrangedObjects]];
			});

			context(@"adding new items with the array controller", ^{

				beforeEach(^{
					anItem = [arrayController newObject];
				});

				it(@"should add new object to the observed items", ^{
					[arrayController addObject:anItem];

					[[sut.observedItems should] contain:anItem];
				});
	
				it(@"should inform the delegate that the content changed", ^{
					[[delegateMock should] receive:@selector(contentArrayDidChange:)];

					[arrayController addObject:anItem];
				});
			});

			context(@"removing items from the array controller", ^{
				NSUInteger removedIndex = 2;

				beforeEach(^{
					anItem = [arrayController arrangedObjects][removedIndex];
				});

				it(@"should not observe the item item anymore", ^{
					[arrayController removeObjectAtArrangedObjectIndex:removedIndex];

					[[sut.observedItems shouldNot] contain:anItem];
				});

				it(@"should inform the delegate that the content changed", ^{
					[[delegateMock should] receive:@selector(contentArrayDidChange:) withArguments:sut];

					[arrayController removeObjectAtArrangedObjectIndex:removedIndex];
				});
			});

			context(@"when the delegate does not respond to contentArrayDidChange:", ^{
				beforeEach(^{
					delegateMock = [KWMock nullMock];
					sut.delegate = delegateMock;
				});

				it(@"should not inform the delegate when adding items", ^{
					[[delegateMock shouldNot] receive:@selector(contentArrayDidChange:)];

					anItem = [arrayController newObject];
					[arrayController addObject:anItem];
				});

				it(@"should not inform the delegate that the content changed", ^{
					[[delegateMock shouldNot] receive:@selector(contentArrayDidChange:) withArguments:sut];
					
					[arrayController removeObjectAtArrangedObjectIndex:0];
				});
			});
			
			context(@"when changing values for the MMFlowViewItem protocol", ^{
				beforeEach(^{
					anItem = [sut.observedItems firstObject];

					[[(id)sut.delegate should] receive:@selector(contentBinder:itemChanged:) withArguments:sut, anItem];
				});

				it(@"should inform the delegate when changing an imageItemRepresentation", ^{
					anItem.imageItemRepresentation = @"test";
				});

				it(@"should inform the delegate when changing an imageItemRepresentationType", ^{
					anItem.imageItemRepresentationType = @"test";
				});

				it(@"should inform the delegate when changing an imageItemUID", ^{
					anItem.imageItemUID = @"test";
				});
			});
		});

	});

	context(@"a new instance created with an NSArrayController with an non MMFlowViewItem conforming objectClass", ^{
		beforeEach(^{
			arrayController = [NSArrayController nullMock];
		});

		it(@"should raise an NSInternalInconsistencyException", ^{
			[[theBlock(^{
				sut = [[MMFlowViewContentBinder alloc] initWithArrayController:arrayController withContentArrayKeyPath:nil];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
});

SPEC_END
