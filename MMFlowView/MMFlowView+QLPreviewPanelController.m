//
//  MMFlowView+QLPreviewPanelController.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+QLPreviewPanelController.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+QLPreviewPanelDataSource.h"
#import "MMFlowView+QLPreviewPanelDelegate.h"

@implementation MMFlowView (QLPreviewPanelController)

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
{
	id item = [ self imageItemForIndex:self.selectedIndex ];
	return [ [ [ self class ] pathRepresentationTypes ] containsObject:[ self imageRepresentationTypeForItem:item ] ];
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
	panel.dataSource = self;
	panel.delegate = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
}

@end
