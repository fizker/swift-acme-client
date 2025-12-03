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
		.macOS(.v13),
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
		.package(url: "https://github.com/apple/swift-crypto.git", from: "4.1.0"),
		.package(url: "https://github.com/fizker/swift-extensions.git", from:"1.5.1"),
		.package(url: "https://github.com/fizker/swift-macro-compile-safe-init", from: "1.0.0"),
		.package(url: "https://github.com/guykogus/SwifterJSON.git", from: "4.2.0"),
		.package(url: "https://github.com/swift-server/async-http-client.git", from: "1.29.1"),
		.package(url: "https://github.com/vapor/jwt-kit.git", from: "5.3.0"),
	],
	targets: [
		.target(
			name: "ACMEClient",
			dependencies: [
				"ACMEAPIModels",
				"ACMEClientModels",
				.product(name: "AsyncHTTPClient", package: "async-http-client"),
				.product(name: "JWTKit", package: "jwt-kit"),
				.product(name: "Crypto", package: "swift-crypto"),
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
				.product(name: "SwifterJSON", package: "SwifterJSON"),
			],
			swiftSettings: upcomingFeatures,
		),
		.testTarget(
			name: "ACMEAPIModelsTests",
			dependencies: [
				"ACMEAPIModels",
				.product(name: "FzkExtensions", package: "swift-extensions"),
			],
		),

		.target(
			name: "ACMEClientModels",
			dependencies: [
				.product(name: "FzkExtensions", package: "swift-extensions"),
				.product(name: "CompileSafeInitMacro", package: "swift-macro-compile-safe-init"),
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
