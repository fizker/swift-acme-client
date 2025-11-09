// swift-tools-version: 6.2

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
	.enableUpcomingFeature("ExistentialAny"),
	.enableExperimentalFeature("StrictConcurrency"),
	.enableExperimentalFeature("AccessLevelOnImport"),
	.enableUpcomingFeature("InternalImportsByDefault"),
	.enableUpcomingFeature("FullTypedThrows"),
]

let package = Package(
	name: "swift-acme-client",
	platforms: [
		.iOS(.v15),
		.macOS(.v12),
		.tvOS(.v15),
		.watchOS(.v8),
	],
	products: [
		.library(
			name: "ACMEClient",
			targets: ["ACMEClient"],
		),
		.library(
			name: "ACMEClientModels",
			targets: ["ACMEClientModels"],
		),
		.executable(
			name: "acme-client",
			targets: ["ACMEClientCLI"],
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.2"),
		.package(url: "https://github.com/fizker/swift-extensions.git", from:"1.4.0"),
		.package(url: "https://github.com/fizker/swift-macro-compile-safe-init", from: "1.0.0"),
	],
	targets: [
		.target(
			name: "ACMEClient",
			dependencies: [
				"ACMEClientModels",
			],
			swiftSettings: upcomingFeatures,
		),
		.testTarget(
			name: "ACMEClientTests",
			dependencies: ["ACMEClient"],
		),

		.target(
			name: "ACMEAPIModels",
			dependencies: [
			],
			swiftSettings: upcomingFeatures,
		),
		.target(
			name: "ACMEClientModels",
			dependencies: [
				.product(name: "FzkExtensions", package: "swift-extensions"),
			],
			swiftSettings: upcomingFeatures,
		),
		.testTarget(
			name: "ACMEClientModelsTests",
			dependencies: [
				"ACMEClientModels",
				.product(name: "CompileSafeInitMacro", package: "swift-macro-compile-safe-init"),
			],
		),

		.executableTarget(
			name: "ACMEClientCLI",
			dependencies: [
				"ACMEClient",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
		),
	],
)
