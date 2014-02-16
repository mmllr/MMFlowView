//
//  MMFlowView+QLPreviewPanelDataSource.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+QLPreviewPanelDataSource.h"
#import "MMFlowView_Private.h"

@implementation MMFlowView (QLPreviewPanelDataSource)


- (BOOL)isPathRepresentationAtSelection
{
	id item = [self imageItemForIndex:self.selectedIndex];
	return [[[self class] pathRepresentationTypes] containsObject:[self imageRepresentationTypeForItem:item]];
}

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
	return [self isPathRepresentationAtSelection] ? 1 : 0;
}

- (id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
	if ([self isPathRepresentationAtSelection]) {
		id representation = [self imageRepresentationForItem:[self imageItemForIndex:self.selectedIndex]];
		return [representation isKindOfClass:[NSURL class]] ? representation : [NSURL fileURLWithPath:representation];
	}
	return nil;
}

@end
