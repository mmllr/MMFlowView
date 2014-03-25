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
#import "MMFlowViewImageCache.h"
#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayer.h"
#import "NSArray+MMAdditions.h"

void * const kMMFlowViewContentArrayObservationContext = @"MMFlowViewContentArrayObservationContext";
void * const kMMFlowViewIndividualItemKeyPathsObservationContext = @"kMMFlowViewIndividualItemKeyPathsObservationContext";
void *const kMMFlowViewItemKeyPathsObservationContext = @"kMMFlowViewItemKeyPathsObservationContext";

NSString * const kMMFlowViewImageRepresentationBinding = @"imageRepresentationKeyPath";
NSString * const kMMFlowViewImageRepresentationTypeBinding = @"imageRepresentationTypeKeyPath";
NSString * const kMMFlowViewImageUIDBinding = @"imageUIDKeyPath";
NSString * const kMMFlowViewImageTitleBinding = @"imageTitleKeyPath";

static NSString * const kMMFlowViewItemImageRepresentationKey = @"imageItemRepresentation";
static NSString * const kMMFlowViewItemImageRepresentationTypeKey = @"imageItemRepresentationType";
static NSString * const kMMFlowViewItemImageUIDKey = @"imageItemUID";
static NSString * const kMMFlowViewItemImageTitleKey = @"imageItemTitle";

@implementation MMFlowView (NSKeyValueObserving)

+ (NSArray*)observedItemKeyPaths
{
	static NSArray *keys = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		keys = @[NSStringFromSelector(@selector(imageRepresentationKeyPath)),
				 NSStringFromSelector(@selector(imageRepresentationTypeKeyPath)),
				 NSStringFromSelector(@selector(imageUIDKeyPath))];
	});
	return keys;
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

- (NSArray*)observedItemKeyPaths
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
	return [observedItemKeyPaths allObjects];
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
		[observableController addObserver:self
							   forKeyPath:keyPath
								  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
								  context:kMMFlowViewContentArrayObservationContext];
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
		[self.contentArrayController
		 removeObserver:self
		 forKeyPath:self.contentArrayKeyPath
		 context:kMMFlowViewContentArrayObservationContext];
		[self.layer setNeedsDisplay];
		self.contentArrayBindingInfo = nil;
	}
	else {
		[super unbind:binding];
	}
}

- (void)setUpObservations
{
	[self.coverFlowLayout bind:@"stackedAngle" toObject:self withKeyPath:@"stackedAngle" options:nil];
	[self.coverFlowLayout bind:@"interItemSpacing" toObject:self withKeyPath:@"spacing" options:nil];

	for (NSString *keyPath in [[self class] observedItemKeyPaths]) {
		[self addObserver:self
			   forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
				  context:kMMFlowViewItemKeyPathsObservationContext];
	}
}

- (void)tearDownObservations
{
	[self.coverFlowLayout unbind:@"stackedAngle"];
	[self.coverFlowLayout unbind:@"interItemSpacing"];
	for (NSString *keyPath in [[self class] observedItemKeyPaths]) {
		[self removeObserver:self forKeyPath:keyPath context:kMMFlowViewItemKeyPathsObservationContext];
	}
}

#pragma mark -
#pragma mark NSKeyValueObserving protocol

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)observedObject change:(NSDictionary *)change context:(void *)context
{
	if (context == kMMFlowViewContentArrayObservationContext) {
		// Have items been removed from the bound-to container?
		/*
		 Should be able to use
		 NSArray *oldItems = [change objectForKey:NSKeyValueChangeOldKey];
		 etc. but the dictionary doesn't contain old and new arrays.
		 */
		NSArray *newItems = [observedObject valueForKeyPath:keyPath];
		
		NSMutableArray *onlyNew = [NSMutableArray arrayWithArray:newItems];
		[onlyNew removeObjectsInArray:self.observedItems];
		[onlyNew mm_addObserver:self forKeyPaths:self.observedItemKeyPaths context:kMMFlowViewIndividualItemKeyPathsObservationContext];
		
		NSMutableArray *removed = [self.observedItems mutableCopy];
		[removed removeObjectsInArray:newItems];
		[removed mm_removeObserver:self forKeyPaths:self.observedItemKeyPaths context:kMMFlowViewIndividualItemKeyPathsObservationContext];
		self.observedItems = newItems;
		
		[self reloadContent];
	}
	else if (context == kMMFlowViewIndividualItemKeyPathsObservationContext) {
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
	else if (context == kMMFlowViewItemKeyPathsObservationContext) {
		[self.observedItems mm_removeObserver:self
								  forKeyPaths:@[change[NSKeyValueChangeOldKey]]
									  context:kMMFlowViewIndividualItemKeyPathsObservationContext];
		[self.observedItems mm_addObserver:self
							   forKeyPaths:@[change[NSKeyValueChangeNewKey]]
								   context:kMMFlowViewIndividualItemKeyPathsObservationContext];
	}
	else {
		[super observeValueForKeyPath:keyPath
							 ofObject:observedObject
							   change:change
							  context:context];
	}
}


@end
