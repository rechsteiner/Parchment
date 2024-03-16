// swift-tools-version:5.10
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
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
