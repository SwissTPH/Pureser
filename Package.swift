// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Pureser",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
		//--------------------------------------------------

        .package(url: "https://github.com/vapor/vapor.git", from: "4.5.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),

		//--------------------------------------------------

		.package(url: "https://github.com/rannym/PrintMore.git", .branch("main")),

		//--------------------------------------------------

		.package(url: "https://github.com/CoreOffice/CryptoOffice.git", .upToNextMinor(from: "0.1.1")),
		.package(url: "https://github.com/CoreOffice/CoreXLSX.git", .upToNextMinor(from: "0.14.0")),

		//--------------------------------------------------

		.package(name: "HTML", url: "https://github.com/robb/Swim.git", from: "0.1.1"),

		//--------------------------------------------------

		.package(url: "https://github.com/eneko/RegEx.git", from: "0.3.0"),

		//--------------------------------------------------
    ],
    targets: [
        .target(name: "SurveyTypes", dependencies: []),
        .target(name: "XlsxParser", dependencies: [
            //--------------------------------------------------

            .target(name: "SurveyTypes"),

            //--------------------------------------------------

            .product(name: "Vapor", package: "vapor"),

            //--------------------------------------------------

            "PrintMore",

            //--------------------------------------------------

            "CryptoOffice",
            "CoreXLSX",

            //--------------------------------------------------

            .product(name: "HTML", package: "HTML"),

            //--------------------------------------------------

            "RegEx",

            //--------------------------------------------------
        ]),
        .target(
            name: "App",
            dependencies: [
				//--------------------------------------------------

                .target(name: "SurveyTypes"),
                .target(name: "XlsxParser"),

                //--------------------------------------------------

                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),

				//--------------------------------------------------

				"PrintMore",

				//--------------------------------------------------

				"CryptoOffice",
				"CoreXLSX",

				//--------------------------------------------------

				.product(name: "HTML", package: "HTML"),

				//--------------------------------------------------
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
