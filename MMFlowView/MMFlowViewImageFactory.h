//
//  MMFlowViewImageFactory.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 17.12.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMFlowViewImageFactory : NSObject

- (BOOL)canDecodeRepresentationType:(NSString*)representationType;
- (void)createCGImageForItem:(id)item withRepresentationType:(NSString*)representationType maximumSize:(CGSize)maxiumSize completionHandler:(void(^)(CGImageRef image))completionHandler;
- (void)imageForItem:(id)item withRepresentationType:(NSString*)representationType completionHandler:(void(^)(NSImage *image))completionHandler;

@end
