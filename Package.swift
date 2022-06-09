// swift-tools-version: 5.6

///
import PackageDescription

///
let package = Package(
    name: "FlameStride",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(
            name: "FlameStride",
            targets: ["FlameStride"]
        ),
    ],
    dependencies: [],
    targets: [
        
        ///
        .target(
            name: "FlameStride",
            dependencies: []
        ),
        
        ///
        .testTarget(
            name: "FlameStride-tests",
            dependencies: ["FlameStride"]
        ),
    ]
)
