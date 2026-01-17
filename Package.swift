// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HotSwitch",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "HotSwitch",
            resources: [
                .process("../../Resources/Info.plist")
            ]
        )
    ]
)
