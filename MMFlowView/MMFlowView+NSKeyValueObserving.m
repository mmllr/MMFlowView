//
//  MMFlowView+NSKeyValueObserving.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView+NSKeyValueObserving.h"
#import "MMFlowView_Private.h"
#import "MMFlowViewImageCache.h"

/* observation context */
static void * const kMMFlowViewContentArrayObservationContext = @"MMFlowViewContentArrayObservationContext";
static void * const kMMFlowViewIndividualItemKeyPathsObservationContext = @"kMMFlowViewIndividualItemKeyPathsObservationContext";


/* bindings */
NSString * const kMMFlowViewImageRepresentationBinding = @"imageRepresentationKeyPath";
NSString * const kMMFlowViewImageRepresentationTypeBinding = @"imageRepresentationTypeKeyPath";
NSString * const kMMFlowViewImageUIDBinding = @"imageUIDKeyPath";
NSString * const kMMFlowViewImageTitleBinding = @"imageTitleKeyPath";

/* default item keys */
static NSString * const kMMFlowViewItemImageRepresentationKey = @"imageItemRepresentation";
static NSString * const kMMFlowViewItemImageRepresentationTypeKey = @"imageItemRepresentationType";
static NSString * const kMMFlowViewItemImageUIDKey = @"imageItemUID";
static NSString * const kMMFlowViewItemImageTitleKey = @"imageItemTitle";

@implementation MMFlowView (NSKeyValueObserving)

- (void)startObservingCollection:(NSArray*)items atKeyPaths:(NSArray*)keyPaths
{
	if ( [ items isEqual:[NSNull null] ] || ![items count] ) {
		return;
	}
	NSIndexSet *allItemIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange( 0, [items count] )];
	for ( NSString *keyPath in keyPaths ) {
		[items addObserver:self
		toObjectsAtIndexes:allItemIndexes
				forKeyPath:keyPath
				   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial )
				   context:kMMFlowViewIndividualItemKeyPathsObservationContext];
	}
}

- (void)stopObservingCollection:(NSArray*)items atKeyPaths:(NSArray*)keyPaths
{
	if ( !items || [items isEqual:[NSNull null]] || ![items count] ) {
		return;
	}
	NSIndexSet *allItemIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange( 0, [items count] )];
	for ( NSString *keyPath in keyPaths ) {
		[items removeObserver:self
		 fromObjectsAtIndexes:allItemIndexes
				   forKeyPath:keyPath];
	}
}

#pragma mark -
#pragma mark Binding releated accessors

- (NSArrayController*)contentArrayController
{
	return [self infoForBinding:NSContentArrayBinding][NSObservedObjectKey];
}

- (NSString*)contentArrayKeyPath
{
	return [self infoForBinding:NSContentArrayBinding][NSObservedKeyPathKey];
}

- (NSArray *)contentArray
{
	NSArray *array = [self.contentArrayController valueForKeyPath:self.contentArrayKeyPath];
	return array ? array : @[];
}

- (NSSet*)observedItemKeyPaths
{
	NSMutableSet *observedItemKeyPaths = [NSMutableSet set];
	if (self.imageRepresentationKeyPath) {
		[observedItemKeyPaths addObject:self.imageRepresentationKeyPath];
	}
	if (self.imageRepresentationTypeKeyPath) {
		[observedItemKeyPaths addObject:self.imageRepresentationTypeKeyPath];
	}
	if (self.imageUIDKeyPath) {
		[observedItemKeyPaths addObject:self.imageUIDKeyPath];
	}
	if (self.imageTitleKeyPath) {
		[observedItemKeyPaths addObject:self.imageTitleKeyPath];
	}
	return [observedItemKeyPaths copy];
}

- (BOOL)bindingsEnabled
{
	return [self infoForBinding:NSContentArrayBinding] != nil;
}

#pragma mark -
#pragma mark NSKeyValueBindingCreation overrides

- (NSDictionary *)infoForBinding:(NSString *)binding
{
	if ([binding isEqualToString:NSContentArrayBinding]) {
		return self.contentArrayBindingInfo;
	}
	return [super infoForBinding:binding];
}

- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	if ([binding isEqualToString:NSContentArrayBinding]) {
		NSParameterAssert([observableController isKindOfClass:[NSArrayController class]]);

		if (self.contentArrayBindingInfo) {
			[self unbind:NSContentArrayBinding];
		}
		self.contentArrayBindingInfo = @{NSObservedObjectKey: observableController,
									   NSObservedKeyPathKey: [keyPath copy],
									   NSOptionsKey: options ? [options copy] : @{} };

		[observableController addObserver:self
							   forKeyPath:keyPath
								  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
								  context:kMMFlowViewContentArrayObservationContext];
		// set keypaths to MMFlowViewItem defaults
		if ( !self.imageRepresentationKeyPath ) {
			self.imageRepresentationKeyPath = kMMFlowViewItemImageRepresentationKey;
		}
		if ( !self.imageRepresentationTypeKeyPath ) {
			self.imageRepresentationTypeKeyPath = kMMFlowViewItemImageRepresentationTypeKey;
		}
		if ( !self.imageUIDKeyPath ) {
			self.imageUIDKeyPath = kMMFlowViewItemImageUIDKey;
		}
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
	if ([binding isEqualToString:NSContentArrayBinding] && [self infoForBinding:NSContentArrayBinding] ) {
		[self.contentArrayController removeObserver:self forKeyPath:self.contentArrayKeyPath context:kMMFlowViewContentArrayObservationContext];
		[self stopObservingCollection:self.contentArray atKeyPaths:self.observedItemKeyPaths];
		[self.layer setNeedsDisplay];
		self.contentArrayBindingInfo = nil;
	}
	else {
		[super unbind:binding];
	}
}

- (void)setUpBindings
{
	[self.layout bind:@"stackedAngle" toObject:self withKeyPath:@"stackedAngle" options:nil];
	[self.layout bind:@"interItemSpacing" toObject:self withKeyPath:@"spacing" options:nil];
}

- (void)tearDownBindings
{
	[self.layout unbind:@"stackedAngle"];
	[self.layout unbind:@"interItemSpacing"];
}

#pragma mark -
#pragma mark NSKeyValueObserving protocol

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)observedObject change:(NSDictionary *)change context:(void *)context
{
	if ( context == kMMFlowViewContentArrayObservationContext ) {
		// Have items been removed from the bound-to container?
		/*
		 Should be able to use
		 NSArray *oldItems = [change objectForKey:NSKeyValueChangeOldKey];
		 etc. but the dictionary doesn't contain old and new arrays.
		 */
		NSArray *newItems = [observedObject valueForKeyPath:keyPath];
		
		NSMutableArray *onlyNew = [NSMutableArray arrayWithArray:newItems];
		[onlyNew removeObjectsInArray:self.observedItems];
		[self startObservingCollection:onlyNew atKeyPaths:self.observedItemKeyPaths];
		
		NSMutableArray *removed = [self.observedItems mutableCopy];
		[removed removeObjectsInArray:newItems];
		[self stopObservingCollection:removed atKeyPaths:self.observedItemKeyPaths];
		self.observedItems = newItems;
		
		[self reloadContent];
	}
	else if ( context == kMMFlowViewIndividualItemKeyPathsObservationContext ) {
		// tracks individual item-properties and resets observations
		if ( [keyPath isEqualToString:self.imageUIDKeyPath] ||
			[keyPath isEqualToString:self.imageRepresentationKeyPath] ||
			[keyPath isEqualToString:self.imageRepresentationTypeKeyPath] ) {
			[self.imageCache removeImageWithUUID:[observedObject valueForKeyPath:self.imageUIDKeyPath]];
			[self.coverFlowLayer setNeedsLayout];
		}
		else if ( [keyPath isEqualToString:self.imageTitleKeyPath] ) {
			self.title = [observedObject valueForKeyPath:keyPath];
		}
	}
	else {
		[super observeValueForKeyPath:keyPath
							 ofObject:observedObject
							   change:change
							  context:context];
	}
}


@end
