WORKSPACE := Example/MMFlowViewDemo.xcworkspace
SCHEME := MMFlowViewDemo
CONFIGURATION := Debug
DERIVED_DATA := build

XCODEBUILD := xcodebuild
COMMON_FLAGS := -workspace $(WORKSPACE) -scheme $(SCHEME) \
	-configuration $(CONFIGURATION) \
	-derivedDataPath $(DERIVED_DATA) \
	CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

.PHONY: build test clean

build:
	$(XCODEBUILD) $(COMMON_FLAGS) build

test:
	$(XCODEBUILD) $(COMMON_FLAGS) test

clean:
	$(XCODEBUILD) -workspace $(WORKSPACE) -scheme $(SCHEME) clean
	rm -rf $(DERIVED_DATA)
