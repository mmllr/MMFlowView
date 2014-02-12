//
//  MMFlowViewImageCacheSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 02.01.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <QuickLook/QuickLook.h>

#import "Kiwi.h"
#import "MMFlowViewImageCache.h"
#import "MMFlowView.h"
#import "MMMacros.h"

SPEC_BEGIN(MMFlowViewImageCacheSpec)

describe(@"MMFlowViewImageCache", ^{
	__block MMFlowViewImageCache *sut = nil;

	beforeEach(^{
		sut = [[MMFlowViewImageCache alloc] init];
	});
	afterEach(^{
		sut = nil;
	});
	context(@"newly created instance", ^{
		it(@"should exist", ^{
			[[sut shouldNot] beNil];
		});
		it(@"should conform to MMFlowViewImageCache", ^{
			[[sut should] conformToProtocol:@protocol(MMFlowViewImageCache)];
		});
		it(@"should repond to cacheImage:withUUID:", ^{
			[[sut should] respondToSelector:@selector(cacheImage:withUUID:)];
		});
		it(@"should respond to imageForUUID:", ^{
			[[sut should] respondToSelector:@selector(imageForUUID:)];
		});
		context(@"caching items", ^{
			__block CGImageRef imageRef = NULL;

			beforeAll(^{
				NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
				NSDictionary *quickLookOptions = @{(id)kQLThumbnailOptionIconModeKey: (id)kCFBooleanFalse};
				imageRef = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)(imageURL), CGSizeMake(400, 400), (__bridge CFDictionaryRef)quickLookOptions );
				
			});
			afterAll(^{
				SAFE_CGIMAGE_RELEASE(imageRef);
			});
			context(@"an image in cache", ^{
				beforeEach(^{
					[sut cacheImage:imageRef withUUID:@"item"];
				});
				it(@"should not return NULL when asking for the item", ^{
					CGImageRef cachedImage = [sut imageForUUID:@"item"];
					[[theValue(cachedImage != NULL) should] beYes];
				});
				it(@"should put an item to the cache", ^{
					CGImageRef cachedImage = [sut imageForUUID:@"item"];
					[[theValue(cachedImage == imageRef) should] beYes];
				});
				context(@"when the cache is reset", ^{
					beforeEach(^{
						[sut reset];
					});
					it(@"should not have the previously cached image", ^{
						[[theValue([sut imageForUUID:@"item"] == NULL) should] beYes];
					});
				});
			});
			it(@"should return nil for an item not in the cache", ^{
				CGImageRef image = [sut imageForUUID:@"an item not in cache"];
				[[theValue(image == NULL) should] beYes];
			});
			it(@"should not throw when asking for an item with nil uuid", ^{
				[[theBlock(^{
					[sut imageForUUID:nil];
				}) shouldNot] raise];
			});
		});
	});
	
});

SPEC_END
