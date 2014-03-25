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
//  NSArrayMMAdditionsSpec.m
//
//  Created by Markus Müller on 23.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "NSArray+MMAdditions.h"

static void *testingContext = @"NSArray+MMAddittions test context";

@interface TestObserver : NSObject

@end

@implementation TestObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == testingContext) {

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

SPEC_BEGIN(NSArrayMMAdditionsSpec)

describe(@"NSArray+MMAdditions", ^{
	__block NSArray *sut = nil;

	afterEach(^{
		sut = nil;
	});
	context(@"KVO", ^{
		__block TestObserver *testObserver = nil;
		__block NSMutableDictionary *aDict = nil;
		__block NSMutableDictionary *anotherDict = nil;
		__block NSIndexSet *indexes = nil;
		NSArray *observedKeyPaths = @[@"name"];

		beforeEach(^{
			testObserver = [[TestObserver alloc] init];
			aDict = [NSMutableDictionary dictionary];
			aDict[@"name"] = @"a name";
			anotherDict = [NSMutableDictionary dictionary];
			anotherDict[@"name"] = @"another name";
			sut = @[aDict, anotherDict];
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [sut count])];
		});
		afterEach(^{
			indexes = nil;
			testObserver = nil;
			aDict = nil;
			anotherDict = nil;
		});
		context(NSStringFromSelector(@selector(mm_addObserver:forKeyPaths:context:)), ^{
			it(@"should add the observer to all items in the array for all key paths", ^{
				for ( NSString *keyPath in observedKeyPaths) {
					[[sut should] receive:@selector(addObserver:toObjectsAtIndexes:forKeyPath:options:context:) withArguments:testObserver, indexes, keyPath, [KWAny any], theValue(testingContext)];
				}
				[sut mm_addObserver:testObserver forKeyPaths:observedKeyPaths context:testingContext];
			});
			it(@"should add the observer to the dictionaries", ^{
				[sut mm_addObserver:testObserver forKeyPaths:observedKeyPaths context:testingContext];
				[[testObserver should] receive:@selector(observeValueForKeyPath:ofObject:change:context:)
							  withCountAtLeast:1
									 arguments:@"name", [sut firstObject], [KWAny any], theValue(testingContext)];
				NSMutableDictionary *firstDict = [sut firstObject];
				firstDict[@"name"] = @"name changed";
			});
			it(@"should not add an observer for a null placeholder key path", ^{
				[[sut shouldNot] receive:@selector(addObserver:toObjectsAtIndexes:forKeyPath:options:context:) withArguments:testObserver, indexes, [NSNull null], [KWAny any], theValue(testingContext)];
				[sut mm_addObserver:testObserver forKeyPaths:@[[NSNull null]] context:testingContext];
			});
		});
		context(NSStringFromSelector(@selector(mm_removeObserver:forKeyPaths:context:)), ^{
			beforeEach(^{
				[sut mm_addObserver:testObserver forKeyPaths:observedKeyPaths context:testingContext];
			});
			it(@"should remove the observer", ^{
				for ( NSString *keyPath in observedKeyPaths) {
					[[sut should] receive:@selector(removeObserver:fromObjectsAtIndexes:forKeyPath:context:) withArguments:testObserver, indexes, keyPath, theValue(testingContext)];
				}
				[sut mm_removeObserver:testObserver forKeyPaths:observedKeyPaths context:testingContext];
			});
			it(@"should not remove an observer for a null placeholder key path", ^{
				[[sut shouldNot] receive:@selector(removeObserver:fromObjectsAtIndexes:forKeyPath:context:) withArguments:testObserver, indexes, [NSNull null], theValue(testingContext)];
				[sut mm_removeObserver:testObserver forKeyPaths:@[[NSNull null]] context:testingContext];
			});
		});
	});
});

SPEC_END
