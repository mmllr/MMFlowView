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
//  MMFlowViewKeyValueObservingSpec.m
//
//  Created by Markus Müller on 13.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <objc/runtime.h>

#import "Kiwi.h"
#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+NSKeyValueObserving.h"
#import "NSArray+MMAdditions.h"

static BOOL testingSuperInvoked = NO;

@interface MMFlowView (MMBindingsTests)

- (void)mmTesting_bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options;

@end

@implementation MMFlowView (MMBindingsTests)

- (void)mmTesting_bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	testingSuperInvoked = YES;
	// invoke swizzled method - strange naming: mmTesting_bind is Cocoas bind:...
	[self mmTesting_bind:binding toObject:observable withKeyPath:keyPath options:options];
}

- (void)mmTesting_unbind:(NSString *)binding
{
	testingSuperInvoked = YES;
	// invoke swizzled method - strange naming: mmTesting_unbind: is Cocoas unbind:...
	[self mmTesting_unbind:binding];
}

- (void)mmTesting_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
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
		it(@"should initially have the default MMFlowViewItem imageItemRepresentation keypath", ^{
			[[sut.imageRepresentationKeyPath should] equal:NSStringFromSelector(@selector(imageItemRepresentation))];
		});
		it(@"should initially have the default MMFlowViewItem imageItemRepresentationType keypath", ^{
			[[sut.imageRepresentationTypeKeyPath should] equal:NSStringFromSelector(@selector(imageItemRepresentationType))];
		});
		it(@"should initially have the default MMFlowViewItem imageItemUID keypath", ^{
			[[sut.imageUIDKeyPath should] equal:NSStringFromSelector(@selector(imageItemUID))];
		});
		context(NSStringFromSelector(@selector(observedItemKeyPaths)), ^{
			it(@"should initally have the non optional MMFlowViewItem keypaths", ^{
				[[sut.observedItemKeyPaths should] haveCountOf:3];
			});
			it(@"should initially have the non optional MMFlowViewItems selectors", ^{
				[[sut.observedItemKeyPaths should] containObjectsInArray:@[sut.imageUIDKeyPath, sut.imageRepresentationKeyPath, sut.imageRepresentationTypeKeyPath]];
			});
			context(@"when setting itemKeyPaths", ^{
				it(@"should contain the imageRepresentationKeyPath (testImageRepresentation)", ^{
					sut.imageRepresentationKeyPath = @"testImageRepresentation";
					[[sut.observedItemKeyPaths should] contain:@"testImageRepresentation"];
				});
				it(@"should contain the imageRepresentationTypeKeyPath (testImageRepresentationType)", ^{
					sut.imageRepresentationTypeKeyPath = @"testImageRepresentationType";
					[[sut.observedItemKeyPaths should] contain:@"testImageRepresentationType"];
				});
				it(@"should contain the imageUIDKeyPath (testImageUID)", ^{
					sut.imageUIDKeyPath = @"testImageUID";
					[[sut.observedItemKeyPaths should] contain:@"testImageUID"];
				});
				it(@"should contain the imageTitleKeyPath (testTitle)", ^{
					sut.imageTitleKeyPath = @"testTitle";
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
			context(NSStringFromSelector(@selector(bind:toObject:withKeyPath:options:)), ^{
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
					context(@"trigering KVO", ^{
						beforeAll(^{
							for (id itemMock in mockedItems) {
								[itemMock stub:NSSelectorFromString(@"test")];
							}
						});
						context(@"when changing imageRepresentationKeyPath", ^{
							it(@"should stop observering for the old key path", ^{
								[[sut.observedItems should] receive:@selector(mm_removeObserver:forKeyPaths:context:)
													  withArguments:sut, @[sut.imageRepresentationKeyPath], [KWAny any]];
								sut.imageRepresentationKeyPath = @"test";
							});
							it(@"should start observering for the new key path", ^{
								[[sut.observedItems should] receive:@selector(mm_addObserver:forKeyPaths:context:)
													  withArguments:sut, @[@"test"], [KWAny any]];
								sut.imageRepresentationKeyPath = @"test";
							});
						});
						context(@"when changing imageRepresentationTypeKeyPath", ^{
							it(@"should stop observering for the old key path", ^{
								[[sut.observedItems should] receive:@selector(mm_removeObserver:forKeyPaths:context:)
													  withArguments:sut, @[sut.imageRepresentationTypeKeyPath], [KWAny any]];
								sut.imageRepresentationTypeKeyPath = @"test";
							});
							it(@"should start observering for the new key path", ^{
								[[sut.observedItems should] receive:@selector(mm_addObserver:forKeyPaths:context:)
													  withArguments:sut, @[@"test"], [KWAny any]];
								sut.imageRepresentationTypeKeyPath = @"test";
							});
						});
						context(@"when changing imageUIDKeyPath", ^{
							it(@"should stop observering for the old key path", ^{
								[[sut.observedItems should] receive:@selector(mm_removeObserver:forKeyPaths:context:)
													  withArguments:sut, @[sut.imageUIDKeyPath], [KWAny any]];
								sut.imageUIDKeyPath = @"test";
							});
							it(@"should start observering for the new key path", ^{
								[[sut.observedItems should] receive:@selector(mm_addObserver:forKeyPaths:context:)
													  withArguments:sut, @[@"test"], [KWAny any]];
								sut.imageUIDKeyPath = @"test";
							});
							
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
					__block NSDictionary *observedDict = nil;
	
					beforeEach(^{
						observedDict = @{@"angle" : @10 };
						supersBindMethod = class_getInstanceMethod([sut superclass], @selector(bind:toObject:withKeyPath:options:));
						testingBindMethod = class_getInstanceMethod([sut class], @selector(mmTesting_bind:toObject:withKeyPath:options:));
						method_exchangeImplementations(supersBindMethod, testingBindMethod);
						testingSuperInvoked = NO;
						[sut bind:@"stackedAngle" toObject:observedDict withKeyPath:@"angle" options:nil];
					});
					afterEach(^{
						method_exchangeImplementations(testingBindMethod, supersBindMethod);
					});
					it(@"should call the supers implementation", ^{
						[[theValue(testingSuperInvoked) should] beYes];
					});
					context(@"infoForBinding:", ^{
						__block NSDictionary *bindingInfo = nil;
						beforeEach(^{
							bindingInfo = [sut infoForBinding:@"stackedAngle"];
						});
						it(@"should have a valid infoForBinding:", ^{
							[[bindingInfo shouldNot] beNil];
						});
						it(@"should have the bound dictionary as NSObservedObjectKey", ^{
							[[bindingInfo[NSObservedObjectKey] should] equal:observedDict];
						});
						it(@"should have angle as NSObservedKeyPathKey", ^{
							[[bindingInfo[NSObservedKeyPathKey] should] equal:@"angle"];
						});
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
					it(@"should call the supers implementation", ^{
						[sut unbind:@"stackedAngle"];
						[[theValue(testingSuperInvoked) should] beYes];
					});
				});

				
			});
		});
		context(@"observeValueForKeyPath:ofObject:change:context:", ^{
			context(@"unhandled observing contexts", ^{
				__block Method supersMethod;
				__block Method testingMethod;

				beforeEach(^{
					supersMethod = class_getInstanceMethod([sut superclass], @selector(observeValueForKeyPath:ofObject:change:context:));
					testingMethod = class_getInstanceMethod([sut class], @selector(mmTesting_observeValueForKeyPath:ofObject:change:context:));
					method_exchangeImplementations(supersMethod, testingMethod);
					testingSuperInvoked = NO;
				});
				afterEach(^{
					method_exchangeImplementations(testingMethod, supersMethod);
				});
				it(@"should call up to supers implementation", ^{
					[sut observeValueForKeyPath:@"testing" ofObject:[KWNull null] change:nil context:NULL];
					[[theValue(testingSuperInvoked) should] beYes];
				});
			});
		});
	});
});

SPEC_END
