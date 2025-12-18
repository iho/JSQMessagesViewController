// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "JSQMessagesViewController",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "JSQMessagesViewController",
            targets: ["JSQMessagesViewController"])
    ],
    dependencies: [
        // Dependencies go here.
    ],
    targets: [
        .target(
            name: "JSQMessagesViewController",
            path: "JSQMessagesViewController",  // Assumes sources are directly here or in subfolders
            exclude: [
                "Info.plist",
                "Assets/JSQMessagesAssets.bundle/Info.plist",  // Exclude other non-source files if necessary
            ],
            resources: [
                .process("Assets/JSQMessagesAssets.bundle")  // Handle assets if they exist and are needed
            ]
        )
    ]
)
