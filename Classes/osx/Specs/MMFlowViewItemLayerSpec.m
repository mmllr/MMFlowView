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
//  MMFlowViewItemLayerSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 29.10.13.
//  Copyright 2013 www.isnotnil.com. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowViewItemLayer.h"
#import "MMFlowViewImageLayer.h"

SPEC_BEGIN(MMFlowViewItemLayerSpec)

describe(@"MMFlowViewItemLayerSpec", ^{
	NSString *expectedImageUID = @"imageUID";
	const NSUInteger expectedIndex = 1;
	
	__block MMFlowViewItemLayer *sut = nil;

	context(@"creating with CALayer default -init/+layer", ^{
		it(@"should raise if created with +layer", ^{
			[[theBlock(^{
				[MMFlowViewItemLayer layer];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
		it(@"should raise if created with -init", ^{
			[[theBlock(^{
				sut = [[MMFlowViewItemLayer alloc] init];
			}) should] raiseWithName:NSInternalInconsistencyException];
		});
	});
	context(@"created with designated initalizer", ^{
		beforeEach(^{
			sut = [MMFlowViewItemLayer layerWithImageUID:expectedImageUID andIndex:expectedIndex];
		});
		afterEach(^{
			sut = nil;
		});
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should be a CAReplicatorLayer subclass", ^{
			[[sut should] beKindOfClass:[CAReplicatorLayer class]];
		});
		it(@"should have a default width of of 50", ^{
			[[theValue(CGRectGetWidth(sut.frame)) should] equal:theValue(50)];
		});
		it(@"should have a default height of 50", ^{
			[[theValue(CGRectGetHeight(sut.frame)) should] equal:theValue(50)];
		});
		it(@"should have an instanceCount of 2", ^{
			[[theValue(sut.instanceCount) should] equal:theValue(2)];
		});
		it(@"should have preservesDepth to be YES", ^{
			[[theValue(sut.preservesDepth) should] beYes];
		});
		it(@"should have the index set from the designated initializer", ^{
			[[theValue(sut.index) should] equal:theValue(expectedIndex)];
		});
		it(@"should have the imageUID set from the designated initializer", ^{
			[[sut.imageUID should] equal:expectedImageUID];
		});
		it(@"should have an imageLayer", ^{
			[[sut.imageLayer shouldNot] beNil];
		});
		it(@"should have an imageLayer of class MMFlowViewImageLayer", ^{
			[[sut.imageLayer should] beKindOfClass:[MMFlowViewImageLayer class]];
		});
		it(@"shoud have an instanceTransform for mirroring", ^{
			
		});
		context(@"reflectionOffset", ^{
			it(@"should have a reflectionOffset of -.4", ^{
				const CGFloat expectedOffset = -.4;

				[[theValue(sut.reflectionOffset) should] equal:expectedOffset withDelta:.0000001];
			});
			context(@"setting values", ^{
				beforeEach(^{
					sut.reflectionOffset = -.2;
				});
				it(@"should have an instanceRedOffset equal to reflectionOffset", ^{
					[[theValue(sut.instanceRedOffset) should] equal:sut.reflectionOffset withDelta:.000001];
				});
				it(@"should have an instanceGreenOffset equal to reflectionOffset", ^{
					[[theValue(sut.instanceGreenOffset) should] equal:sut.reflectionOffset withDelta:.000001];
				});
				it(@"should have an instanceBlueOffset equal to reflectionOffset", ^{
					[[theValue(sut.instanceBlueOffset) should] equal:sut.reflectionOffset withDelta:.000001];
				});
			});
			
		});
		context(@"setting an image", ^{
			__block CGImageRef expectedImage;
			__block NSValue *expectedSize;

			beforeEach(^{
				expectedImage = [[NSImage imageNamed:NSImageNameAdvanced] CGImageForProposedRect:NULL context:nil hints:nil];
				CGFloat aspectRatio = CGImageGetWidth(expectedImage) / CGImageGetHeight(expectedImage);

				CGSize size;
				if ( aspectRatio >= 1 ) {
					size = CGSizeMake(CGRectGetWidth(sut.bounds), CGRectGetHeight(sut.bounds) / aspectRatio);
				}
				else {
					size = CGSizeMake(CGRectGetWidth(sut.bounds)*aspectRatio, CGRectGetHeight(sut.bounds));
				}
				expectedSize = [NSValue valueWithSize:size];
				[sut setImage:expectedImage];
			});
			afterEach(^{
				CGImageRelease(expectedImage);
				expectedImage = NULL;
				expectedSize = nil;
			});
			it(@"should set the image layers bounds according to the images aspect ration", ^{
				[[[NSValue valueWithSize:sut.imageLayer.bounds.size] should] equal:expectedSize];
			});
		});
		
	});
});

SPEC_END
