// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Stremio",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Stremio", targets: ["Stremio"]),
    ],
    targets: [
        .target(
            name: "Stremio",
            path: "Stremio"
        ),
    ]
)
