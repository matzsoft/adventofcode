// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "adventOfCode",
    platforms: [ .macOS( "13.0" ) ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package( path: "../Library" ),
        .package( url: "https://github.com/apple/swift-argument-parser", .upToNextMinor( from: "0.4.0" ) ),
        .package(
            name: "Mustache",
            url: "https://github.com/groue/GRMustache.swift",
            .upToNextMajor( from: "4.0.0" )
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "adventOfCode",
            dependencies: [
                "Library",
                .product( name: "ArgumentParser", package: "swift-argument-parser" ),
                "Mustache",
            ],
            resources: [
                .process( "Resources/mainswift.mustache" ),
                .process( "Resources/PackageSwift.mustache" ),
            ]
        ),
        .testTarget(
            name: "adventOfCodeTests",
            dependencies: ["adventOfCode"]),
    ]
)
