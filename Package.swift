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
	],
	dependencies: [
		.package(url: "https://github.com/fizker/swift-extensions.git", from:"1.4.0"),
	],
	targets: [
		.target(
			name: "ACMEClient",
			dependencies: [
				"ACMEClientModels",
			],
			swiftSettings: upcomingFeatures,
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
			name: "ACMEClientTests",
			dependencies: ["ACMEClient"],
		),
	],
)
