//  Copyright 2013 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//
//
//  NSApplication+MMCodeCoverageFixer.m
//
//  Created by Markus Müller on 09.01.14.
//  Modified for use with AppKit
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
