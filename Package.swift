// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LOSTTools",
    platforms: [
        .macOS(.v13), .iOS(.v16)
    ],
    products: [
        .executable(name: "LOSTTools", targets: ["LostApp"])
    ],
    targets: [
        .executableTarget(
            name: "LostApp",
            path: "Sources/LostApp"
        )
    ]
)