//
//  MMFlowViewKeyValueObservingSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+NSKeyValueObserving.h"
#import <objc/runtime.h>

static BOOL testingSuperInvoked = NO;

@interface MMFlowView (MMBindingsTests)

- (void)mmTesting_bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options;

@end

@implementation MMFlowView (MMBindingsTests)

- (void)mmTesting_bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	testingSuperInvoked = YES;
}

- (void)mmTesting_unbind:(NSString *)binding
{
	testingSuperInvoked = YES;
}

@end

SPEC_BEGIN(MMFlowViewKeyValueObservingSpec)

describe(@"NSKeyValueObserving", ^{
	__block NSArray *mockedItems = nil;
	const NSInteger numberOfItems = 10;
	
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
	context(@"a new instance", ^{
		__block MMFlowView *sut = nil;

		beforeEach(^{
			sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
		});
		afterEach(^{
			sut = nil;
		});
		context(@"observedItemKeyPaths", ^{
			it(@"should initally be empty", ^{
				[[sut.observedItemKeyPaths should] haveCountOf:0];
			});
			context(@"when setting itemKeyPaths", ^{
				beforeEach(^{
					sut.imageRepresentationKeyPath = @"testImageRepresentation";
					sut.imageRepresentationTypeKeyPath = @"testImageRepresentationType";
					sut.imageUIDKeyPath = @"testImageUID";
					sut.imageTitleKeyPath = @"testTitle";
				});
				it(@"should contain the imageRepresentationKeyPath (testImageRepresentation)", ^{
					[[sut.observedItemKeyPaths should] contain:@"testImageRepresentation"];
				});
				it(@"should contain the imageRepresentationTypeKeyPath (testImageRepresentationType)", ^{
					[[sut.observedItemKeyPaths should] contain:@"testImageRepresentationType"];
				});
				it(@"should contain the imageUIDKeyPath (testImageUID)", ^{
					[[sut.observedItemKeyPaths should] contain:@"testImageUID"];
				});
				it(@"should contain the imageTitleKeyPath (testTitle)", ^{
					[[sut.observedItemKeyPaths should] contain:@"testTitle"];
				});
			});
		});
		context(@"bindings", ^{
			__block NSArray *exposedBindings = nil;
			__block NSArrayController *arrayController = nil;
			NSString *arrangedObjectsKeyPath = @"arrangedObjects";
			
			beforeAll(^{
				arrayController = [[NSArrayController alloc] initWithContent:mockedItems];
				[arrayController setEditable:NO];
			});
			afterAll(^{
				arrayController = nil;
			});

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
			context(@"bind:toObject:withKeyPath:options:", ^{
				context(@"when binding the NSContentArrayBinding to an NSArrayController", ^{
					beforeEach(^{
						[sut bind:NSContentArrayBinding toObject:arrayController withKeyPath:arrangedObjectsKeyPath options:nil];
					});
					afterEach(^{
						[sut unbind:NSContentArrayBinding];
					});
					it(@"should be bound to the array controller", ^{
						[[sut.observedItems should] equal:mockedItems];
					});
					it(@"should have the same number of items", ^{
						[[theValue(sut.numberOfItems) should] equal:theValue([mockedItems count])];
					});
					it(@"should have a default imageRepresentationKeyPath", ^{
						[[sut.imageRepresentationKeyPath should] equal:NSStringFromSelector(@selector(imageItemRepresentation))];
					});
					it(@"should have a default imageRepresentationTypeKeyPath ", ^{
						[[sut.imageRepresentationTypeKeyPath should] equal:NSStringFromSelector(@selector(imageItemRepresentationType))];
					});
					it(@"should have a default imageUIDKeyPath ", ^{
						[[sut.imageUIDKeyPath should] equal:NSStringFromSelector(@selector(imageItemUID))];
					});
					it(@"should return the arraycontroller for contentArrayController", ^{
						[[sut.contentArrayController should] equal:arrayController];
					});
					it(@"should return the observed array for contentArray", ^{
						[[sut.contentArray should] equal:mockedItems];
					});
					it(@"should return the observed keypath for contentArrayKeyPath", ^{
						[[sut.contentArrayKeyPath should] equal:arrangedObjectsKeyPath];
					});
					context(@"when binding NSContentArrayBinding to another array controller", ^{
						__block id mockedArrayController = nil;

						beforeEach(^{
							mockedArrayController =[NSArrayController nullMock];
						});
						it(@"should unbind the previously bound arraycontroller", ^{
							[[sut should] receive:@selector(unbind:) withArguments:NSContentArrayBinding];
							[sut bind:NSContentArrayBinding toObject:mockedArrayController withKeyPath:arrangedObjectsKeyPath options:nil];
						});
					});
					context(@"NSContentArrayBinding info", ^{
						__block NSDictionary *contentArrayBinding = nil;
						beforeEach(^{
							contentArrayBinding = [sut infoForBinding:NSContentArrayBinding];
						});
						it(@"should have a NSContentArrayBinding", ^{
							[[contentArrayBinding shouldNot] beNil];
						});
						it(@"should have the array controller as NSObservedObjectKey", ^{
							[[contentArrayBinding[NSObservedObjectKey] should] equal:arrayController];
						});
						it(@"should have the -bind:toObject:withKeyPath:options keyPath as NSObservedKeyPathKey", ^{
							[[contentArrayBinding[NSObservedKeyPathKey] should] equal:arrangedObjectsKeyPath];
						});
					});
					context(@"selection", ^{
						it(@"should set the NSArrayControllers selection", ^{
							sut.selectedIndex = 5;
							[[theValue([arrayController selectionIndex]) should] equal:theValue(5)];
						});
					});
				});
				context(@"when binding the NSContentArrayBinding to an non-NSArrayController", ^{
					__block NSDictionary *dict = nil;
					beforeEach(^{
						dict = @{@"arrangedObjects": @[@1, @2]};
					});
					it(@"should raise when not bound to an NSArrayController", ^{
						[[theBlock(^{
							[sut bind:NSContentArrayBinding toObject:dict withKeyPath:@"arrangedObjects" options:nil];
						}) should] raiseWithName:NSInternalInconsistencyException];
					});
				});
				context(@"when binding to other property than NSContentArrayBinding", ^{
					__block Method supersBindMethod;
					__block Method testingBindMethod;
					
					beforeEach(^{
						supersBindMethod = class_getInstanceMethod([sut superclass], @selector(bind:toObject:withKeyPath:options:));
						testingBindMethod = class_getInstanceMethod([sut class], @selector(mmTesting_bind:toObject:withKeyPath:options:));
						method_exchangeImplementations(supersBindMethod, testingBindMethod);
						testingSuperInvoked = NO;
					});
					afterEach(^{
						method_exchangeImplementations(testingBindMethod, supersBindMethod);
					});
					it(@"should call the supers implementation of -bind:toObject:withKeyPath:options:", ^{
						NSDictionary *dict = @{@"angle" : @10 };
						[sut bind:@"stackedAngle" toObject:dict withKeyPath:@"angle" options:nil];
						[[theValue(testingSuperInvoked) should] beYes];
						
					});
				});
			});
			context(@"unbind:", ^{
				context(NSContentArrayBinding, ^{
					beforeEach(^{
						[sut bind:NSContentArrayBinding toObject:arrayController withKeyPath:arrangedObjectsKeyPath options:nil];
					});
					it(@"should return nil for infoForBinding", ^{
						[sut unbind:NSContentArrayBinding];
						[[[sut infoForBinding:NSContentArrayBinding] should] beNil];
					});
					it(@"should remove itself as observer from the array controllers array property", ^{
						[[arrayController should] receive:@selector(removeObserver:forKeyPath:) withArguments:sut, arrangedObjectsKeyPath];
						[sut unbind:NSContentArrayBinding];
					});
				});
				context(@"when unbind other property than NSContentArrayBinding", ^{
					__block Method supersUnbindMethod;
					__block Method testingUnbindMethod;
					
					beforeEach(^{
						supersUnbindMethod = class_getInstanceMethod([sut superclass], @selector(unbind:));
						testingUnbindMethod = class_getInstanceMethod([sut class], @selector(mmTesting_unbind:));
						method_exchangeImplementations(supersUnbindMethod, testingUnbindMethod);
						testingSuperInvoked = NO;
					});
					afterEach(^{
						method_exchangeImplementations(testingUnbindMethod, supersUnbindMethod);
					});
					it(@"should call the supers implementation of -bind:toObject:withKeyPath:options:", ^{
						[sut unbind:@"stackedAngle"];
						[[theValue(testingSuperInvoked) should] beYes];
					});
				});

				
			});
			
		});
	});
});

SPEC_END
