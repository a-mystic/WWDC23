// swift-tools-version: 5.8

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Detective",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Detective",
            targets: ["AppModule"],
            bundleIdentifier: "com.mystic.detective",
            teamIdentifier: "96B293Z3Y9",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .magicWand),
            accentColor: .presetColor(.brown),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "can i use camera?"),
                .photoLibrary(purposeString: "can i use photo?")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        )
    ]
)
