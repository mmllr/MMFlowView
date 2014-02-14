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


- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
	return 1;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
	id item = [ self imageItemForIndex:self.selectedIndex ];
	if ( [ [ [ self class ] pathRepresentationTypes ] containsObject:[ self imageRepresentationTypeForItem:item ] ] ) {
		id representation = [ self imageRepresentationForItem:item ];
		NSURL *previewURL = [ representation isKindOfClass:[ NSURL class ] ] ? representation : [ NSURL fileURLWithPath:representation ];
		return previewURL;
	}
	return nil;
}


@end
