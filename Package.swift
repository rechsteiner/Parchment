// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Parchment",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "Parchment", targets: ["Parchment"]),
    ],
    targets: [
        .target(
            name: "Parchment",
            path: "Parchment",
            linkerSettings: [
                .unsafeFlags([
                    "-weak_framework", "SwiftUI",
                ]),
            ]
        ),
    ]
)
