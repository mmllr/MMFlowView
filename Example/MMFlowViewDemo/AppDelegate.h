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
//  AppDelegate.h
//  FlowView
//
//  Created by Markus Müller on 13.01.12.
//  Copyright (c) 2012 www.isnotnil.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MMFlowView.h>
@class IKImageBrowserView;

@interface AppDelegate : NSObject <NSApplicationDelegate,MMFlowViewDataSource,MMFlowViewDelegate>

@property (copy,nonatomic) NSArray *items;
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet MMFlowView *flowView;
@property (weak) IBOutlet NSSlider *reflectionSlider;
@property (weak) IBOutlet IKImageBrowserView *imageBrowserView;
@property (weak) IBOutlet NSArrayController *itemArrayController;

- (IBAction)toggleReflection:(id)sender;
- (IBAction)toggleAngle:(id)sender;
- (IBAction)toggleSpacing:(id)sender;
- (IBAction)reflectionChanged:(NSSlider *)sender;

@end
