// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Superboard",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "SuperboardCore", targets: ["SuperboardCore"]),
        .executable(name: "SuperboardMacApp", targets: ["SuperboardMacApp"]),
    ],
    targets: [
        .target(
            name: "SuperboardCore",
            path: "Sources/SuperboardCore"
        ),
        .executableTarget(
            name: "SuperboardMacApp",
            dependencies: ["SuperboardCore"],
            path: "Sources/SuperboardMacApp",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("Carbon"),
            ]
        ),
        .testTarget(
            name: "SuperboardCoreTests",
            dependencies: ["SuperboardCore"],
            path: "Tests/SuperboardCoreTests"
        ),
    ]
)
