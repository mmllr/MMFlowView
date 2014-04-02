//
//  MMFlowViewDatasourceContentAdapter.m
//  Pods
//
//  Created by Markus Müller on 01.04.14.
//
//

#import "MMFlowViewDatasourceContentAdapter.h"
#import "MMFlowView.h"

@interface MMFlowViewDatasourceContentAdapter ()

@property (nonatomic, weak) MMFlowView *flowView;

@end

@implementation MMFlowViewDatasourceContentAdapter

- (instancetype)init
{
    return [self initWithFlowView:nil];
}

- (id)initWithFlowView:(MMFlowView*)aFlowView
{
	NSParameterAssert(aFlowView);
	
	self = [super init];
	if (self) {
		_flowView = aFlowView;
	}
	return self;
}

- (NSUInteger)count
{
	if ([self.flowView.dataSource respondsToSelector:@selector(numberOfItemsInFlowView:)]) {
		return [self.flowView.dataSource numberOfItemsInFlowView:self.flowView];
	}
	return 0;
}

- (id<MMFlowViewItem>)objectAtIndexedSubscript:(NSUInteger)anIndex
{
	if (self.count && anIndex >= self.count) {
		NSString *reason = [NSString stringWithFormat:@"Index %@ out of bounds (%@)", @(anIndex), @(self.count)];
		@throw [NSException exceptionWithName:NSRangeException
									   reason:reason
									 userInfo:nil];
	}
	if ([self.flowView.dataSource respondsToSelector:@selector(flowView:itemAtIndex:)]) {
		return [self.flowView.dataSource flowView:self.flowView itemAtIndex:anIndex];
	}
	return nil;
}

@end
