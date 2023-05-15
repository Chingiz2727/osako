// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UGOUIKit",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "UGOUIKit",
            targets: ["UGOUIKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0"),
        .package(name: "UGOCore", path: "./UGOCore"),
    ],
    targets: [
        .target(
            name: "UGOUIKit",
            dependencies: [
                .byName(name: "SnapKit"),
                .byName(name: "SDWebImage"),
                .byName(name: "UGOCore")
            ],
            resources: [
                .process("Resources/Fonts/Montserrat-Black.ttf"),
                .process("Resources/Fonts/Montserrat-BlackItalic.ttf"),
                .process("Resources/Fonts/Montserrat-Bold.ttf"),
                .process("Resources/Fonts/Montserrat-BoldItalic.ttf"),
                .process("Resources/Fonts/Montserrat-ExtraBold.ttf"),
                .process("Resources/Fonts/Montserrat-ExtraBoldItalic.ttf"),
                .process("Resources/Fonts/Montserrat-ExtraLight.ttf"),
                .process("Resources/Fonts/Montserrat-ExtraLightItalic.ttf"),
                .process("Resources/Fonts/Montserrat-Italic.ttf"),
                .process("Resources/Fonts/Montserrat-Light.ttf"),
                .process("Resources/Fonts/Montserrat-LightItalic.ttf"),
                .process("Resources/Fonts/Montserrat-Medium.ttf"),
                .process("Resources/Fonts/Montserrat-MediumItalic.ttf"),
                .process("Resources/Fonts/Montserrat-Regular.ttf"),
                .process("Resources/Fonts/Montserrat-SemiBold.ttf"),
                .process("Resources/Fonts/Montserrat-SemiBoldItalic.ttf"),
                .process("Resources/Fonts/Montserrat-Thin.ttf"),
                .process("Resources/Fonts/Montserrat-ThinItalic.ttf"),
                .process("Resources/Colors/Media.xcassets"),
                .process("Resources/Icons/Icons.xcassets"),
            ]
        ),
    ]
)
