// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Emacs",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Emacs", type: .dynamic, targets: ["Plugin"])
    ],
    targets: [
        .target(
            name: "Plugin",
            path: "Sources/Plugin"
        )
    ]
)