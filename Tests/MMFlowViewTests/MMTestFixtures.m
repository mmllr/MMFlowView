//
//  MMTestFixtures.m
//  MMFlowViewTests
//

#import "MMTestFixtures.h"

@implementation MMTestFixtures

+ (NSBundle *)resourceBundle
{
	NSBundle *testBundle = [NSBundle bundleForClass:self];
	// Direct hit: resources embedded in the test bundle itself.
	if ([testBundle URLForResource:@"TestImage01" withExtension:@"jpg"]) {
		return testBundle;
	}
	// SwiftPM layout: resources live in a sibling resource bundle next to the
	// test bundle (e.g. .build/<triple>/debug/MMFlowView_MMFlowViewTests.bundle).
	NSURL *resourceBundleURL = [[testBundle bundleURL] URLByDeletingLastPathComponent];
	resourceBundleURL = [resourceBundleURL URLByAppendingPathComponent:@"MMFlowView_MMFlowViewTests.bundle"];
	NSBundle *resourceBundle = [NSBundle bundleWithURL:resourceBundleURL];
	if (resourceBundle) {
		return resourceBundle;
	}
	return testBundle;
}

@end
