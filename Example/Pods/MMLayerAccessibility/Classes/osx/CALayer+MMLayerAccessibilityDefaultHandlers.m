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
//  CALayer+MMLayerAccessibilityDefaultHandlers.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 14.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "CALayer+MMLayerAccessibilityDefaultHandlers.h"
#import "CALayer+MMLayerAccessibilityPrivate.h"

@implementation CALayer (MMLayerAccessibilityDefaultHandlers)

#pragma mark - class methods

+ (NSArray*)defaultAccessibilityAttributes
{
	static NSArray *defaultAttributes = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultAttributes = @[NSAccessibilityParentAttribute, NSAccessibilitySizeAttribute, NSAccessibilityPositionAttribute, NSAccessibilityWindowAttribute, NSAccessibilityTopLevelUIElementAttribute, NSAccessibilityRoleAttribute, NSAccessibilityRoleDescriptionAttribute, NSAccessibilityEnabledAttribute, NSAccessibilityFocusedAttribute];
	});
	return defaultAttributes;
}

#pragma mark - default handlers

- (NSRect)mm_rectInScreen
{
	NSView *containingView = [self mm_containingView];
	CGRect rectInLayer = [containingView.layer convertRect:self.frame
												fromLayer:self.superlayer];
	NSRect windowRect = [containingView convertRect:[containingView convertRectFromLayer:rectInLayer]
										   fromView:nil];
	return [[containingView window] convertRectToScreen:windowRect];
}

- (id)mm_defaultPositionAttributeHandler
{
	return [NSValue valueWithPoint:[self mm_rectInScreen].origin];
}

- (id)mm_defaultSizeAttributeHandler
{
	return [NSValue valueWithSize:[self mm_rectInScreen].size];
}

- (id)mm_defaultParentAttributeHandler
{
	id parent = [self mm_accessibilityParent];
	if (parent) {
		return NSAccessibilityUnignoredAncestor(parent);
	}
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:@"No accessibility parent available"
								 userInfo:nil];
}

@end
