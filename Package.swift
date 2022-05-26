// swift-tools-version: 5.6

///
import PackageDescription

///
let package = Package(
    name: "UserDefaultsDisplayModule",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(
            name: "UserDefaultsDisplayModule",
            targets: ["UserDefaultsDisplayModule"]
        ),
    ],
    dependencies: [],
    targets: [
        
        ///
        .target(
            name: "UserDefaultsDisplayModule",
            dependencies: []
        ),
        
        ///
        .testTarget(
            name: "UserDefaultsDisplayModule-tests",
            dependencies: ["UserDefaultsDisplayModule"]
        ),
    ]
)
