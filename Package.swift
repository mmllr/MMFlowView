// swift-tools-version: 5.9
//
//  Package.swift
//  MMFlowView
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Markus Müller https://codeberg.org/mmllr All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software, and to permit
//  persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.

import PackageDescription

let package = Package(
    name: "MMFlowView",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(name: "MMFlowView", targets: ["MMFlowView"]),
    ],
    targets: [
        .target(
            name: "MMFlowView",
            dependencies: ["MMLayerAccessibility"],
            publicHeadersPath: ".",
            cSettings: [
                .unsafeFlags(["-fobjc-arc", "-Wno-deprecated-declarations"]),
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Quartz"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("CoreImage"),
                .linkedFramework("QuickLook"),
            ]
        ),
        .target(
            name: "MMLayerAccessibility",
            publicHeadersPath: ".",
            cSettings: [
                .unsafeFlags(["-fobjc-arc", "-Wno-deprecated-declarations"]),
            ]
        ),
        .testTarget(
            name: "MMFlowViewTests",
            dependencies: ["MMFlowView"],
            resources: [
                .copy("Test.pdf"),
                .copy("TestImage01.jpg"),
            ]
        ),
    ]
)
