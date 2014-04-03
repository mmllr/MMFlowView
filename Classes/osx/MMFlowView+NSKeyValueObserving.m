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

@implementation MMFlowView (NSKeyValueObserving)

+ (NSArray*)observedItemKeyPaths
{
	static NSArray *keys = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		keys = @[NSStringFromSelector(@selector(imageItemRepresentation)),
				 NSStringFromSelector(@selector(imageItemRepresentationType)),
				 NSStringFromSelector(@selector(imageItemUID))];
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
		[self.contentArrayController removeObserver:self
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
}

- (void)tearDownObservations
{
	[self.coverFlowLayout unbind:@"stackedAngle"];
	[self.coverFlowLayout unbind:@"interItemSpacing"];
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
		[onlyNew mm_addObserver:self forKeyPaths:[[self class] observedItemKeyPaths] context:kMMFlowViewIndividualItemKeyPathsObservationContext];
		
		NSMutableArray *removed = [self.observedItems mutableCopy];
		[removed removeObjectsInArray:newItems];
		[removed mm_removeObserver:self forKeyPaths:[[self class] observedItemKeyPaths] context:kMMFlowViewIndividualItemKeyPathsObservationContext];
		self.observedItems = newItems;

		[self reloadContent];
	}
	else if (context == kMMFlowViewIndividualItemKeyPathsObservationContext) {
		id<MMFlowViewItem> item = (id<MMFlowViewItem>)observedObject;

		if ( [keyPath isEqualToString:NSStringFromSelector(@selector(imageItemRepresentation))] ||
			[keyPath isEqualToString:NSStringFromSelector(@selector(imageItemRepresentationType))] ||
			[keyPath isEqualToString:NSStringFromSelector(@selector(imageItemUID))] ) {
			[self.imageCache removeImageWithUUID:item.imageItemUID];
			[self.coverFlowLayer setNeedsLayout];
		}
		else if ( [keyPath isEqualToString:NSStringFromSelector(@selector(imageItemTitle))] ) {
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
