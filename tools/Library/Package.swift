// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Library",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Library",
            targets: ["Library"]),
    ],
    dependencies: [
//        .package( path: "/Users/markj/Development/Swift/MATZMiscSwiftLibrary" )
        .package( url: "https://github.com/matzsoft/MATZMiscSwiftLibrary.git", from: "1.0.0" )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Library",
            dependencies: [ "MATZMiscSwiftLibrary" ]
        ),
        .testTarget(
            name: "LibraryTests",
            dependencies: ["Library"]),
    ]
)
