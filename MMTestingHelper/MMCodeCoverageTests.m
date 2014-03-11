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
//  MMCodeCoverageTests.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 09.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

// Add MM_IS_COVERAGE_BUILD to your GCC_PREPROCESSOR_DEFINITIONS for the
// Xcode Configuration that wants CodeCoverage support.
#if MM_IS_COVERAGE_BUILD

#import "NSApplication+MMCodeCoverageFixer.h"

extern void __gcov_flush();

@interface MMCodeCoverageTests : XCTestObserver

@end

@implementation MMCodeCoverageTests

- (void)stopObserving {
	[super stopObserving];
	
	// Call gtm_gcov_flush in the application executable unit.
	id application = [NSApplication sharedApplication];
	if ([application respondsToSelector:@selector(gtm_gcov_flush)]) {
		[application performSelector:@selector(gtm_gcov_flush)];
	}
	
	// Call flush for this executable unit.
	__gcov_flush();
	
	// Reset defaults back to what they should be.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:XCTestObserverClassKey];
}

+ (void)load {
	// Verify that all of our assumptions in [GTMCodeCoverageApp load] still stand
	NSString *selfClass = NSStringFromClass(self);
	BOOL mustExit = NO;
	if (![selfClass isEqual:@"MMCodeCoverageTests"]) {
		NSLog(@"Can't change MMCodeCoverageTests name to %@ without updating GTMCoverageApp",
			  selfClass);
		mustExit = YES;
	}
	if (mustExit) {
		exit(1);
	}
}

@end

#endif // MM_IS_COVERAGE_BUILD
