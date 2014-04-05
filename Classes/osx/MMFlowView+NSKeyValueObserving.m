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
//  MMFlowView+NSKeyValueObserving.m
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+NSKeyValueObserving.h"
#import "MMFlowView_Private.h"
#import "MMCoverFlowLayout.h"
#import "MMFlowViewContentBinder.h"
#import "MMFlowView+MMFlowViewContentBinderDelegate.h"

@implementation MMFlowView (NSKeyValueObserving)

#pragma mark -
#pragma mark NSKeyValueBindingCreation overrides

- (NSDictionary *)infoForBinding:(NSString *)binding
{
	if ([binding isEqualToString:NSContentArrayBinding]) {
		return self.contentBinder.bindingInfo;
	}
	return [super infoForBinding:binding];
}

- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	if ([binding isEqualToString:NSContentArrayBinding]) {
		NSParameterAssert([observableController isKindOfClass:[NSArrayController class]]);

		if (self.contentBinder) {
			[self unbind:NSContentArrayBinding];
		}
		self.contentBinder = [[MMFlowViewContentBinder alloc] initWithArrayController:observableController withContentArrayKeyPath:keyPath];
		[self.contentBinder startObservingContent];
	}
	else {
		[super bind:binding
		   toObject:observableController
		withKeyPath:keyPath
			options:options];
	}
}

- (void)unbind:(NSString*)binding
{
	if ([binding isEqualToString:NSContentArrayBinding]) {
		[self.contentBinder stopObservingContent];
		self.contentBinder = nil;
		[self.layer setNeedsDisplay];
	}
	else {
		[super unbind:binding];
	}
}

- (void)setUpObservations
{
	[self.coverFlowLayout bind:NSStringFromSelector(@selector(stackedAngle)) toObject:self withKeyPath:NSStringFromSelector(@selector(stackedAngle)) options:nil];
	[self.coverFlowLayout bind:NSStringFromSelector(@selector(interItemSpacing)) toObject:self withKeyPath:NSStringFromSelector(@selector(spacing)) options:nil];
}

- (void)tearDownObservations
{
	[self.coverFlowLayout unbind:NSStringFromSelector(@selector(stackedAngle))];
	[self.coverFlowLayout unbind:NSStringFromSelector(@selector(interItemSpacing))];
}

@end
