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
//  Created by Markus Müller on 21.01.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSArray+MMAdditions.h"

static void *testingContext = @"NSArray+MMAddittions test context";

@interface NSArrayTestObserver : NSObject

@property (nonatomic, readonly) NSUInteger notificationCount;
@property (nonatomic, strong, readonly) NSMutableArray *notifications; // NSDictionary with keyPath/object

@end

@implementation NSArrayTestObserver

- (instancetype)init
{
	self = [super init];
	if (self) {
		_notifications = [NSMutableArray array];
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == testingContext) {
		_notificationCount++;
		[_notifications addObject:@{@"keyPath": keyPath ?: [NSNull null],
									@"object": object ?: [NSNull null]}];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end

@interface NSArrayMMAdditionsSpec : XCTestCase

@end

@implementation NSArrayMMAdditionsSpec

- (NSArray *)makeArrayWithObservableDictionaries
{
	NSMutableDictionary *aDict = [NSMutableDictionary dictionary];
	aDict[@"name"] = @"a name";
	NSMutableDictionary *anotherDict = [NSMutableDictionary dictionary];
	anotherDict[@"name"] = @"another name";
	return @[aDict, anotherDict];
}

- (void)testMMAddObserverAddsObserverForAllKeyPaths
{
	NSArrayTestObserver *testObserver = [[NSArrayTestObserver alloc] init];
	NSArray *sut = [self makeArrayWithObservableDictionaries];

	[sut mm_addObserver:testObserver forKeyPaths:@[@"name"] context:testingContext];

	NSMutableDictionary *firstDict = sut[0];
	firstDict[@"name"] = @"name changed";
	NSMutableDictionary *secondDict = sut[1];
	secondDict[@"name"] = @"second changed";

	XCTAssertGreaterThanOrEqual(testObserver.notificationCount, (NSUInteger)2);
}

- (void)testMMAddObserverNotifiesForTheObservedItems
{
	NSArrayTestObserver *testObserver = [[NSArrayTestObserver alloc] init];
	NSArray *sut = [self makeArrayWithObservableDictionaries];

	[sut mm_addObserver:testObserver forKeyPaths:@[@"name"] context:testingContext];

	NSMutableDictionary *firstDict = sut[0];
	firstDict[@"name"] = @"name changed";

	XCTAssertGreaterThanOrEqual(testObserver.notificationCount, (NSUInteger)1);
	XCTAssertEqualObjects(testObserver.notifications.lastObject[@"keyPath"], @"name");
	XCTAssertEqual(testObserver.notifications.lastObject[@"object"], firstDict);
}

- (void)testMMAddObserverDoesNotAddObserverForNullPlaceholderKeyPath
{
	NSArrayTestObserver *testObserver = [[NSArrayTestObserver alloc] init];
	NSArray *sut = [self makeArrayWithObservableDictionaries];

	[sut mm_addObserver:testObserver forKeyPaths:@[[NSNull null]] context:testingContext];

	NSMutableDictionary *firstDict = sut[0];
	firstDict[@"name"] = @"name changed";

	XCTAssertEqual(testObserver.notificationCount, (NSUInteger)0);
}

- (void)testMMRemoveObserverRemovesTheObserver
{
	NSArrayTestObserver *testObserver = [[NSArrayTestObserver alloc] init];
	NSArray *sut = [self makeArrayWithObservableDictionaries];

	[sut mm_addObserver:testObserver forKeyPaths:@[@"name"] context:testingContext];
	[sut mm_removeObserver:testObserver forKeyPaths:@[@"name"] context:testingContext];

	NSUInteger before = testObserver.notificationCount;
	NSMutableDictionary *firstDict = sut[0];
	firstDict[@"name"] = @"name changed";

	XCTAssertEqual(testObserver.notificationCount, before);
}

- (void)testMMRemoveObserverDoesNotRemoveObserverForNullPlaceholderKeyPath
{
	NSArrayTestObserver *testObserver = [[NSArrayTestObserver alloc] init];
	NSArray *sut = [self makeArrayWithObservableDictionaries];

	[sut mm_addObserver:testObserver forKeyPaths:@[@"name"] context:testingContext];
	[sut mm_removeObserver:testObserver forKeyPaths:@[[NSNull null]] context:testingContext];

	NSMutableDictionary *firstDict = sut[0];
	firstDict[@"name"] = @"name changed";

	XCTAssertGreaterThanOrEqual(testObserver.notificationCount, (NSUInteger)1);
}

@end
