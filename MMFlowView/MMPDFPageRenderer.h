//
//  MMPDFPageRenderer.h
//  MMFlowViewDemo
//
//  Created by Markus Müller on 22.01.14.
//  Copyright (c) 2014 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface MMPDFPageRenderer : NSObject

- (id)initWithPDFPage:(CGPDFPageRef)aPage;

@property (nonatomic, readonly) CGPDFPageRef page;
@property (nonatomic) CGSize imageSize;
@property (nonatomic, readonly) NSAffineTransform *affineTransform;
@property (strong) NSColor *backgroundColor;
@property (nonatomic, strong, readonly) NSBitmapImageRep *imageRepresentation;

@end
