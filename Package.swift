// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Parchment",
    platforms: [.iOS("9.0")],
    products: [
        .library(name: "Parchment", targets: ["Parchment"]),
    ],
    targets: [
        .target(
            name: "Parchment",
            path: "Parchment"
        )
    ]
)
