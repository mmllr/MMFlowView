.PHONY: build test clean

build:
	swift build

test:
	swift test

clean:
	swift package clean
	rm -rf .build
