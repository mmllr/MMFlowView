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
//  MMLayerAccessibilitySpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 11.01.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMLayerAccessibility.h"
#import "CALayer+NSAccessibility.h"

SPEC_BEGIN(MMLayerAccessibilitySpec)

describe(@"MMLayerAccessibility", ^{
	__block MMLayerAccessibilityDelegate *sut = nil;

	context(@"creating with default -init", ^{
		it(@"should raise if created with -init", ^{
			[[theBlock(^{
				sut = [[MMLayerAccessibilityDelegate alloc] init];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
	context(@"a new instance created with designated initializer", ^{
		__block id layerMock = nil;

		beforeEach(^{
			layerMock = [KWMock mockForClass:[CALayer layer]];
			sut = [[MMLayerAccessibilityDelegate alloc] initWithLayer:layerMock];
		});
		afterEach(^{
			sut = nil;
			layerMock = nil;
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should resond to attributeNames", ^{
			[[sut should] respondToSelector:@selector(attributeNames)];
		});
		it(@"should return an NSArray for attributeNames", ^{
			[[[sut attributeNames] should] beKindOfClass:[NSArray class]];
		});
		it(@"should respond to layer", ^{
			[[sut should] respondToSelector:@selector(layer)];
		});
		it(@"should conform to MMLayerAccessibility", ^{
			[[sut should] conformToProtocol:@protocol(MMLayerAccessibility)];
		});
		context(@"MMLayerAccessibility", ^{
			context(@"setReadableAccessibilityAttribute:withBlock:", ^{
				it(@"should respond to setReadableAccessibilityAttribute:withBlock", ^{
					[[sut should] respondToSelector:@selector(setReadableAccessibilityAttribute:withBlock:)];
				});
				it(@"should throw an NSInternalInconsistencyException if invoked with empty handler", ^{
					[[theBlock(^{
						[sut setReadableAccessibilityAttribute:NSAccessibilityRoleAttribute withBlock:nil ];
					}) should] raiseWithName:NSInternalInconsistencyException];
				});
				it(@"should throw an NSInternalInconsistencyException when if invoked with nil attribute", ^{
					[[theBlock(^{
						[sut setReadableAccessibilityAttribute:nil withBlock:^id{
							return nil;
						}];
					}) should] raiseWithName:NSInternalInconsistencyException];
				});
				context(@"with readable attribute", ^{
					NSString *value = @"value";

					beforeEach(^{
						[sut setReadableAccessibilityAttribute:@"myAttribute" withBlock:^id{
							return value;
						}];
					});
					it(@"attributeNames should contain the attribute", ^{
						[[sut.attributeNames should] contain:@"myAttribute"];
					});
					it(@"should return the block return value when asking for the attribute", ^{
						[[[sut attributeValue:@"myAttribute"] should] equal:value];
					});
				});
				
			});
			context(@"setWritableAccessibilityAttribute:readBlock:writeBlock:", ^{
				it(@"should respond to setWritableAccessibilityAttribute:readBlock:writeBlock:", ^{
					[[sut should] respondToSelector:@selector(setWritableAccessibilityAttribute:readBlock:writeBlock:)];
				});
				it(@"should raise an NSInternalInconsistencyException with empty getter", ^{
					[[theBlock(^{
						[sut setWritableAccessibilityAttribute:NSAccessibilityRoleAttribute readBlock:nil writeBlock:^(id value){
						}];
					}) should] raiseWithName:NSInternalInconsistencyException];
				});
				it(@"should throw an NSInternalInconsistencyException when invoked with nil attribute", ^{
					[[theBlock(^{
						[sut setWritableAccessibilityAttribute:nil readBlock:^id{
							return nil;
						} writeBlock:^(id value) {
						}];
					}) should] raiseWithName:NSInternalInconsistencyException];
				});
				it(@"should raise an NSInternalInconsistencyException with empty setter", ^{
					[[theBlock(^{
						[sut setWritableAccessibilityAttribute:NSAccessibilityRoleAttribute readBlock:(id(^)(void))^{
							return nil;
						}writeBlock:nil];
					}) should] raiseWithName:NSInternalInconsistencyException];
				});
				it(@"should raise an NSInternalInconsistencyException with empty getter and setter", ^{
					[[theBlock(^{
						[sut setWritableAccessibilityAttribute:NSAccessibilityRoleAttribute readBlock:nil writeBlock:nil ];
					}) should] raiseWithName:NSInternalInconsistencyException];
				});
				context(@"adding a writable attribute", ^{
					__block NSNumber *testValue = nil;
					__block id invocationMock = nil;

					beforeEach(^{
						testValue = @NO;
						invocationMock = [NSObject nullMock];
						[sut setWritableAccessibilityAttribute:@"aWritableAttribute" readBlock:^id{
							return testValue;
						} writeBlock:^(id value) {
							[invocationMock setValue:value forKey:@"aWritableAttribute"];
						}];
					});
					it(@"should return the initial test value", ^{
						[[[sut attributeValue:@"aWritableAttribute"] should] equal:@NO];
					});
					it(@"should return the modified value after setting", ^{
						[[invocationMock should] receive:@selector(setValue:forKey:) withArguments:@YES, @"aWritableAttribute"];
						[sut setValue:@YES forAttribute:@"aWritableAttribute"];
					});
				});
			});
			context(@"removeAccessibilityAttribute:", ^{
				it(@"should respond tor removeAccessibilityAttribute:", ^{
					[[sut should] respondToSelector:@selector(removeAccessibilityAttribute:)];
				});
				it(@"should raise an NSInternalInconsistencyException with nil attribute", ^{
					[[theBlock(^{
						[sut removeAccessibilityAttribute:nil];
					}) should] raiseWithName:NSInternalInconsistencyException];
				});
			});
			context(@"setAccessibilityAction:withBlock:", ^{
				it(@"should respond tor setAccessibilityAction:withBlock:", ^{
					[[sut should] respondToSelector:@selector(setAccessibilityAction:withBlock:)];
				});
				it(@"should throw an NSInternalInconsistencyException when if invoked with nil attribute", ^{
					[[theBlock(^{
						[sut setAccessibilityAction:nil withBlock:^{
						}];
					}) should] raiseWithName:NSInternalInconsistencyException];
				});
				it(@"should raise an NSInternalInconsistencyException with empty action handler", ^{
					[[theBlock(^{
						[sut setAccessibilityAction:NSAccessibilityPressAction
										  withBlock:nil ];
					}) should] raise];
				});
				
			});
			context(@"setParameterizedAccessibilityAttribute:withBlock:", ^{
				it(@"should respond to accessibilityParameterizedAttributeNames", ^{
					[[sut should] respondToSelector:@selector(accessibilityParameterizedAttributeNames)];
				});
				it(@"should throw an NSInternalInconsistencyException when if invoked with nil attribute", ^{
					[[theBlock(^{
						[sut setParameterizedAccessibilityAttribute:nil withBlock:^id(id value){
							return nil;
						}];
					}) should] raiseWithName:NSInternalInconsistencyException];
				});
				it(@"should raise an NSInternalInconsistencyException with empty handler", ^{
					[[theBlock(^{
						[sut setParameterizedAccessibilityAttribute:NSAccessibilityLineForIndexParameterizedAttribute withBlock:nil];
					}) should] raiseWithName:NSInternalInconsistencyException];
				});
			});
		});
	});
});

SPEC_END
