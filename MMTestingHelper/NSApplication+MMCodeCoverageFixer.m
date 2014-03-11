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
//  NSApplication+MMCodeCoverageFixer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 09.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "NSApplication+MMCodeCoverageFixer.h"

// Add MM_IS_COVERAGE_BUILD to your GCC_PREPROCESSOR_DEFINITIONS for the
// Xcode Configuration that wants CodeCoverage support.
#if MM_IS_COVERAGE_BUILD

extern void __gcov_flush();

@implementation NSApplication (MMCodeCoverageFixer)

- (void)gtm_gcov_flush {
	__gcov_flush();
}

+ (void)load {
	// Using defines and strings so that we don't have to link in
	// XCTest here.
	// Must set defaults here. If we set them in XCTest we are too late
	// for the observer registration.
	// See the documentation of XCTestObserverClassKey for why we set this key.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *observers = [defaults stringForKey:@"XCTestObserverClass"];
	NSString *className = @"MMCodeCoverageTests";
	if (observers == nil) {
		observers = @"XCTestLog";
	}
	observers = [NSString stringWithFormat:@"%@,%@", observers, className];
	[defaults setValue:observers forKey:@"XCTestObserverClass"];
}

@end

#endif // MM_IS_COVERAGE_BUILD
