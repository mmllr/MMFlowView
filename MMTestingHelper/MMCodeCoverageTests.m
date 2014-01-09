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
