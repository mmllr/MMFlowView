//
//  MMFlowViewCoverFlowLayoutDelegateSpec.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 26.03.14.
//  Copyright 2014 Markus Müller. All rights reserved.
//

#import "Kiwi.h"
#import "MMFlowView+MMCoverFlowLayoutDelegate.h"
#import "MMFlowViewImageCache.h"
#import "MMFlowView_Private.h"
#import "MMMacros.h"

SPEC_BEGIN(MMFlowViewCoverFlowLayoutDelegateSpec)

describe(NSStringFromProtocol(@protocol(MMCoverFlowLayoutDelegate)), ^{
	__block MMFlowView *sut = nil;
	__block id contentAdapterMock = nil;
	__block CGImageRef testImageRef = NULL;
	
	beforeAll(^{
		NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
		NSDictionary *quickLookOptions = @{(id)kQLThumbnailOptionIconModeKey: (id)kCFBooleanFalse};
		testImageRef = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)(imageURL), CGSizeMake(400, 400), (__bridge CFDictionaryRef)quickLookOptions );
	});
	afterAll(^{
		SAFE_CGIMAGE_RELEASE(testImageRef);
	});

	beforeEach(^{
		sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
		contentAdapterMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewContentAdapter)];
		sut.contentAdapter = contentAdapterMock;
	});
	afterEach(^{
		sut = nil;
		contentAdapterMock = nil;
	});
	context(NSStringFromSelector(@selector(coverFLowLayout:aspectRatioForItem:)), ^{
		it(@"should respond to coverFLowLayout:aspectRatioForItem:", ^{
			[[sut should] respondToSelector:@selector(coverFLowLayout:aspectRatioForItem:)];
		});
		context(@"image cache interaction", ^{
			NSString *testUID = @"testUID";
			__block MMFlowViewImageCache *imageCacheMock = nil;
			__block id itemMock = nil;

			beforeEach(^{
				itemMock = [KWMock nullMockForProtocol:@protocol(MMFlowViewItem)];
				[itemMock stub:@selector(imageItemUID) andReturn:testUID];
				[contentAdapterMock stub:@selector(objectAtIndexedSubscript:) andReturn:itemMock];

				imageCacheMock = [KWMock nullMockForClass:[MMFlowViewImageCache class]];
				sut.imageCache = imageCacheMock;
			});
			afterEach(^{
				itemMock = nil;
				imageCacheMock = nil;
			});

			it(@"should ask the image cache for the item", ^{
				[[imageCacheMock should] receive:@selector(imageForUUID:) withArguments:testUID];

				[sut coverFLowLayout:sut.coverFlowLayout aspectRatioForItem:0];
			});
			context(@"when there is no image in the cache", ^{
				beforeEach(^{
					[imageCacheMock stub:@selector(imageForUUID:) andReturn:(__bridge id)NULL];
				});
				it(@"should return 1", ^{
					[[theValue([sut coverFLowLayout:sut.coverFlowLayout aspectRatioForItem:0]) should] equal:1 withDelta:0.0000001];
				});
			});
			context(@"when there is an image in the cache", ^{
				beforeEach(^{
					[imageCacheMock stub:@selector(imageForUUID:) andReturn:(__bridge id)testImageRef];
				});
				it(@"should return the aspect ratio of the image", ^{
					CGFloat expectedAspectRatio = (CGFloat)CGImageGetWidth(testImageRef) / (CGFloat)CGImageGetHeight(testImageRef);

					[[theValue([sut coverFLowLayout:sut.coverFlowLayout aspectRatioForItem:0]) should] equal:expectedAspectRatio withDelta:0.0000001];
				});
			});
		});
	});
});

SPEC_END
