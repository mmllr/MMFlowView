/*
 Copyright (c) 2012, Markus Müller, www.isnotnil.com
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  AppDelegate.h
//  FlowView
//
//  Created by Markus Müller on 13.01.12.
//  Copyright (c) 2012 www.isnotnil.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MMFlowView.h"
@class IKImageBrowserView;

@interface AppDelegate : NSObject <NSApplicationDelegate,MMFlowViewDataSource,MMFlowViewDelegate>
{
@private
	NSMutableArray *items;
	NSSlider *reflectionSlider;
	IKImageBrowserView *imageBrowserView;
	NSArrayController *itemArrayController;
	NSWindow *window;
	MMFlowView *flowView;
}

@property (copy,nonatomic) NSArray *items;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet MMFlowView *flowView;
@property (assign) IBOutlet NSSlider *reflectionSlider;
@property (assign) IBOutlet IKImageBrowserView *imageBrowserView;
@property (assign) IBOutlet NSArrayController *itemArrayController;

- (IBAction)toggleReflection:(id)sender;
- (IBAction)toggleAngle:(id)sender;
- (IBAction)toggleSpacing:(id)sender;
- (IBAction)reflectionChanged:(NSSlider *)sender;
- (IBAction)previewScaleChanged:(NSSlider *)sender;

@end
