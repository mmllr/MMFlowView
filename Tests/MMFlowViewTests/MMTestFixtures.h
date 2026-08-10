//
//  MMTestFixtures.h
//  MMFlowViewTests
//
//  Helper to locate test fixture resources bundled by SwiftPM. SPM places test
//  resources in a separate resource bundle (MMFlowView_MMFlowViewTests.bundle)
//  that is a sibling of the test bundle, so plain [NSBundle bundleForClass:]
//  lookups do not find them.
//

#import <Foundation/Foundation.h>

@interface MMTestFixtures : NSObject

+ (NSBundle *)resourceBundle;

@end

static inline NSURL *MMTestFixtureURL(NSString *name, NSString *ext)
{
	return [[MMTestFixtures resourceBundle] URLForResource:name withExtension:ext];
}
