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
//  MMButtonLayer.h
//
//  Created by Markus Müller on 07.05.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#pragma mark -
#pragma mark MMButtonLayer helper class

extern NSString * const kMMButtonLayerStateKey;
extern NSString * const kMMButtonLayerHighlightedKey;
extern NSString * const kMMButtonLayerEnabledKey;
extern NSString * const kMMButtonLayerStateKey;
extern NSString * const kMMButtonLayerTypeKey;

@interface MMButtonLayer : CALayer

@property(strong) __attribute__((NSObject)) CGImageRef image;
@property(strong) __attribute__((NSObject)) CGImageRef alternateImage;
@property (nonatomic, weak) id<NSObject> target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSCellStateValue state;
@property (nonatomic, assign) NSButtonType type;

- (void)performClick:(id)sender;

@end
