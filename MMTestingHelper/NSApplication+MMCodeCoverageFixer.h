//
//  NSApplication+MMCodeCoverageFixer.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 09.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSApplication (MMCodeCoverageFixer)

- (void)gtm_gcov_flush;

@end
