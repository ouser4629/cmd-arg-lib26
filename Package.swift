// Copyright (c) 2025 Peter Summerland
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "cmd-arg-lib26",

    platforms: [.macOS(.v26)],

    products: [
        .library(name: "CmdArgLib", targets: ["CmdArgLib"]),
        .library(name: "CmdArgLibMacros", targets: ["CmdArgLibMacros"]),
        .executable(name: "mf0-print", targets: ["Example1"]),
        .executable(name: "mf1-greet", targets: ["Example2"]),
    ],

    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest"),
    ],
    
    targets: [
        .macro(
            name: "CmdArgLibMacrosModule",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "CmdArgLibMacroSupport",
            ]),
        .target(
            name: "CmdArgLibMacros",
            dependencies: [
                "CmdArgLibMacrosModule",
            ]),
        .binaryTarget(name: "CmdArgLibMacroSupport", path: "CmdArgLibMacroSupport.xcframework"),
        .binaryTarget( name: "CmdArgLib", path: "CmdArgLib.xcframework"),
        //
        .executableTarget(
              name: "Example1",
              dependencies: ["CmdArgLib", "CmdArgLibMacros",]
          ),
        .executableTarget(
              name: "Example2",
              dependencies: ["CmdArgLib", "CmdArgLibMacros",]
          ),
    ]
)
