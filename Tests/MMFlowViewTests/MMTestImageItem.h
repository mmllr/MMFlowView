//
//  MMTestImageItem.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 03.04.14.
//  Copyright (c) 2014 Markus Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMFlowView.h"

@interface MMTestImageItem : NSObject <MMFlowViewItem>

@property (nonatomic, strong) NSString *imageItemUID;
@property (nonatomic, strong) NSString *imageItemRepresentationType;
@property (nonatomic, strong) id imageItemRepresentation;
@property (nonatomic, strong) NSString *imageItemTitle;

@end
