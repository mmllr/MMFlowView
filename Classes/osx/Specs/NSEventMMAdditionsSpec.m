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
//  NSEventMMAdditionsSpec.m
//
//  Created by Markus Müller on 23.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "NSEvent+MMAdditions.h"

SPEC_BEGIN(NSEventMMAdditionsSpec)

describe(@"NSEvent+MMAdditions", ^{
	__block NSEvent *sut = nil;

	beforeEach(^{
		sut = [[NSEvent alloc] init];
	});
	afterEach(^{
		sut = nil;
	});
	context(NSStringFromSelector(@selector(dominantDeltaInXYSpace)), ^{
		context(@"when the events absolute deltaX is greater than deltaY", ^{
			beforeEach(^{
				[sut stub:@selector(deltaX) andReturn:theValue(10)];
				[sut stub:@selector(deltaY) andReturn:theValue(-5)];
			});
			it(@"should return deltaX", ^{
				[[theValue(sut.dominantDeltaInXYSpace) should] equal:10 withDelta:0.0000001];
			});
		});
		context(@"when the events absolute deltaX is equal to deltaY", ^{
			beforeEach(^{
				[sut stub:@selector(deltaX) andReturn:theValue(-5)];
				[sut stub:@selector(deltaY) andReturn:theValue(-5)];
			});
			it(@"should return deltaX", ^{
				[[theValue(sut.dominantDeltaInXYSpace) should] equal:-5 withDelta:0.0000001];
			});
		});
		context(@"when the events absolute deltaX is less than deltaY", ^{
			beforeEach(^{
				[sut stub:@selector(deltaX) andReturn:theValue(-5)];
				[sut stub:@selector(deltaY) andReturn:theValue(-6)];
			});
			it(@"should return deltaY", ^{
				[[theValue(sut.dominantDeltaInXYSpace) should] equal:-6 withDelta:0.0000001];
			});
		});
	});
});

SPEC_END
