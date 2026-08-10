XCODEBUILD := xcodebuild
PROJECT := Example/MMFlowViewDemo.xcodeproj
SCHEME := MMFlowViewDemo
CONFIGURATION := Debug
DERIVED_DATA := build
APP := $(DERIVED_DATA)/Build/Products/$(CONFIGURATION)/MMFlowViewDemo.app

.PHONY: run build test clean

# default target: build and run the example app
run:
	$(XCODEBUILD) -project $(PROJECT) -scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(DERIVED_DATA) \
		CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
		build
	open "$(APP)"

build:
	swift build

test:
	swift test

clean:
	swift package clean
	rm -rf $(DERIVED_DATA) .build
