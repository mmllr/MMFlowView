//
//  MMFlowViewDatasourceContentAdapter.h
//  Pods
//
//  Created by Markus Müller on 01.04.14.
//
//

#import <Foundation/Foundation.h>

#import "MMFlowViewContentAdapter.h"

@class MMFlowView;

@protocol MMFlowViewDataSource;

@interface MMFlowViewDatasourceContentAdapter : NSObject <MMFlowViewContentAdapter>

- (id)initWithFlowView:(MMFlowView*)aFlowView;

@end
