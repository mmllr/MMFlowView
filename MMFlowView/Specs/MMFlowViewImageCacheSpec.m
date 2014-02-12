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
			__block CGImageRef testImageRef = NULL;

			beforeAll(^{
				NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
				NSDictionary *quickLookOptions = @{(id)kQLThumbnailOptionIconModeKey: (id)kCFBooleanFalse};
				testImageRef = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)(imageURL), CGSizeMake(400, 400), (__bridge CFDictionaryRef)quickLookOptions );
			});
			afterAll(^{
				SAFE_CGIMAGE_RELEASE(testImageRef);
			});
			context(@"when having images in cache", ^{
				beforeEach(^{
					[sut cacheImage:testImageRef withUUID:@"item1"];
					[sut cacheImage:testImageRef withUUID:@"item2"];
					[sut cacheImage:testImageRef withUUID:@"item3"];
				});
				it(@"should contain the cached items", ^{
					NSArray *expectedUUIDs = @[@"item1", @"item2", @"item3"];

					for (NSString *itemID in expectedUUIDs) {
						CGImageRef cachedImage = [sut imageForUUID:itemID];
						[[theValue(cachedImage != NULL) should] beYes];
					}
				});
				it(@"should not return NULL when asking for the item", ^{
					CGImageRef cachedImage = [sut imageForUUID:@"item1"];
					[[theValue(cachedImage != NULL) should] beYes];
				});
				it(@"should put an item to the cache", ^{
					CGImageRef cachedImage = [sut imageForUUID:@"item1"];
					[[theValue(cachedImage == testImageRef) should] beYes];
				});
				it(@"should return the same image when asking repeatedly for it", ^{
					for (int i = 0; i < 5; ++i) {
						CGImageRef cachedImage = [sut imageForUUID:@"item1"];
						[[theValue(cachedImage == testImageRef) should] beYes];
					}
				});
				context(@"removing images", ^{
					beforeEach(^{
						[sut removeImageWithUUID:@"item2"];
					});
					it(@"should not contain the removed item", ^{
						[[theValue([sut imageForUUID:@"item2"] == NULL) should] beYes];
					});
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
