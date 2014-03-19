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
//  NSApplication+MMCodeCoverageFixer.h
//
//  Created by Markus Müller on 09.01.14.
//  Modified for use with AppKit
//

#import <Cocoa/Cocoa.h>

@interface NSApplication (MMCodeCoverageFixer)

- (void)gtm_gcov_flush;

@end
