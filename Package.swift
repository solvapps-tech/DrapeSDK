// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DrapeSDK",
    // 1. Platform Desteği (iOS 15+ demiştik async/await için)
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // 2. Dışarıya ne sunuyoruz? (Kütüphane)
        .library(
            name: "DrapeSDK",
            targets: ["DrapeSDK"]),
    ],
    dependencies: [
        // 3. Bağımlılıklar (Bizim yok, tertemiz native!)
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // 4. Hedefler
        .target(
            name: "DrapeSDK",
            dependencies: [],
            resources: [
                .process("DrapeViewController.xib")
            ])
    ]
)
