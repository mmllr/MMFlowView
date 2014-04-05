//
//  MMFlowView+MMFlowViewContentBinderDelegate.m
//  Pods
//
//  Created by Markus Müller on 03.04.14.
//
//

#import "MMFlowView+MMFlowViewContentBinderDelegate.h"
#import "MMFlowView_Private.h"
#import "MMFlowViewImageCache.h"
#import "MMCoverFlowLayer.h"

@implementation MMFlowView (MMFlowViewContentBinderDelegate)

- (void)contentBinder:(MMFlowViewContentBinder *)contentBinder itemChanged:(id<MMFlowViewItem>)anItem
{
	[self.imageCache removeImageWithUUID:anItem.imageItemUID];
	[self.coverFlowLayer setNeedsLayout];
}

- (void)contentArrayDidChange:(MMFlowViewContentBinder *)contentBinder
{
	self.contentAdapter = contentBinder.observedItems;
	[self reloadContent];
}

@end
