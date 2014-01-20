//
//  MMFlowViewImageCache.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 02.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMFlowViewImageCache <NSObject>

- (void)cacheImage:(id)anImage withUID:(id)anUID;
- (void)imageForUID:(id)anUID;

@end

