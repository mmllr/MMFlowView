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
#import "MMFlowViewContentBinder.h"
#import "MMTestImageItem.h"
#import "MMCoverFLowLayout.h"

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

@end

SPEC_BEGIN(MMFlowViewKeyValueObservingSpec)

describe(@"NSKeyValueObserving", ^{
	__block NSArray *mockedItems = nil;
	const NSInteger numberOfItems = 10;
	
	beforeAll(^{
		NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:numberOfItems];
		for ( NSInteger i = 0; i < numberOfItems; ++i) {
			[itemArray addObject:[MMTestImageItem new]];
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

		context(NSStringFromSelector(@selector(tearDownObservations)), ^{
			it(@"should unbind the stackedAngle from the layout", ^{
				[[sut.coverFlowLayout should] receive:@selector(unbind:) withArguments:NSStringFromSelector(@selector(stackedAngle))];
				
				[sut tearDownObservations];
			});
			it(@"should unbind the interItemSpacing from the layout", ^{
				[[sut.coverFlowLayout should] receive:@selector(unbind:) withArguments:NSStringFromSelector(@selector(interItemSpacing))];
				
				[sut tearDownObservations];
			});
		});

		context(@"bindings", ^{
			__block NSArray *exposedBindings = nil;
			__block NSArrayController *arrayController = nil;
			NSString *arrangedObjectsKeyPath = @"arrangedObjects";
			
			beforeAll(^{
				arrayController = [[NSArrayController alloc] initWithContent:mockedItems];
				id item = [mockedItems firstObject];
				[arrayController setObjectClass:[item class]];
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
	
			context(NSStringFromSelector(@selector(bind:toObject:withKeyPath:options:)), ^{
				context(@"when binding the NSContentArrayBinding to an NSArrayController", ^{
					beforeEach(^{
						[sut bind:NSContentArrayBinding toObject:arrayController withKeyPath:arrangedObjectsKeyPath options:nil];
					});
					afterEach(^{
						[sut unbind:NSContentArrayBinding];
					});
					it(@"should have a content binder", ^{
						[[sut.contentBinder shouldNot] beNil];
					});
					it(@"should be the delegate of the content binder", ^{
						[[(id)sut.contentBinder.delegate should] equal:sut];
					});
					it(@"should be bound to the array controller", ^{
						[[sut.contentAdapter should] equal:mockedItems];
					});
					it(@"should have the same number of items", ^{
						[[theValue(sut.numberOfItems) should] equal:theValue([mockedItems count])];
					});
					context(@"when binding NSContentArrayBinding to another array controller", ^{
						__block id mockedArrayController = nil;

						beforeEach(^{
							mockedArrayController =[NSArrayController nullMock];
							[mockedArrayController stub:@selector(objectClass) andReturn:[MMTestImageItem class]];
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
					context(NSStringFromSelector(@selector(infoForBinding:)), ^{
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
			context(NSStringFromSelector(@selector(unbind:)), ^{
				context(@"when having a bound NSContentArrayBinding", ^{
					beforeEach(^{
						[sut bind:NSContentArrayBinding toObject:arrayController withKeyPath:arrangedObjectsKeyPath options:nil];
					});

					it(@"should return nil for infoForBinding", ^{
						[sut unbind:NSContentArrayBinding];
						[[[sut infoForBinding:NSContentArrayBinding] should] beNil];
					});

					it(@"should have a nil contentBinder", ^{
						[sut unbind:NSContentArrayBinding];

						[[sut.contentBinder should] beNil];
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

		
	});
});

SPEC_END
