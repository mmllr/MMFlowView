//
//  MMFlowViewContentBinder.h
//  Pods
//
//  Created by Markus Müller on 02.04.14.
//
//

#import <Foundation/Foundation.h>

void * const kMFlowViewContentBinderArrayObservationContext;
void * const kMFlowViewContentBinderItemObservationContext;

@protocol MMFlowViewContentBinderDelegate;

@interface MMFlowViewContentBinder : NSObject

@property (nonatomic, weak) id<MMFlowViewContentBinderDelegate> delegate;
@property (nonatomic, readonly, copy) NSString *contentArrayKeyPath;
@property (nonatomic, readonly, copy) NSArray *observedItems;
@property (nonatomic, readonly) NSArray *observedItemKeys;
@property (nonatomic, readonly) NSDictionary *bindingInfo;

- (instancetype)initWithArrayController:(NSArrayController*)controller withContentArrayKeyPath:(NSString *)keyPath;
- (void)startObservingContent;
- (void)stopObservingContent;

@end

@protocol MMFlowViewItem;

@protocol MMFlowViewContentBinderDelegate <NSObject>

- (void)contentArrayDidChange:(MMFlowViewContentBinder*)contentBinder;
- (void)contentBinder:(MMFlowViewContentBinder*)contentBinder itemChanged:(id<MMFlowViewItem>)anItem;

@end
