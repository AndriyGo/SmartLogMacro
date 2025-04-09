// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SmartLogMacro",
    platforms: [.macOS(.v11), .iOS(.v15), .tvOS(.v14), .watchOS(.v7), .macCatalyst(.v13), .visionOS(.v1)],
    products: [
        .library(
            name: "SmartLogMacro",
            targets: ["SmartLogMacro"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "SmartLogMacroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "SmartLogMacro", dependencies: ["SmartLogMacroMacros"]),
        .testTarget(
            name: "SmartLogTests",
            dependencies: [
                "SmartLogMacroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
