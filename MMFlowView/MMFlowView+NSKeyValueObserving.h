//
//  MMFlowView+NSKeyValueObserving.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 13.02.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import "MMFlowView.h"

@interface MMFlowView (NSKeyValueObserving)

@property (weak, nonatomic, readonly) NSArray *contentArray;
@property (weak, nonatomic, readonly) NSArrayController *contentArrayController;
@property (weak, nonatomic, readonly) NSString *contentArrayKeyPath;


@property (weak, nonatomic,readonly) NSSet *observedItemKeyPaths;
@property (nonatomic,readonly) BOOL bindingsEnabled;

- (void)startObservingCollection:(NSArray*)aCollection atKeyPaths:(NSSet*)keyPaths;
- (void)stopObservingCollection:(NSArray*)aCollection atKeyPaths:(NSSet*)keyPaths;

- (void)setUpBindings;
- (void)tearDownBindings;

@end
