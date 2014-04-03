//
//  MMFlowViewContentBinder.m
//  Pods
//
//  Created by Markus Müller on 02.04.14.
//
//

#import "MMFlowViewContentBinder.h"
#import "MMFlowView.h"
#import "NSArray+MMAdditions.h"

void * const kMFlowViewContentBinderArrayObservationContext = @"MFlowViewContentBinderArrayObservationContext";
void * const kMFlowViewContentBinderItemObservationContext = @"MFlowViewContentBinderItemObservationContext";

@interface MMFlowViewContentBinder ()

@property (nonatomic, strong) NSArrayController *controller;
@property (nonatomic, readwrite) NSArray *observedItems;

@end

@implementation MMFlowViewContentBinder

@dynamic contentArray;
@dynamic observedItemKeys;

- (instancetype)init
{
	return [self initWithArrayController:nil withContentArrayKeyPath:nil];
}

- (instancetype)initWithArrayController:(NSArrayController *)controller withContentArrayKeyPath:(NSString *)keyPath
{
	NSParameterAssert(controller);
	NSParameterAssert([[controller objectClass] instancesRespondToSelector:@selector(imageItemRepresentation)]);
	NSParameterAssert([[controller objectClass] instancesRespondToSelector:@selector(imageItemRepresentationType)]);
	NSParameterAssert([[controller objectClass] instancesRespondToSelector:@selector(imageItemUID)]);
	NSParameterAssert(keyPath);

	self = [super init];
	if (self) {
		_controller = controller;
		_contentArrayKeyPath = [keyPath copy];
		_observedItems = nil;
	}
	return self;
}

- (void)dealloc
{
	[self stopObservingContent];
}

- (NSArray*)observedItemKeys
{
	static NSArray *mandantoryKeys = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		mandantoryKeys = @[NSStringFromSelector(@selector(imageItemRepresentation)), NSStringFromSelector(@selector(imageItemRepresentationType)), NSStringFromSelector(@selector(imageItemUID))];
	});
	return mandantoryKeys;
}

- (NSArray*)contentArray
{
	return @[];
}

- (void)startObservingContent
{
	[self.controller addObserver:self
					  forKeyPath:self.contentArrayKeyPath
						 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
						 context:kMFlowViewContentBinderArrayObservationContext];
}

- (void)stopObservingContent
{
	if (self.observedItems) {
		[self.observedItems mm_removeObserver:self forKeyPaths:self.observedItemKeys context:kMFlowViewContentBinderItemObservationContext];
		[self.controller removeObserver:self forKeyPath:self.contentArrayKeyPath context:kMFlowViewContentBinderArrayObservationContext];
		self.observedItems = nil;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)observedObject change:(NSDictionary *)change context:(void *)context
{
    if (context == kMFlowViewContentBinderArrayObservationContext) {
        NSParameterAssert(observedObject == self.controller);
		NSParameterAssert([keyPath isEqualToString:self.contentArrayKeyPath]);

		// Have items been removed from the bound-to container?
		/*
		 Should be able to use
		 NSArray *oldItems = [change objectForKey:NSKeyValueChangeOldKey];
		 etc. but the dictionary doesn't contain old and new arrays.
		 */
		NSArray *newItems = [observedObject valueForKeyPath:keyPath];

		NSMutableArray *onlyNew = [NSMutableArray arrayWithArray:newItems];
		[onlyNew removeObjectsInArray:self.observedItems];
		[onlyNew mm_addObserver:self forKeyPaths:self.observedItemKeys context:kMFlowViewContentBinderItemObservationContext];

		NSMutableArray *removed = [self.observedItems mutableCopy];
		[removed removeObjectsInArray:newItems];
		[removed mm_removeObserver:self forKeyPaths:self.observedItemKeys context:kMFlowViewContentBinderItemObservationContext];
		self.observedItems = [newItems copy];

		if ([self.delegate respondsToSelector:@selector(contentArrayDidChange:)]) {
			[self.delegate contentArrayDidChange:self];
		}
    }
	else if (context == kMFlowViewContentBinderItemObservationContext) {
		NSParameterAssert([observedObject isKindOfClass:[self.controller objectClass]]);

		[self.delegate contentBinder:self itemChanged:observedObject];
	}
	else {
        [super observeValueForKeyPath:keyPath ofObject:observedObject change:change context:context];
    }
}

@end
