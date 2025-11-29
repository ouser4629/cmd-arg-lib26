// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

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

// Example2
//

// Suggested command calls:
//     > ./mf1-greet --help
//     > ./mf1-greet -lui Manny
//     > ./mf1-greet -uc1 --greeting "Welcome home" Manny
//     > ./mf1-greet -uxc1.0 --greet
//

import CmdArgLib
import CmdArgLibMacros

typealias Greeting = String
typealias Name = String
typealias Count = Int

enum Prefix: String, CaseIterable, CustomStringConvertible, BasicParameterType {
    case arrow, stars, dashes
}

@main
struct GreetMain {

    @MainFunction(shadowGroups: ["lower upper"])
    private static func m1Greet(
        i includeIndex: Flag,
        u upper: Flag = false,
        l lower: Flag = false,
        p__prefix prefix: Prefix = .dashes,
        c__count repeats: Count? = nil,
        g__greeting greeting: Greeting = "Hello",
        _ name: Name,
        authors: MetaFlag = MetaFlag(string: "Robert Ford and Jesse James"),
        h__help help: MetaFlag = MetaFlag(helpElements: helpElements),
        v__version version: MetaFlag = MetaFlag(string: "version 0.1.0 - 2025-10-14")
    ) {
        let count = repeats == nil || repeats! < 1 ? (Int.random(in: 1...3)) : repeats!
        let prefixText: String
        switch prefix {
        case .arrow: prefixText = "-->"
        case .stars: prefixText = "***"
        case .dashes: prefixText = "---"
        }
        var text = "\(greeting) \(name)"
        text = lower ? text.lowercased() : upper ? text.uppercased() : text
        for index in 1...count {
            var text = (includeIndex ? "\(index) " : "") + "\(greeting) \(name)"
            if upper { text = text.uppercased() }
            print("\(prefixText) \(text)")
        }
    }

    private static let helpElements: [ShowElement] = [
        .text("DESCRIPTION:", "Print a greeting."),
        .synopsis("\nUSAGE:"),
        .text("\nPARAMETERS:"),
        .parameter("includeIndex", "Show index of repeated greetings"),
        .parameter("upper", "Print text in upper case"),
        .parameter("lower", "Print text in lower case"),
        .parameter("help", "Show this help message"),
        .parameter("version", "Show version information"),
        .parameter("prefix", "Text to prefix each greeting with"),
        .parameter(
            "repeats", "Repeat the greeting $E{repeats} times (the default is a random integer between 1 and 3)"),
        .parameter("greeting", "The greeting to print"),
        .parameter("name", "Name of person to greet, if any"),
        .text("\nNOTES:\n", note1),
        .text("\n", note2),
        .text("\n", note3),
    ]

    private static let note1 = """
        The $S{lower} and $S{upper} options shadow each other; only the last one specified 
        is applicable.
        """

    private static let note2 = """
        The available prefixes are \(Prefix.casesJoined(separator: ", " )).
        """

    private static let note3 = """
        Bracketed parameters in the synopsis line are not required because they have
        explicit or implied default values. The other parameters are required.
        """
}
